import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:arch_cli/commands/create_command.dart';
import 'package:arch_cli/utils/logger.dart';

class CliCommandRunner extends CommandRunner<int> {
  CliCommandRunner()
      : super('mvvm_cli', 'CLI tool for generating MVVM project structure') {
    // Add your flags like this
    argParser.addFlag(
      'verbose',
      abbr: 'v',
      help: 'Print verbose output.',
      negatable: false,
    );

    // add your commands like this
    addCommand(CreateCommand());
  }

  /// We override the [run] method only to handle verbose mode.
  @override
  Future<int> run(Iterable<String> args) async {
    try {
      final argResults = parse(args);

      if (argResults['verbose'] == true) {
        logger.level = Level.verbose;

        logger.detail('Verbose mode enabled');
      }

      return await super.run(args) ?? ExitCode.success.code;
    } catch (e, st) {
      logger.err(e.toString());
      logger.detail(st.toString());
      return ExitCode.software.code;
    }
  }
}
