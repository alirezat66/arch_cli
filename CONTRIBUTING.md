# Contributing to Arch CLI

Thank you for your interest in contributing to Arch CLI! This document will guide you through the project architecture and how to add new features.

## Table of Contents

- [Project Overview](#project-overview)
- [Architecture](#architecture)
- [Development Setup](#development-setup)
- [Adding New Commands](#adding-new-commands)
- [Adding New Templates](#adding-new-templates)
- [Testing](#testing)
- [Code Style](#code-style)
- [Pull Request Process](#pull-request-process)

## Project Overview

Arch CLI is a Flutter project generator that creates MVVM-structured applications. It's built using Dart and follows a modular, extensible architecture that makes it easy to add new features and commands.

## Architecture

### Core Components

```
lib/
├── commands/           # CLI command implementations
│   ├── command_runner.dart    # Main command orchestrator
│   └── create_command.dart    # Project creation logic
├── model/             # Data models
│   └── file_model.dart        # Template file generation model
├── utils/             # Utility functions
│   └── logger.dart            # Logging utilities
└── templates/         # Mustache templates for file generation
    ├── basics/        # Basic project files
    ├── core/          # Core architecture files
    └── main.dart.mustache     # Main app template
```

### Command System

The CLI uses the `args` package for command-line argument parsing and follows a hierarchical command structure:

- **CliCommandRunner**: Main entry point that manages all commands
- **CreateCommand**: Handles project creation with interactive prompts
- **Extensible**: New commands can be easily added

### Template System

Templates use Mustache syntax and are processed through the `FileModel` class:

```dart
class FileModel {
  final String templatePath;      // Path to template file
  final String destinationPath;   // Where to generate the file
  final Map<String, dynamic> parameters; // Template variables
}
```

### File Generation Flow

1. **Template Selection**: Choose appropriate template based on requirements
2. **Parameter Binding**: Bind dynamic values (project name, dependencies, etc.)
3. **File Creation**: Generate files with proper directory structure
4. **Error Handling**: Graceful fallbacks for missing templates or permissions

## Development Setup

### Prerequisites

- Dart SDK (^3.5.4)
- Flutter SDK (^3.5.4)
- Git

### Local Development

```bash
# Clone the repository
git clone <repository-url>
cd arch_cli

# Install dependencies
dart pub get

# Run tests
dart test

# Build and test the CLI locally
dart compile exe bin/arch_cli.dart -o arch_cli
./arch_cli --help
```


## Adding New Commands

### 1. Create Command Class

Create a new file in `lib/commands/` following this pattern:

```dart
import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:arch_cli/utils/logger.dart';

class NewFeatureCommand extends Command<int> {
  @override
  final String description = 'Description of what this command does';

  @override
  final String name = 'new-feature';

  @override
  Future<int> run() async {
    try {
      logger.info('Starting new feature...');
      
      // Your command logic here
      
      logger.info('Feature completed successfully!');
      return ExitCode.success.code;
    } catch (e) {
      logger.err('Error: $e');
      return ExitCode.software.code;
    }
  }
}
```

### 2. Register Command

Add your command to `CliCommandRunner` in `lib/commands/command_runner.dart`:

```dart
class CliCommandRunner extends CommandRunner<int> {
  CliCommandRunner()
      : super('arch_cli', 'CLI tool for generating MVVM project structure') {
    // ... existing commands ...
    addCommand(NewFeatureCommand());
  }
}
```

### 3. Add Arguments/Flags

Use the `argParser` to add command-specific options:

```dart
class NewFeatureCommand extends Command<int> {
  NewFeatureCommand() {
    argParser.addOption(
      'output',
      abbr: 'o',
      help: 'Output directory for generated files',
      defaultsTo: 'output',
    );
    
    argParser.addFlag(
      'force',
      abbr: 'f',
      help: 'Overwrite existing files',
      negatable: false,
    );
  }
  
  @override
  Future<int> run() async {
    final outputDir = argResults?['output'] as String;
    final force = argResults?['force'] as bool;
    
    // Use the arguments in your logic
  }
}
```

## Adding New Templates

### 1. Create Template File

Add your Mustache template to the appropriate directory in `templates/`:

```dart
// templates/core/services/api_service.dart.mustache
import 'package:{{projectName}}/core/network/api_client.dart';

class ApiService {
  final ApiClient _client;
  
  ApiService(this._client);
  
  Future<NetworkResponse<T>> get<T>(String endpoint) async {
    return await _client.get(endpoint);
  }
}
```

### 2. Update File Generation Logic

Modify the command that uses this template to include it in the generation process:

```dart
FileModel _generateApiService(String projectName) {
  return FileModel(
    templatePath: 'templates/core/services/api_service.dart.mustache',
    destinationPath: '$projectName/lib/core/services/api_service.dart',
    parameters: {'projectName': projectName},
  );
}

// Add to your file generation list
final fileModels = [
  // ... existing files ...
  _generateApiService(projectName),
];
```

### 3. Template Variables

Common template variables you can use:

- `{{projectName}}`: The name of the project
- `{{networkingDependency}}`: Selected networking library
- `{{authorName}}`: Developer name (if collected)
- `{{packageName}}`: Flutter package identifier


### Test Structure

- **Unit Tests**: Test individual functions and classes
- **Integration Tests**: Test command execution end-to-end
- **Template Tests**: Verify template rendering with various parameters

## Code Style

### Dart Standards

- Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use `dart format` to format code
- Run `dart analyze` to check for issues

### Project-Specific Conventions

- **Commands**: Use kebab-case for command names (`new-feature`)
- **Classes**: Use PascalCase (`NewFeatureCommand`)
- **Files**: Use snake_case (`new_feature_command.dart`)
- **Constants**: Use SCREAMING_SNAKE_CASE

### Error Handling

- Always wrap command execution in try-catch blocks
- Return appropriate `ExitCode` values
- Use the logger for all output (info, error, warning)
- Provide helpful error messages

## Pull Request Process

### 1. Create Feature Branch

```bash
git checkout -b feature/new-command-name
```

### 2. Make Changes

- Implement your feature
- Add tests
- Update documentation
- Follow code style guidelines

### 3. Test Your Changes

```bash
# Test CLI locally
dart compile exe bin/arch_cli.dart -o arch_cli
./arch_cli --help
./arch_cli your-new-command --help
```

### 4. Commit and Push

```bash
git add .
git commit -m "feat: add new command for feature X"
git push origin feature/new-command-name
```

### 5. Create Pull Request

- Provide clear description of changes
- Include any breaking changes
- Reference related issues
- Request review from maintainers

### Commit Message Format

Use conventional commit format:

- `feat:` New features
- `fix:` Bug fixes
- `docs:` Documentation changes
- `style:` Code style changes
- `refactor:` Code refactoring
- `test:` Test additions/changes

## Common Patterns

### Interactive Prompts

```dart
String projectName = logger.promptWithValidation(
  message: 'Enter project name:',
  validator: (input) {
    if (input.trim().isEmpty) return 'Project name cannot be empty';
    if (input.contains(' ')) return 'Project name cannot contain spaces';
    return null;
  },
);
```

### Choice Selection

```dart
String choice = logger.chooseOne<String>(
  'Select an option',
  choices: ['option1', 'option2', 'option3'],
  defaultValue: 'option1',
);
```

### File Operations

```dart
// Create directories
final dir = Directory(path);
dir.createSync(recursive: true);

// Generate files from templates
final template = Template(templateContent);
final output = template.renderString(parameters);
File(destinationPath).writeAsStringSync(output);
```

## Getting Help

- **Issues**: Check existing issues for similar problems
- **Discussions**: Join project discussions
- **Documentation**: Review this guide and USAGE.md
- **Code**: Examine existing commands for examples

## Thank You

Your contributions help make Arch CLI better for everyone. Whether it's fixing bugs, adding features, or improving documentation, every contribution is valuable!
