import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:mustache_template/mustache.dart';
import 'package:arch_cli/model/file_model.dart';
import 'package:arch_cli/utils/logger.dart';

class CreateCommand extends Command<int> {
  @override
  final String description = 'Create a new flutter project structure';

  @override
  final String name = 'create';

  @override
  Future<int> run() async {
    try {
      logger.info('Creating a new Flutter MVVM project...');
      logger.space(1);

      final args = argResults?.rest ?? [];

      String projectName = args.isNotEmpty ? args[0] : _promptForProjectName();

      final projectDir = Directory(projectName);
      if (projectDir.existsSync()) {
        logger.err('Error: Directory "$projectName" already exists.');
        return ExitCode.ioError.code;
      }
      // Step 1: Run `flutter create projectName`
      if (!_createFlutterProject(projectName)) {
        return ExitCode.software.code;
      }

      // Step 2: Ask user for networking library
      final networkingLib = _promptForNetworkingLibrary();

      // Step 3: Add basic directories
      _addBasicDirectories(projectName);

      // Step 4: Modify necessary files using templates
      _generateBasicFiles(projectName, networkingLib);


      logger.info('Project created successfully!');
      return ExitCode.success.code;
    } catch (e) {
      logger.err('Error creating project: $e');
      return ExitCode.software.code;
    }
  }

  /// Runs `flutter create projectName`
  bool _createFlutterProject(String projectName) {
    try {
      final result = Process.runSync('flutter', ['create', projectName]);
      if (result.exitCode != 0) {
        logger.err('Failed to create Flutter project: ${result.stderr}');
        return false;
      }
      logger.info('Flutter project created successfully.');
      return true;
    } catch (e) {
      logger.err('Error running flutter create: $e');
      return false;
    }
  }

  String _promptForNetworkingLibrary() {
    return logger.chooseOne<String>(
      'Select networking library',
      choices: ['http', 'dio'],
      defaultValue: 'http',
    );
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
          ? 'dio: ^5.8.0+1\n  pretty_dio_logger: ^1.4.0'
          : 'http: ^1.3.0',
    };
    return FileModel(
        templatePath: 'templates/basics/pubspec.yaml.mustache',
        destinationPath: '$projectName/pubspec.yaml',
        parameters: data);
  }

  FileModel _generateConsts(String projectName) {
    return FileModel(
        templatePath: 'templates/core/app_constants.dart.mustache',
        destinationPath: '$projectName/lib/core/constants/app_constants.dart',
        parameters: {'projectName': projectName});
  }

  Iterable<FileModel> _generateNetworks(
      String projectName, String networkingLib) {
    final networkAbstractionTemplate =
        'templates/core/network/api_client.dart.mustache';
    final networkTemplate = networkingLib == 'dio'
        ? 'templates/core/network/dio_api_client.dart.mustache'
        : 'templates/core/network/dio_api_client.dart.mustache';
    final String responseTemplate =
        'templates/core/network/network_response.dart.mustache';
    return [
      FileModel(
          templatePath: networkAbstractionTemplate,
          destinationPath: '$projectName/lib/core/network/api_client.dart'),
      FileModel(
          templatePath: networkTemplate,
          destinationPath: '$projectName/lib/core/network/network_client.dart'),
      FileModel(
          templatePath: responseTemplate,
          destinationPath:
              '$projectName/lib/core/network/network_response.dart')
    ];
  }

  FileModel _generateMain(String projectName) {
    return FileModel(
        templatePath: 'templates/main.dart.mustache',
        destinationPath: '$projectName/lib/main.dart',
        parameters: {'projectName': projectName});
  }

  String _promptForProjectName() {
    return logger.promptWithValidation(
      message: 'Enter project name:',
      validator: (input) {
        if (input.trim().isEmpty) return 'Project name cannot be empty';
        if (input.contains(' ')) return 'Project name cannot contain spaces';
        return null;
      },
    );
  }

  void _addBasicDirectories(String projectName) {
    final directories = [
      '$projectName/lib/core',
      '$projectName/lib/core/network',
      '$projectName/lib/core/di',
      '$projectName/lib/data',
      '$projectName/lib/domain',
      '$projectName/lib/presentation',
      '$projectName/lib/utils',
    ];

    for (final dirPath in directories) {
      final dir = Directory(dirPath);
      dir.createSync(recursive: true);
      logger.info('Created folder: $dirPath');
    }
  }

  void _generateBasicFiles(String projectName, String networkingLib) {
    final fileModels = [
      _generateYaml(projectName, networkingLib),
      _generateConsts(projectName),
      _generateMain(projectName),
      ..._generateNetworks(projectName, networkingLib),
    ];

    for (final file in fileModels) {
      _generateFile(file);
    }
  }
}
