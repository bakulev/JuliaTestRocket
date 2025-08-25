# JuliaTestRocket

[![CI](https://github.com/bakulev/JuliaTestRocket/actions/workflows/CI.yml/badge.svg)](https://github.com/bakulev/JuliaTestRocket/actions/workflows/CI.yml)
[![Documentation](https://github.com/bakulev/JuliaTestRocket/actions/workflows/Documentation.yml/badge.svg)](https://bakulev.github.io/JuliaTestRocket/)
[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

An interactive Julia application that displays a controllable point using GLMakie visualization. Control the point's movement using WASD keys with real-time coordinate updates and smooth continuous movement.

## Application Preview

![PointController Application](docs/assets/WorkingApp.png)

*The PointController application showing the interactive point (red dot) with real-time coordinate display and reference grid. Use WASD keys to move the point smoothly around the coordinate space.*

## Features

- **Interactive Point Visualization**: Real-time point rendering using GLMakie
- **WASD Keyboard Controls**: Intuitive movement controls with immediate response
- **Real-time Coordinate Display**: Live coordinate updates as the point moves
- **Smooth Continuous Movement**: Fluid movement while keys are held down
- **Diagonal Movement Support**: Natural diagonal movement when multiple keys are pressed
- **Robust Error Handling**: Comprehensive error handling for graphics and input issues
- **Performance Optimized**: Efficient rendering and input processing

## Installation

### Prerequisites
- Julia 1.6 or higher
- OpenGL 3.3+ compatible graphics card and drivers
- Working display system (X11, Wayland, or native windowing)

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

4. **Verify installation**:
   ```bash
   julia --project=. verify_installation.jl
   ```
   
   This will check all dependencies and basic functionality. You should see:
   ```
   === Installation Verification Complete ===
   ✓ All checks passed!
   ```

## Usage

### Backend Activation

PointController follows modern Makie.jl patterns where users control backend activation. 
**You must activate GLMakie before using PointController functions:**

```julia
using GLMakie
GLMakie.activate!()  # Required before using PointController
```

**Backend Configuration Options:**
```julia
# Basic activation
GLMakie.activate!()

# With custom window settings
GLMakie.activate!(
    title = "My Point Controller",
    vsync = true,
    framerate = 60.0,
    fxaa = true
)

# For HiDPI displays
GLMakie.activate!(scalefactor = 2.0)
```

### Quick Start

**From Julia REPL**:
```julia
# First, activate the GLMakie backend
using GLMakie
GLMakie.activate!()

# Then use PointController
using PointController
run_point_controller()
```

**From command line**:
```bash
julia --project=. -e "using GLMakie; GLMakie.activate!(); using PointController; run_point_controller()"
```

**Using the provided script**:
```bash
julia run_app.jl
```

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

> 💡 **Tip**: See the [application preview](#application-preview) above for a visual example of the interface in action.

## Project Structure

```
JuliaTestRocket/
├── Project.toml                          # Package configuration and dependencies
├── README.md                             # This documentation file
├── LICENSE                               # MIT license file
├── run_app.jl                           # Standalone application launcher
├── verify_installation.jl               # Installation verification script
├── docs/                                # Documentation and assets
│   └── assets/                          # Images and media files
│       └── WorkingApp.png               # Application screenshot
├── src/                                 # Source code directory
│   ├── PointController.jl               # Main module and application entry point
│   ├── movement_state.jl                # Movement state management and key tracking
│   ├── input_handler.jl                 # Keyboard event processing and validation
│   └── visualization.jl                 # GLMakie visualization setup and rendering
└── test/                                # Test suite directory
    ├── runtests.jl                      # Main test runner
    ├── test_movement_state.jl           # Movement state and calculation tests
    ├── test_input.jl                    # Input handler and keyboard event tests
    ├── test_visualization.jl            # Visualization component tests
    ├── test_keyboard_integration.jl     # Keyboard integration tests
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
julia --project=. test/runtests.jl
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
- **`visualization.jl`**: GLMakie setup, rendering, and display management

### Adding Features

1. **Movement modifications**: Edit `movement_state.jl` for new movement behaviors
2. **Input handling**: Modify `input_handler.jl` for additional key bindings
3. **Visual changes**: Update `visualization.jl` for rendering modifications
4. **New functionality**: Add to `PointController.jl` and create corresponding tests

## System Requirements

### Minimum Requirements
- **Julia**: Version 1.6 or higher
- **OpenGL**: Version 3.3 or higher
- **RAM**: 512 MB available memory
- **Graphics**: Hardware-accelerated graphics card

### Recommended Requirements
- **Julia**: Version 1.8 or higher
- **OpenGL**: Version 4.0 or higher
- **RAM**: 1 GB available memory
- **Graphics**: Dedicated graphics card with updated drivers

### Supported Platforms
- **Linux**: X11 and Wayland display systems
- **macOS**: Native windowing system
- **Windows**: DirectX-compatible graphics

## Troubleshooting

### Common Issues

**GLMakie initialization fails**:
- Update graphics drivers to latest version
- Verify OpenGL 3.3+ support: `glxinfo | grep "OpenGL version"` (Linux)
- Try software rendering if hardware acceleration unavailable

**Window doesn't appear**:
- Check display system configuration (DISPLAY variable on Linux)
- Verify X11 forwarding if using SSH: `ssh -X username@hostname`
- Ensure window manager is running

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
```

**"Display system not available"**:
```
Solution: Ensure X11/Wayland is running or enable X11 forwarding for SSH
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
4. Run the test suite: `julia --project=. test/runtests.jl`
5. Submit a pull request

## Support

For issues and questions:
1. Check the troubleshooting section above
2. Review existing issues in the repository
3. Create a new issue with detailed error information and system specifications