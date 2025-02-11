import 'dart:io';

// Import your command-related classes.

import 'package:mvvm_cli/commands/command_runner.dart';

Future<void> main(List<String> arguments) async {
  final runner = CliCommandRunner();
  
  final exitCode = await runner.run(arguments);
  
  exit(exitCode);
}
