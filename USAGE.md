# Arch CLI - Usage Guide

## Overview

Arch CLI is a command-line tool that generates Flutter projects with a clean MVVM (Model-View-ViewModel) architecture. It automatically sets up the project structure, dependencies, and basic files to get you started quickly.

## Installation

### Prerequisites
- Flutter SDK (^3.5.4 or higher)
- Dart SDK (^3.5.4 or higher)

### Install from source
```bash
# Clone the repository
git clone <repository-url>
cd arch_cli

# Install dependencies
dart pub get

# Build the CLI
dart compile exe bin/arch_cli.dart -o arch_cli

# Make it globally accessible (optional)
sudo mv arch_cli /usr/local/bin/
```

## Basic Usage

### Create a new project
```bash
# Basic usage
arch_cli create my_project

# With verbose output
arch_cli create my_project --verbose

# Interactive mode (will prompt for project name)
arch_cli create
```

### Command Options

- `--verbose, -v`: Enable verbose logging for detailed output
- `--help, -h`: Show help information

## Generated Project Structure

When you create a new project, Arch CLI generates the following structure:

```
my_project/
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   │   └── app_constants.dart
│   │   ├── di/
│   │   │   └── di.dart
│   │   ├── extensions/
│   │   │   └── string_ext.dart
│   │   └── network/
│   │       ├── api_client.dart
│   │       ├── network_client.dart
│   │       └── network_response.dart
│   ├── data/
│   ├── domain/
│   ├── presentation/
│   ├── utils/
│   └── main.dart
├── pubspec.yaml
└── ... (other Flutter project files)
```

## Architecture Overview

### MVVM Pattern
The generated project follows the MVVM (Model-View-ViewModel) architecture:

- **Model**: Data layer in `lib/data/`
- **View**: UI components in `lib/presentation/`
- **ViewModel**: Business logic in `lib/domain/`

### Core Components

#### Network Layer
- **API Client**: Abstract interface for HTTP operations
- **Network Client**: Concrete implementation (HTTP or Dio)
- **Network Response**: Standardized response wrapper

#### Dependency Injection
- **DI Container**: Centralized dependency management
- **Service Locator**: Easy access to services throughout the app

#### Constants & Extensions
- **App Constants**: Centralized configuration values
- **String Extensions**: Utility methods for string operations

## Networking Library Selection

During project creation, you'll be prompted to choose between:

1. **HTTP**: Lightweight HTTP client (default)
2. **Dio**: Feature-rich HTTP client with interceptors

The choice affects:
- Dependencies in `pubspec.yaml`
- Network client implementation
- Available features (logging, caching, etc.)

## Customization

### Templates
All generated files use Mustache templates located in the `templates/` directory. You can:

- Modify existing templates
- Add new template files
- Customize the generation logic

### Adding New Commands
The CLI is extensible. See `CONTRIBUTING.md` for details on adding new commands.

## Examples

### Create a project with specific networking
```bash
arch_cli create my_api_app
# Select 'dio' when prompted for networking library
```

### Verbose output for debugging
```bash
arch_cli create my_project --verbose
# Shows detailed information about each step
```

## Troubleshooting

### Common Issues

1. **Directory already exists**
   - Error: "Directory 'my_project' already exists"
   - Solution: Choose a different project name or remove the existing directory

2. **Flutter not found**
   - Error: "Failed to create Flutter project"
   - Solution: Ensure Flutter is installed and in your PATH

3. **Permission denied**
   - Error: "Permission denied" when creating files
   - Solution: Check directory permissions or run with appropriate privileges

### Getting Help

- Use `--help` flag for command information
- Enable verbose mode with `--verbose` for detailed logs
- Check the project repository for issues and updates

## Next Steps

After creating your project:

1. Navigate to the project directory: `cd my_project`
2. Install dependencies: `flutter pub get`
3. Run the app: `flutter run`
4. Start building your features following the MVVM pattern

## Support

- **Documentation**: Check `CONTRIBUTING.md` for development details
- **Issues**: Report bugs or request features on the project repository
- **Community**: Join discussions in the project community
