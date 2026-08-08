import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final int? statusCode;
  final String statusMessage;

  const Failure(this.statusMessage, this.statusCode);

  @override
  List<Object?> get props => [statusCode, statusMessage];
}

class ServerFailure extends Failure {
  const ServerFailure(super.statusMessage, super.statusCode);

  @override
  String toString() {
    return 'ServerFailure{statusMessage: $statusMessage, statusCode: $statusCode}';
  }
}

class CacheFailure extends Failure {
  const CacheFailure(super.statusMessage, [super.statusCode]);

  @override
  String toString() {
    return 'CacheFailure{statusMessage: $statusMessage, statusCode: $statusCode}';
  }
}

class GeneralFailure extends Failure {
  const GeneralFailure(super.statusMessage, [super.statusCode]);

  @override
  String toString() {
    return 'GeneralFailure{statusMessage: $statusMessage, statusCode: $statusCode}';
  }
}

class ParsingJsonFailure extends Failure {
  const ParsingJsonFailure(super.statusMessage, [super.statusCode]);

  @override
  String toString() {
    return 'ParsingJsonFailure{statusMessage: $statusMessage, statusCode: $statusCode}';
  }
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.statusMessage, super.statusCode);

  @override
  String toString() {
    return 'NetworkFailure{statusMessage: $statusMessage, statusCode: $statusCode}';
  }
}

class PermissionFailure extends Failure {
  const PermissionFailure(super.statusMessage, super.statusCode);

  @override
  String toString() {
    return 'PermissionFailure{statusMessage: $statusMessage, statusCode: $statusCode}';
  }
}
