import 'package:opennutritracker/features/add_meal/data/data_sources/fdc_data_source.dart';
import 'package:opennutritracker/features/add_meal/data/data_sources/off_data_source.dart';
import 'package:opennutritracker/features/add_meal/data/data_sources/search_food_data_source.dart';
import 'package:opennutritracker/features/add_meal/data/data_sources/sp_fdc_data_source.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_entity.dart';

class ProductsRepository {
  final OFFDataSource _offDataSource;
  final FDCDataSource _fdcDataSource;
  final SpFdcDataSource _spBackendDataSource;
  final SearchFoodDataSource _searchFoodDataSource;

  ProductsRepository(this._offDataSource, this._fdcDataSource,
      this._spBackendDataSource, this._searchFoodDataSource);

  Future<List<MealEntity>> getOFFProductsByString(String searchString) async {
    final offWordResponse =
        await _offDataSource.fetchSearchWordResults(searchString);

    final products = offWordResponse.products
        .map((offProduct) => MealEntity.fromOFFProduct(offProduct))
        .toList();

    return products;
  }

  Future<List<MealEntity>> getFDCFoodsByString(String searchString) async {
    final fdcWordResponse =
        await _fdcDataSource.fetchSearchWordResults(searchString);
    final products = fdcWordResponse.foods
        .map((food) => MealEntity.fromFDCFood(food))
        .toList();
    return products;
  }

  Future<List<MealEntity>> getSupabaseFDCFoodsByString(
      String searchString) async {
    final spFdcWordResponse =
        await _spBackendDataSource.fetchSearchWordResults(searchString);
    final products = spFdcWordResponse
        .map((foodItem) => MealEntity.fromSpFDCFood(foodItem))
        .toList();
    return products;
  }

  Future<MealEntity> getOFFProductByBarcode(String barcode) async {
    final productResponse = await _offDataSource.fetchBarcodeResults(barcode);

    return MealEntity.fromOFFProduct(productResponse.product);
  }

  Future<List<MealEntity>> getSearchFoodByText(String text) async {
    final response = await _searchFoodDataSource.getNutriInfoFromText(text);
    return response.items
        .map((searchFoodItem) => MealEntity.fromSearchFoodItem(searchFoodItem))
        .toList();
  }

  Future<List<MealEntity>> getSearchFoodByImage({
    required String base64Image,
    String mimeType = 'image/jpeg',
  }) async {
    final response = await _searchFoodDataSource.estimateCaloriesFromImage(
      base64Image: base64Image,
      mimeType: mimeType,
    );

    return response.items
        .map((searchFoodItem) => MealEntity.fromSearchFoodItem(searchFoodItem))
        .toList();
  }
}
