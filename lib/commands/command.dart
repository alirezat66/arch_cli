import 'dart:io';

import 'package:mvvm_cli/model/file_model.dart';

abstract class Command {
  /// The name of the command, e.g. 'create'
  String get name;

  List<FileModel> get fileModels;

  List<Directory> get directories;

  /// Executes the command with the provided arguments.
  Future<void> execute(List<String> args);
}
