import 'dart:convert';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:opennutritracker/features/add_meal/data/repository/products_repository.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_entity.dart';

class SearchFoodUseCase {
  static const _maxDimension = 1024;
  static const _maxUploadBytes = 1024 * 1024;
  static const _minJpegQuality = 80;

  final ProductsRepository _productsRepository;

  SearchFoodUseCase(this._productsRepository);

  Future<List<MealEntity>> getNutriInfoFromText(String text) async {
    return _productsRepository.getSearchFoodByText(text);
  }

  Future<List<MealEntity>> estimateCaloriesFromImage(
      Uint8List imageBytes) async {
    final processedBytes = _prepareImageForUpload(imageBytes);
    final base64Image = base64Encode(processedBytes);

    return _productsRepository.getSearchFoodByImage(
      base64Image: base64Image,
      mimeType: 'image/jpeg',
    );
  }

  Uint8List _prepareImageForUpload(Uint8List rawBytes) {
    final decodedImage = img.decodeImage(rawBytes);
    if (decodedImage == null) {
      throw const FormatException('Unsupported image format');
    }

    final resizedImage = _resizeIfNeeded(decodedImage);

    var quality = 95;
    var encodedBytes = Uint8List.fromList(
      img.encodeJpg(resizedImage, quality: quality),
    );

    // Keep quality high and only reduce while payload is still too large.
    while (encodedBytes.lengthInBytes > _maxUploadBytes &&
        quality > _minJpegQuality) {
      quality -= 5;
      encodedBytes = Uint8List.fromList(
        img.encodeJpg(resizedImage, quality: quality),
      );
    }

    return encodedBytes;
  }

  img.Image _resizeIfNeeded(img.Image image) {
    if (image.width <= _maxDimension && image.height <= _maxDimension) {
      return image;
    }

    final aspectRatio = image.width / image.height;

    if (aspectRatio >= 1) {
      return img.copyResize(
        image,
        width: _maxDimension,
        height: (_maxDimension / aspectRatio).round(),
      );
    }

    return img.copyResize(
      image,
      width: (_maxDimension * aspectRatio).round(),
      height: _maxDimension,
    );
  }
}
