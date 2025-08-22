# Arch CLI

A powerful command-line tool for generating Flutter projects with clean MVVM (Model-View-ViewModel) architecture. Quickly scaffold your Flutter applications with best practices and a well-structured foundation.

## Features

- 🚀 **Quick Setup**: Generate complete Flutter project structure in seconds
- 🏗️ **MVVM Architecture**: Pre-configured with industry-standard patterns
- 🌐 **Flexible Networking**: Choose between HTTP and Dio for API calls
- 📁 **Smart Templates**: Mustache-based templates for easy customization
- 🔧 **Extensible**: Add new commands and templates easily

## Quick Start

```bash
# Create a new project
arch_cli create my_awesome_app

# Interactive mode
arch_cli create

# With verbose output
arch_cli create my_app --verbose
```

## Documentation

- **[USAGE.md](USAGE.md)** - Complete usage guide and examples
- **[CONTRIBUTING.md](CONTRIBUTING.md)** - Development guide for contributors

## Installation

```bash
# Clone and build from source
git clone <repository-url>
cd arch_cli
dart pub get
dart compile exe bin/arch_cli.dart -o arch_cli
```

## Project Structure

The generated projects follow a clean MVVM architecture:

```
lib/
├── core/          # Core utilities, DI, networking
├── data/          # Data layer and repositories
├── domain/        # Business logic and use cases
├── presentation/  # UI components and views
└── utils/         # Helper functions
```

## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for detailed information on:

- Project architecture
- Adding new commands
- Creating templates
- Development workflow
- Code style guidelines

## License

This project is licensed under the terms specified in the [LICENSE](LICENSE) file.
