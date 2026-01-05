# Contributing to StickyHeaderScrollView

First off, thank you for considering contributing to StickyHeaderScrollView! It's people like you that make this project better for everyone.

## Code of Conduct

This project and everyone participating in it is governed by our commitment to providing a welcoming and inclusive environment. Please be respectful and constructive in your interactions.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the existing issues to avoid duplicates. When you create a bug report, include as many details as possible:

**Bug Report Template:**
```
**Description**
A clear and concise description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Go to '...'
2. Click on '....'
3. Scroll down to '....'
4. See error

**Expected behavior**
A clear and concise description of what you expected to happen.

**Screenshots**
If applicable, add screenshots or screen recordings to help explain your problem.

**Environment:**
 - Device: [e.g. iPhone 15 Pro]
 - iOS Version: [e.g. iOS 17.2]
 - Xcode Version: [e.g. 15.0]
 - Package Version: [e.g. 1.0.0]

**Additional context**
Add any other context about the problem here.
```

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, include:

- **Use a clear and descriptive title**
- **Provide a detailed description** of the suggested enhancement
- **Explain why this enhancement would be useful** to most users
- **List some examples** of how it would be used
- **Include mockups or examples** if applicable

### Pull Requests

1. **Fork the repo** and create your branch from `main`
2. **Make your changes** following our coding standards
3. **Add tests** if you're adding functionality
4. **Update documentation** if needed
5. **Ensure the test suite passes**
6. **Make sure your code follows** Swift style guidelines
7. **Write a clear commit message**

#### Pull Request Template:
```
**Description**
Brief description of what this PR does.

**Motivation and Context**
Why is this change required? What problem does it solve?

**Type of change**
- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to change)
- [ ] Documentation update

**Testing**
- [ ] I have tested this code on a physical device
- [ ] I have tested this code in the simulator
- [ ] I have added tests that prove my fix is effective or that my feature works

**Checklist**
- [ ] My code follows the code style of this project
- [ ] My change requires a change to the documentation
- [ ] I have updated the documentation accordingly
- [ ] I have read the CONTRIBUTING document
```

## Development Setup

1. Clone the repository:
```bash
git clone https://github.com/yourusername/StickyHeaderScrollView.git
cd StickyHeaderScrollView
```

2. Open in Xcode:
```bash
open Package.swift
```

3. Build and test:
   - Press `Cmd+B` to build
   - Press `Cmd+U` to run tests

## Coding Standards

### Swift Style Guide

- Use Swift naming conventions (camelCase for variables/functions, PascalCase for types)
- Add documentation comments for public APIs using `///`
- Keep functions focused and small (prefer < 30 lines)
- Use meaningful variable names
- Avoid force unwrapping (`!`) when possible
- Use `guard` statements for early returns

### Example:
```swift
/// Calculates the position of a sticky header based on scroll offset
/// - Parameters:
///   - cellId: The unique identifier of the cell
///   - position: The current frame position in global coordinates
/// - Returns: The calculated offset for the header position
func computePosition(cellId: Item.ID, position: CGRect) {
    guard let index = cells.firstIndex(where: { $0.item.id == cellId }) else {
        return
    }
    // Implementation...
}
```

### Commit Messages

- Use the present tense ("Add feature" not "Added feature")
- Use the imperative mood ("Move cursor to..." not "Moves cursor to...")
- Limit the first line to 72 characters or less
- Reference issues and pull requests liberally after the first line

**Good commit messages:**
```
Add collision detection for adjacent headers

- Implement edge detection algorithm
- Add opacity fade when headers overlap
- Update documentation with collision behavior

Fixes #123
```

## Testing

- Write unit tests for new functionality
- Ensure all tests pass before submitting PR
- Test on both simulator and physical devices
- Test on different iOS versions if possible
- Test with different screen sizes

## Documentation

- Update README.md if adding new features
- Add inline code documentation for public APIs
- Update example code if changing APIs
- Consider adding new examples for complex features

## Questions?

Feel free to open an issue with the label `question` if you need help or clarification on anything.

## Recognition

Contributors will be recognized in the README and release notes. Thank you for your contributions!

---

By contributing to StickyHeaderScrollView, you agree that your contributions will be licensed under the MIT License.
