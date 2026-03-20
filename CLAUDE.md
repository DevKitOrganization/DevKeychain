# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this
repository.


## Project Overview

DevKeychain is a Swift package providing a modern, type-safe interface to Apple's keychain
services. It supports version 26 of Apple's OSes and requires a Swift 6.2+ toolchain.


## Development Commands

### Building and Testing

  - **Build**: `swift build`
  - **Test all**: `swift test`
  - **Test specific**: `swift test --filter <TestName>`
  - **Test with coverage**: `swift test --enable-code-coverage`

### Code Quality

  - **Lint**: `Scripts/lint` (uses `swift format lint --recursive --strict`)
  - **Format**: `Scripts/format` (uses `swift format --in-place --recursive`)

### Git Hooks

  - **Install**: `Scripts/install-git-hooks` (installs pre-push hook that runs lint)


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

The project uses GitHub Actions for continuous integration:

  - **Linting**: Automatically checks code formatting on all pull requests using `swift format`
  - **Testing**: Builds and tests on iOS, macOS, tvOS, and watchOS
  - **Coverage**: Generates code coverage reports using xccovPretty
  - Uses Xcode 26.3 and macOS 26 runners


## Platform Requirements

  - Swift 6.2+ toolchain required
  - Xcode 26.3 for CI/CD
  - Apple platforms only (iOS/macOS/tvOS/visionOS/watchOS version 26)
  - Uses modern Swift concurrency features


## Testing and Mocking Standards

### Test Mock Architecture

The codebase uses a consistent stub-based mocking pattern built on the DevTesting framework:

#### Core Mock Patterns

  - **Stub-based mocks**: All mocks use `Stub<Input, Output>` or
    `ThrowingStub<Input, Output, Error>`
  - **Force-unwrapped stubs**: Stub properties are declared with `!` — tests must configure them
  - **Swift 6 concurrency**: All stub properties marked `nonisolated(unsafe)`
  - **Argument structures**: Complex parameters use dedicated structures (e.g.,
    `LogErrorArguments`)

#### Mock Organization

  - **File naming**: `Mock[ProtocolName].swift`
  - **Type naming**: `Mock[ProtocolName]`
  - **Stub properties**: `[functionName]Stub`
  - **Location**: `Tests/DevKeychainTests/Testing Helpers/`

#### Test Patterns

  - Use `@Test` with Swift Testing framework
  - Use `#expect()` and `#require()` for assertions
  - Always configure stubs before use to avoid crashes
  - Leverage DevTesting's call tracking for verification


## Documentation Standards

Follow the project's Markdown Style Guide:

  - **Line length**: 100 characters max
  - **Code blocks**: Use 4-space indentation, not fenced blocks
  - **Lists**: Use `-` for bullets, align continuation lines with text
  - **Spacing**: 2 blank lines between major sections, 1 after headers
  - **Terminology**: Use "function" over "method", "type" over "class"

When writing Markdown documentation, reference `@Documentation/MarkdownStyleGuide.md` to
ensure consistent formatting, structure, and style across all project documentation.


## Code Formatting and Spacing

The project follows strict spacing conventions for readability and consistency:

  - **2 blank lines between major sections** including:
    - Between the last property declaration and first function declaration
    - Between all function/computed property implementations at the same scope level
    - Between top-level type declarations (class, struct, enum, protocol, extension)
    - Before MARK comments that separate major sections
  - **1 blank line** for minor separations:
    - Between property declarations and nested type definitions
    - Between all function definitions in protocols
    - After headers in documentation
    - After MARK comments that separate major sections
  - **File endings**: All Swift files must end with exactly one blank line


## Scripts Directory

The `Scripts/` directory contains utility scripts for development workflow automation:

### Available Scripts

**`Scripts/install-git-hooks`**:
  - Installs a pre-push git hook that runs `Scripts/lint` for formatting validation
  - Works correctly with git worktrees
  - Run once per repository to set up automated code quality workflow

**`Scripts/lint`**:
  - Runs `swift format lint` validation with strict mode enabled
  - Checks `App/`, `Sources/`, and `Tests/` directories recursively
  - Returns non-zero exit code if formatting issues are found
  - Used by pre-push hook and can be run manually for code quality verification

**`Scripts/format`**:
  - Runs `swift format --in-place` to automatically fix formatting issues
  - Formats `App/`, `Sources/`, and `Tests/` directories recursively


## Key Files for Understanding

  - `Sources/DevKeychain/Core/Keychain.swift`: Main API entry point
  - `Sources/DevKeychain/Core/KeychainServices.swift`: Core protocol abstraction
  - `Sources/DevKeychain/Keychain Items/GenericPassword.swift`: Example keychain item
    implementation
  - `Tests/DevKeychainTests/Testing Helpers/`: Mock implementations and test utilities
  - `Package.swift`: Dependencies and platform requirements
  - `.swift-format`: Code formatting configuration
  - `Scripts/`: Development workflow automation scripts
