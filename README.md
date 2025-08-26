# JuliaTestRocket

[![CI](https://github.com/bakulev/JuliaTestRocket/actions/workflows/CI.yml/badge.svg)](https://github.com/bakulev/JuliaTestRocket/actions/workflows/CI.yml)
[![Documentation](https://github.com/bakulev/JuliaTestRocket/actions/workflows/Documentation.yml/badge.svg)](https://bakulev.github.io/JuliaTestRocket/)
[![Codecov](https://codecov.io/gh/bakulev/JuliaTestRocket/branch/main/graph/badge.svg)](https://codecov.io/gh/bakulev/JuliaTestRocket)
[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

An interactive Julia application that displays a controllable point using Makie.jl visualization. Control the point's movement using WASD keys with real-time coordinate updates and smooth continuous movement. Built with a backend-agnostic architecture following modern Makie.jl best practices.

## Application Preview

![PointController Application](docs/assets/WorkingApp.png)

*The PointController application showing the interactive point (red dot) with real-time coordinate display and reference grid. Use WASD keys to move the point smoothly around the coordinate space.*

## Features

- **Interactive Point Visualization**: Real-time point rendering using Makie.jl
- **Backend-Agnostic Architecture**: Works with GLMakie, CairoMakie, or WGLMakie
- **WASD Keyboard Controls**: Intuitive movement controls with immediate response
- **Real-time Coordinate Display**: Live coordinate updates as the point moves
- **Smooth Continuous Movement**: Fluid movement while keys are held down
- **Diagonal Movement Support**: Natural diagonal movement when multiple keys are pressed
- **Robust Error Handling**: Comprehensive error handling for graphics and input issues
- **Performance Optimized**: Efficient rendering and input processing
- **CI/CD Ready**: Comprehensive test suite with backend-specific testing strategies

## Installation

### Prerequisites
- Julia 1.10 or higher
- For interactive graphics: OpenGL 3.3+ compatible graphics card and drivers
- For headless operation: No graphics hardware required

### Setup Instructions

1. **Install Julia**: Download from [julialang.org](https://julialang.org/downloads/)

2. **Clone or download this project**:
   ```bash
   git clone https://github.com/bakulev/JuliaTestRocket.git
   cd JuliaTestRocket
   ```

3. **Activate the project environment**:
   ```julia
   using Pkg
   Pkg.activate(".")
   Pkg.instantiate()
   ```

## Usage

### Backend Activation (Required)

PointController follows modern Makie.jl patterns where **users control backend activation**. You must activate a Makie backend before using PointController functions.

#### Available Backends

**GLMakie (Interactive Graphics)**:
```julia
using GLMakie
GLMakie.activate!()
```
- **Best for**: Interactive applications, real-time graphics
- **Features**: Full OpenGL acceleration, interactive windows
- **Requirements**: OpenGL 3.3+, display system

**CairoMakie (Static/Headless Graphics)**:
```julia
using CairoMakie
CairoMakie.activate!()
```
- **Best for**: Publication-quality plots, CI environments, headless operation
- **Features**: Vector graphics, no display required
- **Requirements**: None (works in headless environments)

**WGLMakie (Web Graphics)**:
```julia
using WGLMakie
WGLMakie.activate!()
```
- **Best for**: Web applications, browser-based graphics
- **Features**: WebGL-based, runs in browsers
- **Requirements**: WebGL-capable browser

### Recommended Usage Methods

#### 1. Interactive Mode (Recommended for Development)

Start an interactive Julia session with the project loaded:

```bash
# Start interactive session
julia --project=. -i start_interactive.jl

# Then in the Julia REPL, activate your preferred backend:
using GLMakie; GLMakie.activate!()
run_point_controller()
```

#### 2. Direct Execution with GLMakie (Interactive Graphics)

Run the application directly with interactive graphics:

```bash
julia run_glmakie.jl
```

#### 3. Direct Execution with CairoMakie (Headless)

Run the application in headless mode (for CI/headless environments):

```bash
julia run_cairomakie.jl
```

#### 4. Manual Setup (Advanced Users)

For advanced users who want full control:

```bash
# Start Julia with project
julia --project=.

# In Julia REPL:
using Pkg; Pkg.instantiate()
using GLMakie; GLMakie.activate!()
using PointController
run_point_controller()
```

### Why These Methods Are Better

The recommended approach provides:
- **Proper Module Loading**: Each module loads in the correct order
- **Error Handling**: Each step can be verified before proceeding
- **Interactive Debugging**: Can inspect state and debug issues
- **Resource Management**: Proper cleanup and resource management
- **Flexibility**: Can easily switch backends or modify behavior

### Controls

| Key | Action |
|-----|--------|
| **W** | Move point up (positive Y direction) |
| **S** | Move point down (negative Y direction) |
| **A** | Move point left (negative X direction) |
| **D** | Move point right (positive X direction) |
| **Q** | Quit application |

**Advanced Controls**:
- **Multiple keys**: Press multiple WASD keys simultaneously for diagonal movement
- **Window close**: Close the window to exit the application
- **Focus handling**: Application safely handles window focus changes

### Visual Interface

- **Red point**: The controllable point that responds to keyboard input
- **Coordinate display**: Real-time position shown in the top-left corner
- **Grid system**: Reference grid for precise positioning
- **Axis labels**: X and Y coordinate axes with proper scaling

## Project Structure

```
JuliaTestRocket/
├── Project.toml                          # Package configuration and dependencies
├── README.md                             # This documentation file
├── LICENSE                               # MIT license file
├── start_interactive.jl                  # Interactive startup script
├── run_glmakie.jl                        # GLMakie execution script
├── run_cairomakie.jl                     # CairoMakie execution script
├── docs/                                # Documentation and assets
│   └── assets/                          # Images and media files
│       └── WorkingApp.png               # Application screenshot
├── src/                                 # Source code directory
│   ├── PointController.jl               # Main module and application entry point
│   ├── movement_state.jl                # Movement state management and key tracking
│   ├── input_handler.jl                 # Keyboard event processing and validation
│   └── visualization.jl                 # Makie visualization setup and rendering
└── test/                                # Test suite directory
    ├── runtests.jl                      # Main test runner
    ├── test_movement_state.jl           # Movement state and calculation tests
    ├── test_input.jl                    # Input handler and keyboard event tests
    ├── test_visualization.jl            # Visualization component tests
    ├── test_glmakie_smoke.jl            # GLMakie smoke tests
    └── test_integration_comprehensive.jl # End-to-end integration tests
```

## Development

### Running Tests

**Full test suite**:
```julia
using Pkg
Pkg.test()
```

**From command line**:
```bash
julia --project=. -e "using Pkg; Pkg.test()"
```

**Individual test files**:
```julia
# Test specific components
include("test/test_movement_state.jl")
include("test/test_input.jl")
include("test/test_visualization.jl")
```

### Code Organization

The codebase is organized into modular components:

- **`PointController.jl`**: Main module with application lifecycle management
- **`movement_state.jl`**: State management for point position and key tracking
- **`input_handler.jl`**: Keyboard event processing and input validation
- **`visualization.jl`**: Makie setup, rendering, and display management

### Architecture Highlights

- **Backend-Agnostic Core**: Core logic is independent of specific Makie backends
- **Runtime Backend Detection**: Automatically detects and adapts to active backends
- **Modular Design**: Separate concerns for movement, input, and visualization
- **Modern Makie Patterns**: Follows current best practices for backend activation

### Adding Features

1. **Movement modifications**: Edit `movement_state.jl` for new movement behaviors
2. **Input handling**: Modify `input_handler.jl` for additional key bindings
3. **Visual changes**: Update `visualization.jl` for rendering modifications
4. **New functionality**: Add to `PointController.jl` and create corresponding tests

## System Requirements

### Minimum Requirements
- **Julia**: Version 1.10 or higher
- **RAM**: 512 MB available memory

### For Interactive Graphics (GLMakie)
- **OpenGL**: Version 3.3 or higher
- **Graphics**: Hardware-accelerated graphics card
- **Display**: Working display system (X11, Wayland, or native windowing)

### For Headless Operation (CairoMakie)
- **No graphics hardware required**
- **No display system required**

### Recommended Requirements
- **Julia**: Version 1.11 or higher
- **OpenGL**: Version 4.0 or higher (for GLMakie)
- **RAM**: 1 GB available memory
- **Graphics**: Dedicated graphics card with updated drivers (for GLMakie)

### Supported Platforms
- **Linux**: X11 and Wayland display systems
- **macOS**: Native windowing system
- **Windows**: DirectX-compatible graphics

## Troubleshooting

### Common Issues

**"No Makie backend activated"**:
- Solution: Activate a backend before running the application
- Example: `using GLMakie; GLMakie.activate!()`

**GLMakie initialization fails**:
- Update graphics drivers to latest version
- Verify OpenGL 3.3+ support: `glxinfo | grep "OpenGL version"` (Linux)
- Try software rendering if hardware acceleration unavailable
- Use CairoMakie as alternative: `using CairoMakie; CairoMakie.activate!()`

**Window doesn't appear**:
- Check display system configuration (DISPLAY variable on Linux)
- Verify X11 forwarding if using SSH: `ssh -X username@hostname`
- Ensure window manager is running
- Use CairoMakie for headless operation

**Keyboard input not working**:
- Click on the window to ensure it has focus
- Check for conflicting key bindings in window manager
- Verify keyboard layout is standard QWERTY

**Performance issues**:
- Close other graphics-intensive applications
- Reduce window size if experiencing lag
- Check system resource usage (CPU, memory, GPU)

### Error Messages

**"OpenGL initialization failed"**:
```
Solution: Update graphics drivers and verify OpenGL 3.3+ support
Alternative: Use CairoMakie for headless operation
```

**"Display system not available"**:
```
Solution: Use CairoMakie or ensure display system is available
For SSH: Enable X11 forwarding or use CairoMakie
```

**"Out of memory error"**:
```
Solution: Close other applications and restart Julia session
```

## API Documentation

### Main Functions

#### `run_point_controller()`
Main entry point for the application. Initializes all components and starts the interactive loop.

#### `MovementState(speed::Float64 = 1.0)`
Creates a new movement state with specified movement speed.

#### Key Management Functions
- `add_key!(state, key)`: Add a key to pressed keys set
- `remove_key!(state, key)`: Remove a key from pressed keys set
- `calculate_movement_vector(state)`: Calculate movement based on pressed keys

### Configuration Options

Movement speed can be adjusted by modifying the `MovementState` initialization:
```julia
# Slower movement
state = MovementState(0.05)

# Faster movement  
state = MovementState(0.2)
```

## License

This project is licensed under the MIT License. See the LICENSE file for details.

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Make changes and add tests
4. Run the test suite: `julia --project=. -e "using Pkg; Pkg.test()"`
5. Submit a pull request

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

## Support

For issues and questions:
1. Check the troubleshooting section above
2. Review existing issues in the repository
3. Create a new issue with detailed error information and system specifications