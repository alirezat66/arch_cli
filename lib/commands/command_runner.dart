import 'dart:io';

import 'package:mustache_template/mustache.dart';
import 'package:mvvm_cli/commands/command.dart';
import 'package:mvvm_cli/model/file_model.dart';
import 'package:mvvm_cli/utils/logger.dart';
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
        logger.info('Created directory: ${directory.path}');
      } catch (e) {
        logger.info('Failed to create directory ${directory.path}: $e');
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
    logger.detail('Current working directory: ${Directory.current.path}');
    logger.detail('Script path: ${Platform.script.toFilePath()}');
    logger.detail("this is path:");
    logger.detail(file.templatePath);
    final templateFile = File(file.templatePath);
    if (!templateFile.existsSync()) {
      logger.err('Template file not found: ${file.templatePath}');
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
