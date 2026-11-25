# DevKeychain

DevKeychain is a small Swift package that provides a Swift interface to Apple’s keychain services.
It is fully documented and tested and supports version 26 of Apple’s OSes.


View our [changelog](CHANGELOG.md) to see what’s new.


## Development Requirements

DevKeychain requires a Swift 6.4+ toolchain to build. We only test on Apple platforms. We follow the
[Swift API Design Guidelines][SwiftAPIDesignGuidelines]. We take pride in the fact that our public
interfaces are fully documented and tested. We aim for overall test coverage over 99%.

[SwiftAPIDesignGuidelines]: https://swift.org/documentation/api-design-guidelines/


### Development Setup

To set up the development environment:

  1. Run `Tools/install-git-hooks` to install a pre-push hook that runs `Tools/lint`.
  2. Use `Tools/lint` to check Swift and Markdown formatting at any time.
  3. Use `Tools/format` to fix formatting issues.


## Continuous Integration

DevKeychain uses GitHub Actions for continuous integration. The CI pipeline:

  - **Linting**: Checks Swift and Markdown formatting on all pull requests using `Tools/lint`
  - **Testing**: Builds and tests on iOS, macOS, tvOS, and watchOS
  - **Coverage**: Generates code coverage reports using xccovPretty


## Bugs and Feature Requests

Find a bug? Want a new feature? Create a GitHub issue and we’ll take a look.


## License

All code is licensed under the MIT license. Do with it as you will.
