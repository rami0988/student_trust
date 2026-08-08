import '../../generated/l10n.dart';

abstract class GenericExceptions implements Exception {
  final String? exceptionMessage;
  final int? exceptionCode;

  const GenericExceptions(this.exceptionMessage, this.exceptionCode);
}

class ServerException extends GenericExceptions {
  ServerException(super.exceptionMessage, super.exceptionCode);

  @override
  String toString() {
    return 'ServerException{exceptionMessage: $exceptionMessage, exceptionCode: $exceptionCode}';
  }
}

class CacheException extends GenericExceptions {
  CacheException(
    String? exceptionMessage,
  ) : super(exceptionMessage, 404);

  @override
  String toString() {
    return 'CacheException{exceptionMessage: $exceptionMessage, exceptionCode: $exceptionCode}';
  }
}

class GeneralException extends GenericExceptions {
  GeneralException() : super(S.current.oopsSomethingWentWrongPleaseTryAgain, 404);

  @override
  String toString() {
    return 'GeneralException{exceptionMessage: $exceptionMessage, exceptionCode: $exceptionCode}';
  }
}

class NetworkException extends GenericExceptions {
  NetworkException(String? exceptionMessage) : super(exceptionMessage, 400);

  @override
  String toString() {
    return 'NetworkException{exceptionMessage: $exceptionMessage, exceptionCode: $exceptionCode}';
  }
}

class ParsingJsonException extends GenericExceptions {
  final String? className;

  ParsingJsonException(this.className, String? exceptionMessage) : super(exceptionMessage, null);

  @override
  String toString() {
    return 'ParsingJsonException{className: $className, exceptionMessage: $exceptionMessage, exceptionCode: $exceptionCode}';
  }
}
