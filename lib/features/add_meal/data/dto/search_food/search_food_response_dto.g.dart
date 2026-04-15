// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_food_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchFoodResponseDTO _$SearchFoodResponseDTOFromJson(
        Map<String, dynamic> json) =>
    SearchFoodResponseDTO(
      items: (json['items'] as List<dynamic>)
          .map((e) => SearchFoodItemDTO.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SearchFoodResponseDTOToJson(
        SearchFoodResponseDTO instance) =>
    <String, dynamic>{
      'items': instance.items,
    };
