class FileModel {
  final String templatePath;
  final String destinationPath;
  final Map<String, String> parameters;
  FileModel(
      {required this.templatePath,
      required this.destinationPath,
      this.parameters = const {}});
}
