class AppError implements Exception {
  const AppError({required this.kind, required this.message, this.details});

  factory AppError.from(Object error) {
    if (error is AppError) {
      return error;
    }
    if (error is AppConfigurationException) {
      return AppError(
        kind: AppErrorKind.configuration,
        message: error.message,
        details: null,
      );
    }
    if (error is AppBootstrapException) {
      return AppError(
        kind: AppErrorKind.bootstrap,
        message: error.message,
        details: error.details,
      );
    }
    return const AppError(
      kind: AppErrorKind.unknown,
      message: 'unexpected_start_error',
    );
  }

  final AppErrorKind kind;
  final String message;
  final String? details;
}

enum AppErrorKind { configuration, bootstrap, unknown }

class AppConfigurationException implements Exception {
  const AppConfigurationException(this.message);

  final String message;
}

class AppBootstrapException implements Exception {
  const AppBootstrapException(this.message, {this.details});

  final String message;
  final String? details;
}
