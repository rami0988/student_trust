import 'package:equatable/equatable.dart';

class IdName extends Equatable {
  final int id;
  final String name;

  const IdName({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}
