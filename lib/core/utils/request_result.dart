import '../error/failures.dart';

abstract class RequestResult<T> {
  const RequestResult();

  R fold<R>({
    required R Function(T data) success,
    required R Function(Failure error) failure,
  }) {
    if (this is SuccessResult<T>) {
      return success((this as SuccessResult<T>).data);
    } else if (this is FailureResult<T>) {
      return failure((this as FailureResult<T>).failure);
    }
    throw Exception('Unknown subtype of RequestResult');
  }

  bool get isSuccess => this is SuccessResult<T>;
  bool get isFailure => this is FailureResult<T>;
}

class SuccessResult<T> extends RequestResult<T> {
  final T data;
  const SuccessResult(this.data);
}

class FailureResult<T> extends RequestResult<T> {
  final Failure failure;
  const FailureResult(this.failure);
}
