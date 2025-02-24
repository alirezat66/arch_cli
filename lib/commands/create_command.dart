import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:mustache_template/mustache.dart';
import 'package:mvvm_cli/model/file_model.dart';
import 'package:mvvm_cli/utils/logger.dart';

class CreateCommand extends Command<int> {
  @override
  final String description = 'Create a new MVVM project structure';

  @override
  final String name = 'create';

  List<Directory> _directories = [];
  final List<FileModel> _fileModels = [];

  List<Directory> get directories => _directories;
  List<FileModel> get fileModels => _fileModels;

  @override
  Future<int> run() async {
    try {
      logger.info('Create command executed!');
      logger.space(1);

      final String projectName;
      final args = argResults?.rest ?? [];

      if (args.isEmpty) {
        logger.info(
            'Project name is required. In the following prompt, enter name of the project.');

        final result = logger.promptWithValidation(
          message: 'Enter project name:',
          validator: (input) {
            if (input.trim().isEmpty) {
              return 'Project name cannot be empty';
            }
            if (input.contains(' ')) {
              return 'Project name cannot contain spaces';
            }
            return null;
          },
        );

        projectName = result;
      } else {
        projectName = args[0];
      }

      final projectDir = Directory(projectName);
      if (projectDir.existsSync()) {
        logger.err('Error: Directory "$projectName" already exists.');
        return ExitCode.ioError.code;
      }

      projectDir.createSync();

      logger.space(2);

      logger.info('Provided project name: $projectName');

      const httpClientOptions = ['http', 'dio'];
      final networkingLib = logger.chooseOne<String>(
        'Select networking library',
        choices: httpClientOptions,
        defaultValue: 'http',
      );

      _directories = [
        Directory('$projectName/lib/core/network'),
        Directory('$projectName/lib/core/di'),
        Directory('$projectName/lib/core'),
        Directory('$projectName/lib')
      ];

      _fileModels.add(_generateYaml(projectName, networkingLib));
      _fileModels.add(_generateConsts(projectName));
      _fileModels.addAll(_generateNetworks(projectName, networkingLib));
      _fileModels.add(_generateMain(projectName));

      // Create directories
      for (final directory in directories) {
        try {
          directory.createSync(recursive: true);
          logger.info('Created directory: ${directory.path}');
        } catch (e) {
          logger.err('Failed to create directory ${directory.path}: $e');
          return ExitCode.ioError.code;
        }
      }

      // Generate files
      for (final file in fileModels) {
        if (!_generateFile(file)) {
          return ExitCode.ioError.code;
        }
      }

      logger.info('Project created successfully!');
      return ExitCode.success.code;
    } catch (e) {
      logger.err('Error creating project: $e');
      return ExitCode.software.code;
    }
  }

  bool _generateFile(FileModel fileModel) {
    try {
      final templateFile = File(fileModel.templatePath);
      if (!templateFile.existsSync()) {
        logger.err('Template file not found: ${fileModel.templatePath}');
        return false;
      }
      final templateContent = templateFile.readAsStringSync();
      final template = Template(templateContent, htmlEscapeValues: false);
      final output = template.renderString(fileModel.parameters);
      File(fileModel.destinationPath)
        ..createSync(recursive: true)
        ..writeAsStringSync(output);
      return true;
    } catch (e) {
      logger.err('Error generating file ${fileModel.destinationPath}: $e');
      return false;
    }
  }

  FileModel _generateYaml(String projectName, String networkingLib) {
    final data = {
      'projectName': projectName,
      'networkingDependency': networkingLib == 'dio'
          ? 'dio: ^4.0.0\n  pretty_dio_logger: ^1.4.0'
          : 'http: ^1.3.0',
    };
    return FileModel(
        templatePath: 'templates/pubspec.yaml.mustache',
        destinationPath: '$projectName/pubspec.yaml',
        parameters: data);
  }

  FileModel _generateConsts(String projectName) {
    return FileModel(
        templatePath: 'templates/core/constants.dart.mustache',
        destinationPath: '$projectName/lib/core/constants.dart',
        parameters: {'projectName': projectName});
  }

  Iterable<FileModel> _generateNetworks(
      String projectName, String networkingLib) {
    final networkAbstractionTemplate =
        'templates/core/network/api_client.dart.mustache';
    final networkTemplate = networkingLib == 'dio'
        ? 'templates/core/network/dio_api_client.dart.mustache'
        : 'templates/core/network/dio_api_client.dart.mustache';

    return [
      FileModel(
          templatePath: networkAbstractionTemplate,
          destinationPath: '$projectName/lib/core/network/api_client.dart'),
      FileModel(
          templatePath: networkTemplate,
          destinationPath: '$projectName/lib/core/network/network_client.dart')
    ];
  }

  FileModel _generateMain(String projectName) {
    return FileModel(
        templatePath: 'templates/main.dart.mustache',
        destinationPath: '$projectName/lib/main.dart',
        parameters: {'projectName': projectName});
  }
}
