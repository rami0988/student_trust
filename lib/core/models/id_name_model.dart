import 'package:json_annotation/json_annotation.dart';

import '../entities/id_name.dart';

part 'id_name_model.g.dart';

@JsonSerializable(checked: true, createToJson: false)
class IdNameModel {
  @JsonKey(name: "id")
  final int id;
  @JsonKey(name: "name")
  final String name;

  IdNameModel({required this.id, required this.name});

  factory IdNameModel.fromJson(Map<String, dynamic> json) => _$IdNameModelFromJson(json);

  IdName toDomain() => IdName(id: id, name: name);
}
