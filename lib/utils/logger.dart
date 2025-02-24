import 'package:mason_logger/mason_logger.dart';

final Logger logger = Logger(
  level: Level.info,
);

extension LoggerExt on Logger {
  /// Adds empty lines to the log output for better readability.
  ///
  /// Example:
  /// ```dart
  /// logger.space(); // adds 1 empty line
  /// logger.space(3); // adds 3 empty lines
  /// ```
  /// 
  /// [lines] The number of empty lines to add. Defaults to 1.
  void space([int lines = 1]) {
    for (var i = 0; i < lines; i++) {
      info('');
    }
  }

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
