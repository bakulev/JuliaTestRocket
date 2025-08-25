# Getting Started

## Installation

### Prerequisites
- Julia 1.10 or higher
- OpenGL 3.3+ compatible graphics card and drivers
- Working display system (X11, Wayland, or native windowing)

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

4. **Verify installation**:
   ```bash
   julia --project=. verify_installation.jl
   ```

## Backend Activation

PointController follows modern Makie.jl patterns where users control backend activation. 
**You must activate GLMakie before using PointController functions:**

```julia
using GLMakie
GLMakie.activate!()  # Required before using PointController
```

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

```julia
# First, activate the GLMakie backend
using GLMakie
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