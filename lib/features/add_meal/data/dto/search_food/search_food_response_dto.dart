import 'package:json_annotation/json_annotation.dart';
import 'package:opennutritracker/features/add_meal/data/dto/search_food/search_food_item_dto.dart';

part 'search_food_response_dto.g.dart';

@JsonSerializable()
class SearchFoodResponseDTO {
  final List<SearchFoodItemDTO> items;

  SearchFoodResponseDTO({required this.items});

  factory SearchFoodResponseDTO.fromJson(Map<String, dynamic> json) =>
      _$SearchFoodResponseDTOFromJson(json);

  Map<String, dynamic> toJson() => _$SearchFoodResponseDTOToJson(this);
}
