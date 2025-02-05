import 'dart:io';
import 'package:mustache_template/mustache.dart';
import 'package:mvvm_cli/model/file_model.dart';

import 'command.dart';

class CreateCommand implements Command {
  @override
  String get name => 'create';

  List<Directory> _dictionaries = [];

  final List<FileModel> _fileModels = [];
  @override
  List<Directory> get directories => _dictionaries;

  @override
  List<FileModel> get fileModels => _fileModels;

  @override
  Future<void> execute(List<String> args) async {
    if (args.isEmpty) {
      print('Please provide a project name.');
      exit(1);
    }

    final projectName = args.first;
    // Prompt for networking choice:
    stdout.write('Select networking library (1 = http, 2 = dio): ');
    final choice = stdin.readLineSync();
    String networkingLib;
    if (choice == '1') {
      networkingLib = 'http';
    } else if (choice == '2') {
      networkingLib = 'dio';
    } else {
      print('Invalid choice, defaulting to http.');
      networkingLib = 'http';
    }
    _dictionaries = [
      Directory('$projectName/lib/core/network'),
      Directory('$projectName/lib/core/di'),
      Directory('$projectName/lib/core'),
      Directory('$projectName/lib')
    ];
    _fileModels.add(_generateYaml(projectName, networkingLib));
    _fileModels.add(_generateConsts(projectName));
    _fileModels.addAll(_generateNetworks(projectName, networkingLib));
    _fileModels.add(_generateMain(projectName));
    
    final projectDir = Directory(projectName);
    if (projectDir.existsSync()) {
      print('Error: Directory "$projectName" already exists.');
      exit(1);
    }
    projectDir.createSync();
    run(args);
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

  void run(List<String> args) {
    // Execute the command-specific logic first.

    // Now perform the common finalization steps.

    // 1. Create all directories recursively.
    for (final directory in directories) {
      try {
        directory.createSync(recursive: true);
        print('Created directory: ${directory.path}');
      } catch (e) {
        print('Failed to create directory ${directory.path}: $e');
      }
    }

    // 2. Generate files from the file models.
    for (final file in fileModels) {
      generateFile(file);
    }
  }

  static void generateFile(FileModel fileModel) {
    final templateFile = File(fileModel.templatePath);
    if (!templateFile.existsSync()) {
      print('Template file not found: $fileModel.templatePath');
      return;
    }
    final templateContent = templateFile.readAsStringSync();
    final template = Template(templateContent, htmlEscapeValues: false);
    final output = template.renderString(fileModel.parameters);
    File(fileModel.destinationPath)
      ..createSync(recursive: true)
      ..writeAsStringSync(output);
  }
}
