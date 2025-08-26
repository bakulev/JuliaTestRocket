# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Backend-agnostic architecture following modern Makie.jl best practices
- Runtime backend detection and dynamic backend access
- Support for multiple Makie backends (GLMakie, CairoMakie, WGLMakie)
- Comprehensive CI/CD pipeline with backend-specific testing strategies
- Dedicated execution scripts for different backends (`run_glmakie.jl`, `run_cairomakie.jl`)
- Interactive startup script (`start_interactive.jl`)
- GLMakie smoke tests for interactive functionality
- CairoMakie-based visual regression tests
- Modern dependency management with conditional dependencies

### Changed
- Refactored core application logic to be backend-agnostic
- Moved Makie backends from `[deps]` to `[extras]` in Project.toml
- Updated all source files to use dynamic backend access via `Main.` prefix
- Restructured test suite to separate backend-agnostic and backend-specific tests
- Enhanced error handling and user guidance for backend activation
- Improved application responsiveness by integrating movement updates into main event loop
- Updated documentation to reflect modern Makie.jl patterns

### Fixed
- Precompilation errors in headless CI environments
- Keyboard event handling issues (event.button vs event.key)
- Movement timer integration and responsiveness
- Test failures related to logging output and floating-point precision
- Module loading conflicts and timing issues

### Removed
- Direct GLMakie dependency from core module
- Redundant execution scripts (`run_app.jl`, `run_app_ci.jl`, `run_tests.jl`)
- Outdated installation verification script
- Hardcoded backend assumptions throughout the codebase

## [0.1.0] - 2024-01-XX

### Added
- Initial release of PointController.jl
- Interactive point control using WASD keyboard inputs
- Real-time visualization with GLMakie backend
- Smooth continuous movement with diagonal support
- Comprehensive error handling and recovery
- Modular architecture with separate concerns
- Complete test suite with 357+ passing tests
- Modern Julia package structure and best practices

### Features
- **Point Control**: Real-time point movement using W/A/S/D keys
- **Visual Feedback**: Live coordinate display and reference grid
- **Diagonal Movement**: Natural diagonal movement with multiple key presses
- **Error Recovery**: Robust error handling for graphics and input issues
- **Performance**: Optimized rendering with 60 FPS smooth animation
- **Cross-Platform**: Support for Linux, macOS, and Windows

### Technical Highlights
- **Backend Activation**: Modern Makie.jl pattern with user-controlled activation
- **Observable System**: Reactive UI updates using GLMakie's Observable pattern
- **Timer-Based Movement**: Frame-rate independent smooth movement
- **Modular Design**: Separate modules for movement, input, and visualization
- **Comprehensive Testing**: Unit, integration, and end-to-end test coverage

### Requirements
- Julia 1.10+ (LTS version)
- GLMakie.jl 0.10-0.11
- OpenGL 3.3+ compatible graphics
- Hardware-accelerated graphics recommended

---

## Release Types

This project follows [Semantic Versioning](https://semver.org/):

- **MAJOR** version when you make incompatible API changes
- **MINOR** version when you add functionality in a backwards compatible manner  
- **PATCH** version when you make backwards compatible bug fixes

### Version History Guidelines

#### Major Versions (X.0.0)
- Breaking API changes
- Significant architectural changes
- Removal of deprecated features
- Changes requiring user migration

#### Minor Versions (0.X.0)
- New features and functionality
- Performance improvements
- New configuration options
- Backwards compatible API additions

#### Patch Versions (0.0.X)
- Bug fixes and error corrections
- Documentation improvements
- Dependency updates (compatible versions)
- Performance optimizations without API changes

---

## Contributing to Changelog

When contributing to this project, please update the `[Unreleased]` section with your changes:

1. **Added** for new features
2. **Changed** for changes in existing functionality
3. **Deprecated** for soon-to-be removed features
4. **Removed** for now removed features
5. **Fixed** for any bug fixes
6. **Security** in case of vulnerabilities

### Example Entry Format

```markdown
### Added
- New feature description with brief explanation of functionality
- Reference to issue/PR if applicable (#123)

### Fixed  
- Bug fix description with impact and resolution (#456)
```

### Release Process

1. Update `[Unreleased]` section with all changes
2. Run version management script: `julia scripts/version_management.jl bump <type>`
3. Move unreleased changes to new version section
4. Add release date in YYYY-MM-DD format
5. Create git tag and push changes
6. Update documentation and announce release

---

## Links

- [Project Repository](https://github.com/bakulev/JuliaTestRocket)
- [Documentation](https://bakulev.github.io/JuliaTestRocket/)
- [Issue Tracker](https://github.com/bakulev/JuliaTestRocket/issues)
- [Releases](https://github.com/bakulev/JuliaTestRocket/releases)