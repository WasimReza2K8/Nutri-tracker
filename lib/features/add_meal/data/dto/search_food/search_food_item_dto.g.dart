// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_food_item_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchFoodItemDTO _$SearchFoodItemDTOFromJson(Map<String, dynamic> json) =>
    SearchFoodItemDTO(
      foodName: json['foodName'] as String,
      calories: SearchFoodItemDTO._toDouble(json['calories']),
      proteinG: SearchFoodItemDTO._toDouble(json['protein_g']),
      carbsG: SearchFoodItemDTO._toDouble(json['carbs_g']),
      fatG: SearchFoodItemDTO._toDouble(json['fat_g']),
      quantityG: SearchFoodItemDTO._toDouble(json['quantity_g']),
    );

Map<String, dynamic> _$SearchFoodItemDTOToJson(SearchFoodItemDTO instance) =>
    <String, dynamic>{
      'foodName': instance.foodName,
      'calories': instance.calories,
      'protein_g': instance.proteinG,
      'carbs_g': instance.carbsG,
      'fat_g': instance.fatG,
      'quantity_g': instance.quantityG,
    };
