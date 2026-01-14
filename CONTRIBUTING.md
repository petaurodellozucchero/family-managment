# Contributing to Family Management App

Thank you for your interest in contributing to the Family Management App! This document provides guidelines and instructions for contributing.

## Code of Conduct

- Be respectful and inclusive
- Provide constructive feedback
- Focus on what's best for the project
- Show empathy towards other contributors

## How to Contribute

### Reporting Bugs

If you find a bug, please create an issue with:

1. **Clear title**: Describe the issue concisely
2. **Description**: Detailed explanation of the bug
3. **Steps to reproduce**: List exact steps to reproduce the issue
4. **Expected behavior**: What should happen
5. **Actual behavior**: What actually happens
6. **Screenshots**: If applicable
7. **Environment**:
   - Flutter version (`flutter --version`)
   - Device/Emulator details
   - OS version

### Suggesting Enhancements

For feature requests:

1. **Check existing issues**: Make sure it hasn't been suggested already
2. **Clear description**: Explain the feature and its benefits
3. **Use cases**: Provide examples of how it would be used
4. **Mockups**: Visual examples if applicable

### Pull Requests

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/your-feature-name`
3. **Make your changes**: Follow the coding standards below
4. **Test your changes**: Ensure everything works
5. **Commit with clear messages**: `git commit -m "Add feature: description"`
6. **Push to your fork**: `git push origin feature/your-feature-name`
7. **Create a Pull Request**: Describe your changes thoroughly

## Development Setup

1. Follow the [QUICKSTART.md](QUICKSTART.md) guide
2. Set up your development environment
3. Run the app to ensure everything works

## Coding Standards

### Dart/Flutter

- Follow the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful variable and function names
- Add comments for complex logic
- Keep functions small and focused
- Use `flutter analyze` to check for issues

### Code Formatting

```bash
# Format all Dart files
flutter format .

# Analyze code
flutter analyze
```

### File Organization

- Models in `lib/models/`
- Services in `lib/services/`
- Providers in `lib/providers/`
- Screens in `lib/screens/`
- Widgets in `lib/widgets/`

### Naming Conventions

- **Classes**: PascalCase (e.g., `EventProvider`)
- **Variables**: camelCase (e.g., `selectedDate`)
- **Constants**: camelCase or UPPER_SNAKE_CASE (e.g., `maxItems` or `MAX_ITEMS`)
- **Files**: snake_case (e.g., `event_provider.dart`)
- **Private members**: prefix with underscore (e.g., `_privateMethod`)

## Testing

### Writing Tests

- Place tests in `test/` directory
- Mirror the structure of `lib/`
- Use descriptive test names

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/models/event_model_test.dart
```

### Test Coverage

```bash
# Generate coverage report
flutter test --coverage
```

## Git Commit Messages

Follow these guidelines:

- Use present tense ("Add feature" not "Added feature")
- Use imperative mood ("Move cursor to..." not "Moves cursor to...")
- Limit first line to 72 characters
- Reference issues and pull requests when relevant

Examples:
```
Add recurring event support for monthly events
Fix shopping list item deletion bug
Update README with installation instructions
Refactor event provider for better performance
```

## Code Review Process

1. All submissions require review
2. Reviewers will check for:
   - Code quality and standards
   - Test coverage
   - Documentation
   - Performance implications
   - Security considerations
3. Address feedback promptly
4. Be open to suggestions

## Areas for Contribution

### High Priority

- [ ] Improve test coverage
- [ ] Add more unit tests for widgets
- [ ] Implement integration tests
- [ ] Add accessibility features
- [ ] Performance optimization

### Features

- [ ] Custom family member creation UI
- [ ] Event notifications/reminders
- [ ] Shopping list categories
- [ ] Export calendar to ICS format
- [ ] Photo attachments to events
- [ ] Multiple shopping lists
- [ ] Recipe integration
- [ ] Dark mode improvements

### Documentation

- [ ] Code documentation improvements
- [ ] More examples in README
- [ ] Video tutorials
- [ ] Translation to other languages

### Bug Fixes

Check the [Issues](https://github.com/petaurodellozucchero/family-managment/issues) page for known bugs.

## Questions?

If you have questions about contributing:

1. Check existing documentation
2. Search closed issues
3. Open a new issue with the "question" label

## Recognition

Contributors will be recognized in:
- README.md contributors section
- Release notes
- Project documentation

Thank you for contributing to make Family Management App better! 🎉
