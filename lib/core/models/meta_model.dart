import 'package:json_annotation/json_annotation.dart';

part 'meta_model.g.dart';

@JsonSerializable(checked: true, explicitToJson: true)
class MetaModel {
  @JsonKey(name: "current_page")
  final int? currentPage;
  @JsonKey(name: "first_page_url")
  final String? firstPageUrl;
  @JsonKey(name: "from")
  final int? from;
  @JsonKey(name: "last_page", defaultValue: 1)
  final int lastPage;
  @JsonKey(name: "last_page_url")
  final String? lastPageUrl;
  @JsonKey(name: "next_page_url")
  final dynamic nextPageUrl;
  @JsonKey(name: "path")
  final String? path;
  @JsonKey(name: "per_page")
  final int? perPage;
  @JsonKey(name: "prev_page_url")
  final dynamic prevPageUrl;
  @JsonKey(name: "to")
  final int? to;
  @JsonKey(name: "total")
  final int? total;

  MetaModel({
    this.currentPage,
    this.firstPageUrl,
    this.from,
    required this.lastPage,
    this.lastPageUrl,
    this.nextPageUrl,
    this.path,
    this.perPage,
    this.prevPageUrl,
    this.to,
    this.total,
  });

  factory MetaModel.fromJson(Map<String, dynamic> json) => _$MetaModelFromJson(json);

  Map<String, dynamic> toJson() => _$MetaModelToJson(this);
}

int lastPageFromJson(Map<String, dynamic> json) {
  return json['last_page'] as int? ?? 1;
}
