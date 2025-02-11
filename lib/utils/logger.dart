import 'package:mason_logger/mason_logger.dart';

final Logger logger = Logger(
  level: Level.verbose,
);

extension LoggerExt on Logger {
  /// Prompts the user for input with built-in validation.
  ///
  /// Keeps asking for input until the validation passes.
  ///
  /// Example:
  /// ```dart
  /// final name = logger.promptWithValidation(
  ///   message: 'Enter your name',
  ///   validator: (input) => input.isEmpty ? 'Name cannot be empty' : null,
  /// );
  /// ```
  String promptWithValidation({
    String message = 'input',
    required String? Function(String p1) validator,
    Object? defaultValue,
  }) {
    while (true) {
      final result = prompt(message, defaultValue: defaultValue);

      final validatorError = validator(result);

      if (validatorError == null) {
        return result;
      }

      logger.err(validatorError);
    }
  }
}
