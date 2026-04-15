import 'package:json_annotation/json_annotation.dart';

part 'search_food_item_dto.g.dart';

@JsonSerializable()
class SearchFoodItemDTO {
  @JsonKey(name: 'foodName')
  final String foodName;

  @JsonKey(fromJson: _toDouble)
  final double calories;

  @JsonKey(name: 'protein_g', fromJson: _toDouble)
  final double proteinG;

  @JsonKey(name: 'carbs_g', fromJson: _toDouble)
  final double carbsG;

  @JsonKey(name: 'fat_g', fromJson: _toDouble)
  final double fatG;

  @JsonKey(name: 'quantity_g', fromJson: _toDouble)
  final double quantityG;

  SearchFoodItemDTO({
    required this.foodName,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.quantityG,
  });

  factory SearchFoodItemDTO.fromJson(Map<String, dynamic> json) =>
      _$SearchFoodItemDTOFromJson(json);

  Map<String, dynamic> toJson() => _$SearchFoodItemDTOToJson(this);

  static double _toDouble(Object? value) => (value as num?)?.toDouble() ?? 0;
}
