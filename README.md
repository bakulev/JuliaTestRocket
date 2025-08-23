# Point Controller

An interactive Julia application that displays a controllable point using GLMakie visualization. Control the point's movement using WASD keys with real-time coordinate updates.

## Features

- Interactive point visualization using GLMakie
- WASD keyboard controls for point movement
- Real-time coordinate display
- Smooth continuous movement while keys are held
- Diagonal movement support for simultaneous key presses

## Installation

1. Ensure you have Julia 1.6+ installed
2. Clone or download this project
3. Navigate to the project directory
4. Activate the project environment:
   ```julia
   using Pkg
   Pkg.activate(".")
   Pkg.instantiate()
   ```

## Usage

```julia
using PointController
run_point_controller()
```

```bash
julia --project=. demo_visualization.jl
```

## Controls

- **W**: Move point up (positive Y direction)
- **S**: Move point down (negative Y direction)  
- **A**: Move point left (negative X direction)
- **D**: Move point right (positive X direction)

Multiple keys can be pressed simultaneously for diagonal movement.

## Project Structure

```
PointController/
├── Project.toml              # Package configuration and dependencies
├── README.md                 # This file
├── src/
│   ├── PointController.jl    # Main module
│   ├── movement_state.jl     # Movement state management
│   ├── input_handler.jl      # Keyboard input processing
│   └── visualization.jl      # GLMakie visualization setup
└── test/
    ├── runtests.jl          # Test runner
    ├── test_movement.jl     # Movement state tests
    └── test_input.jl        # Input handler tests
```

## Development

To run tests:
```julia
using Pkg
Pkg.test()
```
From command line:
```bash
julia --project=. test/runtests.jl
```

## Requirements

- Julia 1.6+
- GLMakie.jl
- OpenGL 3.3+ compatible graphics card