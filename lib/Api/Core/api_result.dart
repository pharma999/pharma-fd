/// Wrapper class for API responses - improves error handling and type safety
abstract class ApiResult<T> {
  const ApiResult();

  R when<R>({
    required R Function(T data) onSuccess,
    required R Function(String error) onError,
  });

  R? whenOrNull<R>({
    R Function(T data)? onSuccess,
    R Function(String error)? onError,
  });
}

class Success<T> extends ApiResult<T> {
  final T data;

  const Success(this.data);

  @override
  R when<R>({
    required R Function(T data) onSuccess,
    required R Function(String error) onError,
  }) => onSuccess(data);

  @override
  R? whenOrNull<R>({
    R Function(T data)? onSuccess,
    R Function(String error)? onError,
  }) => onSuccess?.call(data);
}

class Error<T> extends ApiResult<T> {
  final String message;

  const Error(this.message);

  @override
  R when<R>({
    required R Function(T data) onSuccess,
    required R Function(String error) onError,
  }) => onError(message);

  @override
  R? whenOrNull<R>({
    R Function(T data)? onSuccess,
    R Function(String error)? onError,
  }) => onError?.call(message);
}
