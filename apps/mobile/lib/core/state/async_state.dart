enum Status { initial, loading, success, empty, error }

class AsyncState<T> {
  final Status status;
  final T? data;
  final String? errorMessage;
  final bool isRefreshing;

  const AsyncState({
    this.status = Status.initial,
    this.data,
    this.errorMessage,
    this.isRefreshing = false,
  });

  bool get isInitial => status == Status.initial;
  bool get isLoading => status == Status.loading;
  bool get isSuccess => status == Status.success;
  bool get isEmpty => status == Status.empty;
  bool get isError => status == Status.error;

  AsyncState<T> copyWith({
    Status? status,
    T? data,
    String? errorMessage,
    bool? isRefreshing,
  }) {
    return AsyncState<T>(
      status: status ?? this.status,
      data: data ?? this.data,
      errorMessage: errorMessage ?? this.errorMessage,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}
