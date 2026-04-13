const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");
const { GoogleGenerativeAI } = require("@google/generative-ai");

// Define the secret
const GEMINI_API_KEY = defineSecret("GEMINI_API_KEY");

exports.getNutriInfoFromText = onCall({
  secrets: [GEMINI_API_KEY],
  region: "europe-west3",
}, async (request) => {

  // 1. Get the user message from the data payload
  const userMessage = request.data.text;

  if (!userMessage) {
    throw new HttpsError("invalid-argument", "Please provide text in the 'text' field.");
  }

  // 2. Your internal, hidden prompt
  const internalPrompt = `
      Identify each food item and its quantity from the user input.
      If no quantity is specified, assume 100g.
      Return a JSON object containing a single array named "items".
      Each element in the array must be an object with these exact keys:
      "foodName" (string), "calories" (integer), "protein_g" (integer), "carbs_g" (integer), "fat_g" (integer), "quantity_g" (integer).
      Example Input: "2 eggs and a banana"
      Example Output: {"items": [{"foodName": "egg", "calories": 140, "protein_g": 12, "carbs_g": 1, "fat_g": 10, "quantity_g": 100}, ...]}
    `;

  try {
    const genAI = new GoogleGenerativeAI(GEMINI_API_KEY.value());
    const model = genAI.getGenerativeModel({
      model: "gemini-2.5-flash-lite",
      // Forces the model to respond with a JSON object
      generationConfig: { responseMimeType: "application/json" }
    });

    const result = await model.generateContent([internalPrompt, userMessage]);
    const responseText = result.response.text();

    // 3. Parse the string into a real JSON object and return it
    return JSON.parse(responseText);

  } catch (error) {
    console.error("Gemini Error:", error);
    throw new HttpsError("internal", "AI failed to generate nutrition data.");
  }
});


exports.estimateCaloriesFromImage = onCall({
  secrets: [GEMINI_API_KEY],
  region: "europe-west3",
}, async (request) => {

  // 1. Expecting base64 string and mimeType in the data payload
  const { base64Image, mimeType } = request.data;

  if (!base64Image) {
    throw new HttpsError("invalid-argument", "No image data provided (base64Image required).");
  }

  const internalPrompt = `
    Analyze this image of food. Identify every item shown.
    Estimate weights and nutritional values.
    Return a JSON object containing a single array named "items".
    Each element must have: "foodName", "calories", "protein_g", "carbs_g", "fat_g", "quantity_g".
    Strictly output raw JSON only.
    Example Output: {"items": [{"foodName": "egg", "calories": 140, "protein_g": 12, "carbs_g": 1, "fat_g": 10, "quantity_g": 100}, ...]}
  `;

  try {
    const genAI = new GoogleGenerativeAI(GEMINI_API_KEY.value());
    const model = genAI.getGenerativeModel({
      model: "gemini-2.5-flash",
      generationConfig: { responseMimeType: "application/json" }
    });

    // 2. Prepare image for Gemini
    const imageParts = [
      {
        inlineData: {
          data: base64Image,
          mimeType: mimeType || "image/jpeg"
        }
      }
    ];

    const result = await model.generateContent([internalPrompt, ...imageParts]);
    const responseText = result.response.text();

    return JSON.parse(responseText);

  } catch (error) {
    console.error("Vision Error:", error);
    throw new HttpsError("internal", "AI failed to analyze image.");
  }
});
