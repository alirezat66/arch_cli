import 'dart:io';
import 'package:args/args.dart';

// Import your command-related classes.

import 'package:mvvm_cli/commands/command_runner.dart';
import 'package:mvvm_cli/commands/create_command.dart';
import 'package:mvvm_cli/utils/logger.dart';

Future<void> main(List<String> arguments) async {
  // Step 1: Set up the argument parser.
  final parser = ArgParser();
  parser.addCommand('create');

  // Step 2: Parse the provided arguments.
  ArgResults argResults;
  try {
    argResults = parser.parse(arguments);
  } on FormatException catch (e) {
    logger.err('Error parsing arguments: ${e.message}');
    exit(1);
  }

  // Step 3: Ensure a command is provided.
  if (argResults.command == null) {
    logger.err('No command provided.');
    logger.err('Usage: mvvm_cli <command> [arguments]');
    exit(1);
  }

  // Step 4: Handle the "create" command.
  if (argResults.command!.name == 'create') {
    // Create an instance of your CreateCommand.
    final command = CreateCommand();

    // Wrap the command with the CommandRunner which will
    // call the command's execute method and then perform the common finalization
    // (creating directories and generating files).

    final runner = CommandRunner(command);
    await runner.run(argResults.command!.rest);
  } else {
    logger.err('Unknown command: ${argResults.command!.name}');
    logger.err('Usage: mvvm_cli <command> [arguments]');
    exit(1);
  }
}
