import 'package:equatable/equatable.dart';

import '../utils/app_enums.dart';

class Media extends Equatable {
  final int id;
  final String url;
  final MediaType type;

  const Media({required this.id, required this.url, required this.type});

  @override
  List<Object?> get props => [id, type, url];
}
