const { onRequest } = require("firebase-functions/https");
const { defineSecret } = require("firebase-functions/params");
const { GoogleGenerativeAI } = require("@google/generative-ai");

// Define the secret
const GEMINI_API_KEY = defineSecret("GEMINI_API_KEY");

exports.getNutriInfoFromText = onRequest({
  secrets: [GEMINI_API_KEY],
  region: "europe-west3",
  cors: true,
}, async (req, res) => {

  // 1. Get the user message from the URL (e.g., ?text=1 apple)
  const userMessage = req.query.text;

  if (!userMessage) {
    return res.status(400).send({ error: "Please provide text in the URL. Example: ?text=1 apple" });
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

    // 3. Parse the string into a real JSON object and send it back
    const nutritionData = JSON.parse(responseText);

    return res.status(200).send(nutritionData);

  } catch (error) {
    console.error("Gemini Error:", error);
    return res.status(500).send({ error: "AI failed to generate nutrition data." });
  }
});


exports.estimateCaloriesFromImage = onRequest({
  secrets: [GEMINI_API_KEY],
  region: "europe-west3",
  cors: true,
}, async (req, res) => {

  // 1. Ensure it's a POST request
  if (req.method !== "POST") {
    return res.status(405).send({ error: "Only POST allowed (Send image in body)" });
  }

  // 2. Expecting base64 string and mimeType in the body
  const { base64Image, mimeType } = req.body;

  if (!base64Image) {
    return res.status(400).send({ error: "No image data provided (base64Image required)." });
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

    // 3. Prepare image for Gemini
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

    return res.status(200).send(JSON.parse(responseText));

  } catch (error) {
    console.error("Vision Error:", error);
    return res.status(500).send({ error: "AI failed to analyze image." });
  }
});

