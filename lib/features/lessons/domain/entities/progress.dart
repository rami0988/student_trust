import 'package:equatable/equatable.dart';

class Progress extends Equatable {
  final int positionSeconds;
  final bool isCompleted;

  const Progress({this.positionSeconds = 0, this.isCompleted = false});

  @override
  List<Object?> get props => [positionSeconds, isCompleted];
}
