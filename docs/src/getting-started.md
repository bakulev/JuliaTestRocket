# Getting Started

## Installation

### Prerequisites
- Julia 1.10 or higher
- For interactive graphics: OpenGL 3.3+ compatible graphics card and drivers
- For headless operation: No graphics hardware required

### Setup Instructions

1. **Install Julia**: Download from [julialang.org](https://julialang.org/downloads/)

2. **Clone the repository**:
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

## Backend Activation

PointController follows modern Makie.jl patterns where **users control backend activation**. You must activate a Makie backend before using PointController functions.

### Available Backends

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

### Configuration Options

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

## First Run

### Interactive Mode (Recommended)
```bash
# Start interactive session
julia --project=. -i start_interactive.jl

# Then in the Julia REPL, activate your preferred backend:
using GLMakie; GLMakie.activate!()
run_point_controller()
```

### Direct Execution
```bash
# Run with GLMakie (interactive)
julia run_glmakie.jl

# Run with CairoMakie (headless)
julia run_cairomakie.jl
```

### Manual Setup
```julia
# First, activate your preferred Makie backend
using GLMakie  # or CairoMakie, WGLMakie
GLMakie.activate!()

# Then use PointController
using PointController
run_point_controller()
```

## Controls

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