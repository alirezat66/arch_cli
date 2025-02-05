import 'dart:io';

import 'package:mustache_template/mustache.dart';
import 'package:mvvm_cli/commands/command.dart';
import 'package:mvvm_cli/model/file_model.dart';
import 'package:path/path.dart' as p;

class CommandRunner {
  final Command command;

  CommandRunner(this.command);

  Future<void> run(List<String> args) async {
    // Execute the command-specific logic first.
    await command.execute(args);

    // Now perform the common finalization steps.

    // 1. Create all directories recursively.
    for (final directory in command.directories) {
      try {
        directory.createSync(recursive: true);
        print('Created directory: ${directory.path}');
      } catch (e) {
        print('Failed to create directory ${directory.path}: $e');
      }
    }

    // 2. Generate files from the file models.
    for (final file in command.fileModels) {
      generateFile(file);
    }
  }

  String getTemplateAbsolutePath(String filename) {
    final scriptDir = p.dirname(Platform.script.toFilePath());
    // e.g., if your templates are in lib/templates relative to mvvm_cli.dart:
    return p.join(scriptDir, 'templates', filename);
  }

  void generateFile(FileModel file) {
    print('Current working directory: ${Directory.current.path}');
    print('Script path: ${Platform.script.toFilePath()}');
    print("this is path:");
    print(file.templatePath);
    final templateFile = File(file.templatePath);
    if (!templateFile.existsSync()) {
      print('Template file not found: ${file.templatePath}');
      return;
    }
    final templateContent = templateFile.readAsStringSync();
    final template = Template(templateContent, htmlEscapeValues: false);
    final output = template.renderString(file.parameters);
    File(file.destinationPath)
      ..createSync(recursive: true)
      ..writeAsStringSync(output);
  }
}

void generateFile(
    String templatePath, String outputPath, Map<String, String> data) {}
