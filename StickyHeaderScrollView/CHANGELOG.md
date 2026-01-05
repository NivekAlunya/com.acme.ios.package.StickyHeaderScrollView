# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned
- Add support for vertical scrolling
- Custom animation curves for header transitions
- Accessibility improvements
- iPad optimization

## [1.0.0] - 2025-12-11

### Added
- Initial release of StickyHeaderScrollView
- Horizontal scrolling with sticky headers
- Smooth header collision and push-out animation
- Fade effect for headers being pushed off-screen
- Generic implementation supporting any `Identifiable` type
- Customizable header and cell views via ViewBuilder
- Comprehensive documentation and examples
- Swift Package Manager support
- Example implementations for common use cases:
  - E-commerce product categories
  - Timeline/schedule view
  - Photo gallery by date

### Features
- **Sticky Headers**: Headers remain visible at the left edge while scrolling
- **Collision Detection**: Automatic detection and handling of header overlap
- **Smooth Transitions**: Elegant animations when headers push each other out
- **Type-Safe**: Built with Swift generics for maximum flexibility
- **SwiftUI Native**: Uses modern SwiftUI APIs (iOS 17+)
- **Fully Customizable**: Complete control over header and cell appearance
- **Performance Optimized**: Efficient geometry tracking and state management

### Technical Details
- Minimum iOS version: 17.0
- Uses `onGeometryChange` for efficient position tracking
- Uses `.position()` modifier for precise header placement
- Automatic width calculation based on header content
- Opacity fade calculation based on visibility

---

## Release Notes Format

### Types of Changes
- **Added** - for new features
- **Changed** - for changes in existing functionality
- **Deprecated** - for soon-to-be removed features
- **Removed** - for now removed features
- **Fixed** - for any bug fixes
- **Security** - in case of vulnerabilities

[Unreleased]: https://github.com/yourusername/StickyHeaderScrollView/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/yourusername/StickyHeaderScrollView/releases/tag/v1.0.0
