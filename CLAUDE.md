# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this
repository.


## Project Overview

DevKeychain is a Swift package providing a modern, type-safe interface to Apple's keychain
services. It supports iOS 18+, macOS 15+, tvOS 18+, visionOS 2+, and watchOS 11+, requiring
Swift 6.1 toolchain.


## Common Development Commands

### Building and Testing

    # Build the package
    swift build

    # Run all tests
    swift test

    # Run specific test
    swift test --filter <TestName>

    # Build and test with code coverage
    swift test --enable-code-coverage

### Code Quality

    # Format code (requires swift-format)
    swift-format --in-place --recursive Sources/ Tests/

    # Check formatting
    swift-format --recursive Sources/ Tests/

### Git Hooks

    # Install pre-commit hooks (if Scripts directory exists)
    Scripts/install-git-hooks

    # Run linting manually
    Scripts/lint


## Architecture Overview

### Core Design Pattern

The codebase follows a **protocol-based architecture** with dependency injection:

  - `KeychainServices` protocol abstracts Security framework operations
  - `StandardKeychainServices` provides real implementation
  - Mock implementations enable comprehensive testing
  - All keychain item types implement `KeychainItemAdditionAttributes` and `KeychainItemQuery`
    protocols

### Key Components

**Core Layer** (`Sources/DevKeychain/Core/`):

  - `Keychain.swift`: Main keychain interface
  - `KeychainServices.swift`: Protocol abstraction over Security framework
  - `KeychainItemAdditionAttributes.swift` & `KeychainItemQuery.swift`: Generic protocols for
    type-safe operations

**Keychain Item Types** (`Sources/DevKeychain/Keychain Items/`):

  - `GenericPassword.swift`: Service/account-based passwords
  - `InternetPassword.swift`: Server/account-based credentials
  - Each type has nested `AdditionAttributes` and `Query` types

**Error Handling** (`Sources/DevKeychain/Errors/`):

  - `KeychainServicesError.swift`: Wraps OSStatus errors from Security framework
  - `KeychainItemMappingError.swift`: Data conversion and mapping errors

### Testing Architecture

Uses **Swift Testing** framework with comprehensive mocking:

  - All tests inject mock `KeychainServices` implementations
  - `DevTesting` dependency provides Stub system for mocking
  - Tests are organized by component in `Tests/DevKeychainTests/`
  - Integration tests in `App/Tests/` use real keychain operations

### Code Organization Patterns

  1. **Nested Types**: Related functionality grouped within parent types
  2. **Generic Protocols**: Type-safe operations without runtime checks
  3. **Extension-based Helpers**: `Dictionary+KeychainItemMapping.swift` for attribute conversion
  4. **Dependency Injection**: Constructor injection for `KeychainServices`


## Development Guidelines

### Adding New Keychain Item Types

  1. Create new file in `Sources/DevKeychain/Keychain Items/`
  2. Implement `KeychainItemAdditionAttributes` protocol for adding items
  3. Implement `KeychainItemQuery` protocol for querying items
  4. Add comprehensive tests with both success and failure scenarios
  5. Follow the pattern established by `GenericPassword` and `InternetPassword`

### Testing Patterns

  - Always use mock `KeychainServices` in unit tests
  - Use `DevTesting.Stub` for consistent mocking behavior
  - Test both success and error scenarios
  - Use randomized test data via `RandomValueGenerating+DevKeychain.swift`
  - Follow naming convention: `<ComponentName>Tests.swift`

### Code Style

  - Swift API Design Guidelines strictly enforced
  - 120 character line limit (configured in `.swift-format`)
  - All public APIs must be documented
  - Use descriptive variable names and clear function signatures


## CI/CD Configuration

The project uses GitHub Actions with comprehensive testing:

  - Multi-platform testing (iOS, macOS, tvOS, watchOS)
  - Code coverage reporting with xccovPretty
  - Swift-format validation
  - Test plans in `Build Support/Test Plans/`


## Platform Requirements

  - Swift 6.1 toolchain required
  - Xcode 16.4 for CI/CD
  - Apple platforms only (iOS 18+, macOS 15+, tvOS 18+, visionOS 2+, watchOS 11+)
  - Uses modern Swift concurrency features


## Scripts Directory

The `Scripts/` directory contains utility scripts for development workflow automation:

### Available Scripts

**`Scripts/install-git-hooks`**:
  - Installs pre-commit git hooks that automatically run lint checks
  - Creates `.git/hooks/pre-commit` that calls `Scripts/lint`
  - Prevents commits with formatting issues
  - Run once per repository to set up automated code quality checks

**`Scripts/lint`**:
  - Runs swift-format lint validation with strict mode enabled
  - Checks `App/`, `Sources/`, and `Tests/` directories recursively
  - Returns non-zero exit code if formatting issues are found
  - Used by pre-commit hooks and can be run manually for code quality verification

### Usage Patterns

  - Run `Scripts/install-git-hooks` after cloning the repository
  - Pre-commit hooks will automatically run `Scripts/lint` before each commit
  - Manual lint checking: `Scripts/lint`
  - Both scripts work from any directory by calculating repository root path


## Key Files for Understanding

  - `Sources/DevKeychain/Core/Keychain.swift`: Main API entry point
  - `Sources/DevKeychain/Core/KeychainServices.swift`: Core protocol abstraction
  - `Sources/DevKeychain/Keychain Items/GenericPassword.swift`: Example keychain item
    implementation
  - `Tests/DevKeychainTests/Testing Helpers/`: Mock implementations and test utilities
  - `Package.swift`: Dependencies and platform requirements
  - `.swift-format`: Code formatting configuration
  - `Scripts/`: Development workflow automation scripts