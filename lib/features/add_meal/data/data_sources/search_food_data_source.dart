import 'package:cloud_functions/cloud_functions.dart';
import 'package:logging/logging.dart';
import 'package:opennutritracker/features/add_meal/data/dto/search_food/search_food_response_dto.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class SearchFoodDataSource {
  final log = Logger('SearchFoodDataSource');
  final FirebaseFunctions _firebaseFunctions;

  SearchFoodDataSource({FirebaseFunctions? firebaseFunctions})
      : _firebaseFunctions = firebaseFunctions ??
            FirebaseFunctions.instanceFor(region: 'europe-west3');

  Future<SearchFoodResponseDTO> getNutriInfoFromText(String text) async {
    print("search request with: $text");
    return _callSearchFunction('getNutriInfoFromText', {'text': text});
  }

  Future<SearchFoodResponseDTO> estimateCaloriesFromImage({
    required String base64Image,
    String mimeType = 'image/jpeg',
  }) async {
    return _callSearchFunction('estimateCaloriesFromImage', {
      'base64Image': base64Image,
      'mimeType': mimeType,
    });
  }

  Future<SearchFoodResponseDTO> _callSearchFunction(
    String functionName,
    Map<String, dynamic> payload,
  ) async {
    try {
      final callable = _firebaseFunctions.httpsCallable(functionName);
      final response = await callable.call(payload);
      final responseData = response.data;

      if (responseData is! Map) {
        return Future.error(
          const FormatException(
              'Invalid callable response. Expected JSON object.'),
        );
      }

      final responseJson = _deepCast(responseData);
      print("response: $responseJson");
      return SearchFoodResponseDTO.fromJson(responseJson);
    } catch (exception, stacktrace) {
      log.severe('Exception while calling $functionName: $exception');
      Sentry.captureException(exception, stackTrace: stacktrace);
      return Future.error(exception);
    }
  }

  Map<String, dynamic> _deepCast(dynamic value) {
    if (value is Map) {
      return value.map<String, dynamic>(
        (key, val) => MapEntry(key.toString(), _deepCastValue(val)),
      );
    }
    throw const FormatException(
        'Invalid callable response. Expected JSON object.');
  }

  dynamic _deepCastValue(dynamic value) {
    if (value is Map) {
      return _deepCast(value);
    } else if (value is List) {
      return value.map(_deepCastValue).toList();
    }
    return value;
  }
}
