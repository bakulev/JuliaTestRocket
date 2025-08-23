# Technology Stack

## Core Technologies

- **Julia**: Version 1.10+ (LTS), modern Julia language features and patterns
- **GLMakie.jl**: Version 0.10-0.11, OpenGL-based interactive visualization backend
- **Package Management**: Julia's built-in Pkg system with Project.toml/Manifest.toml

## Architecture Patterns

- **Modular Design**: Separate modules for movement state, input handling, and visualization
- **Observable Pattern**: GLMakie's Observable system for reactive UI updates
- **Event-Driven**: Keyboard event processing with timer-based continuous movement
- **Error-First Design**: Comprehensive error handling and graceful degradation

## Key Dependencies

```toml
[deps]
GLMakie = "e9467ef8-e4e7-5192-8a1a-b1aee30e663a"

[compat]
GLMakie = "0.10, 0.11"
julia = "1.10"
```

## Common Commands

### Development Setup
```bash
# Activate project environment
julia --project=.

# Install dependencies
julia --project=. -e "using Pkg; Pkg.instantiate()"

# Verify installation
julia --project=. verify_installation.jl
```

### Running the Application
```bash
# Using provided script (recommended)
julia run_app.jl

# Manual execution
julia --project=. -e "using GLMakie; GLMakie.activate!(); using PointController; run_point_controller()"
```

### Testing
```bash
# Run full test suite
julia --project=. -e "using Pkg; Pkg.test()"

# Run tests with script
julia run_tests.jl

# Run specific test file
julia --project=. test/test_movement_state.jl
```

### Backend Activation Pattern

**Critical**: GLMakie backend must be activated by users before using PointController:

```julia
using GLMakie
GLMakie.activate!()  # Required before PointController functions
using PointController
run_point_controller()
```

## Performance Considerations

- **Timer-based Movement**: 60 FPS update rate with time-delta scaling
- **Observable Updates**: Efficient reactive UI updates only when needed
- **Render Optimization**: Minimal overdraw and optimized marker rendering
- **Memory Management**: Proper resource cleanup and timer management

## System Requirements

- **OpenGL**: Version 3.3+ for GLMakie rendering
- **Graphics**: Hardware-accelerated graphics recommended
- **Display**: X11/Wayland (Linux), native windowing (macOS/Windows)
- **Memory**: 512MB+ available RAM for graphics operations

## Modern Julia Patterns

- **Keyword Arguments**: Use keyword arguments for constructors (e.g., `MovementState(movement_speed = 1.0)`)
- **Error Handling**: Comprehensive try-catch blocks with meaningful error messages
- **Documentation**: Docstrings for all public functions following Julia conventions
- **Testing**: Use Test.jl with @testset organization for comprehensive coverage
- **Module Exports**: Export only public API functions, keep internal functions private