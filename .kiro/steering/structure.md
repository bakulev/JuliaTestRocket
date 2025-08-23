# Project Structure

## Directory Organization

```
PointController/
├── Project.toml                          # Package configuration and dependencies
├── Manifest.toml                         # Dependency lock file (auto-generated)
├── README.md                             # Main documentation
├── LICENSE                               # MIT license
├── run_app.jl                           # Application launcher script
├── run_tests.jl                         # Test runner script
├── verify_installation.jl               # Installation verification
├── src/                                 # Source code (main package)
│   ├── PointController.jl               # Main module and entry point
│   ├── movement_state.jl                # Movement state management
│   ├── input_handler.jl                 # Keyboard event processing
│   └── visualization.jl                 # GLMakie rendering and display
└── test/                                # Test suite
    ├── Project.toml                     # Test-specific dependencies
    ├── runtests.jl                      # Main test runner
    ├── test_movement_state.jl           # Movement state tests
    ├── test_input.jl                    # Input handling tests
    ├── test_visualization.jl            # Visualization tests
    ├── test_keyboard_integration.jl     # Integration tests
    └── test_integration_comprehensive.jl # End-to-end tests
```

## Module Architecture

### Core Modules (src/)

- **PointController.jl**: Main module containing application lifecycle, error handling, and public API
- **movement_state.jl**: State management for point position, key tracking, and movement calculations
- **input_handler.jl**: Keyboard event processing, validation, and state integration
- **visualization.jl**: GLMakie setup, rendering, coordinate display, and window management

### Module Dependencies

```
PointController.jl (main)
├── movement_state.jl    # State management
├── input_handler.jl     # Event processing  
└── visualization.jl     # Rendering
```

## Code Organization Patterns

### Exported API Structure
```julia
# Main entry point
export run_point_controller

# Core types
export MovementState, KEY_MAPPINGS

# Movement state functions
export add_key!, remove_key!, calculate_movement_vector
export reset_movement_state!, request_quit!

# Input handling functions
export handle_key_press, handle_key_release, is_movement_key

# Visualization functions
export create_visualization, update_point_position!
```

### File Naming Conventions

- **Snake_case**: All Julia source files use snake_case (e.g., `movement_state.jl`)
- **Test prefix**: Test files prefixed with `test_` (e.g., `test_movement_state.jl`)
- **Descriptive names**: File names clearly indicate their purpose and scope

### Function Organization

- **Public API**: Exported functions at module level
- **Internal helpers**: Non-exported utility functions within modules
- **Error handling**: Comprehensive try-catch blocks with meaningful error messages
- **Documentation**: Docstrings for all public functions and key internal functions

## Configuration Files

- **Project.toml**: Package metadata, dependencies, compatibility constraints
- **test/Project.toml**: Test-specific dependencies (Test.jl, GLMakie.jl)
- **Manifest.toml**: Exact dependency versions (auto-generated, version controlled)

## Development Workflow

1. **Source changes**: Edit files in `src/` directory
2. **Testing**: Run tests from `test/` directory using `run_tests.jl`
3. **Integration**: Use `run_app.jl` for full application testing
4. **Verification**: Run `verify_installation.jl` to check setup

## Best Practices

- **Modular design**: Each file has a single, clear responsibility
- **Consistent exports**: Only export what users need in public API
- **Error handling**: Every module includes comprehensive error recovery
- **Documentation**: All public functions have docstrings with examples
- **Testing**: Each module has corresponding test file with comprehensive coverage