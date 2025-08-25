# JuliaTestRocket

```@meta
CurrentModule = PointController
```

An interactive Julia application that displays a controllable point using GLMakie visualization. Control the point's movement using WASD keys with real-time coordinate updates and smooth continuous movement.

![PointController Application](../assets/WorkingApp.png)

## Features

- **Interactive Point Visualization**: Real-time point rendering using GLMakie
- **WASD Keyboard Controls**: Intuitive movement controls with immediate response
- **Real-time Coordinate Display**: Live coordinate updates as the point moves
- **Smooth Continuous Movement**: Fluid movement while keys are held down
- **Diagonal Movement Support**: Natural diagonal movement when multiple keys are pressed
- **Robust Error Handling**: Comprehensive error handling for graphics and input issues
- **Performance Optimized**: Efficient rendering and input processing

## Quick Start

```julia
# First, activate the GLMakie backend
using GLMakie
GLMakie.activate!()

# Then use PointController
using PointController
run_point_controller()
```

## Installation

```julia
using Pkg
Pkg.add(url="https://github.com/bakulev/JuliaTestRocket")
```

Or clone the repository:

```bash
git clone https://github.com/bakulev/JuliaTestRocket.git
cd JuliaTestRocket
julia --project=. -e "using Pkg; Pkg.instantiate()"
```

## System Requirements

- Julia 1.10 or higher
- OpenGL 3.3+ compatible graphics card and drivers
- Working display system (X11, Wayland, or native windowing)

## Contents

```@contents
Pages = ["getting-started.md", "api.md", "examples.md", "troubleshooting.md"]
```