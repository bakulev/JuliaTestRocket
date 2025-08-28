# Examples

## Basic Usage

### Simple Point Control

```julia
using GLMakie
GLMakie.activate!()
using PointController

# Start the application
run_point_controller()
```

### Custom Movement Speed

```julia
using GLMakie
GLMakie.activate!()
using PointController

# Create a movement state with custom speed
state = MovementState(movement_speed = 0.05)  # Slower movement

# You can also create faster movement
fast_state = MovementState(movement_speed = 0.2)  # Faster movement
```

### Programmatic Key Handling

```julia
using PointController

# Create a movement state
state = MovementState()

# Add keys programmatically
add_key!(state, 'w')
add_key!(state, 'd')

# Calculate movement vector
movement = calculate_movement_vector(state)
println("Movement vector: $movement")

# Remove keys
remove_key!(state, 'w')
remove_key!(state, 'd')
```

## Advanced Usage

### Custom Backend Configuration

```julia
using GLMakie

# Configure GLMakie for high-performance rendering
GLMakie.activate!(
    title = "High Performance Point Controller",
    vsync = false,           # Disable vsync for maximum FPS
    fxaa = true              # Enable anti-aliasing
)

using PointController
run_point_controller()
```

### Development and Testing

```julia
using GLMakie
GLMakie.activate!(debugging = true)

using PointController

# Test individual components
state = MovementState(movement_speed = 1.0)
@assert is_movement_key('w') == true
@assert is_movement_key('x') == false

# Test movement calculations
add_key!(state, 'w')
add_key!(state, 'd')
movement = calculate_movement_vector(state)
@assert movement ≈ [0.7071, 0.7071] atol=0.001  # Normalized diagonal
```

## Integration Examples

### Using with Other Packages

```julia
using GLMakie
GLMakie.activate!()
using PointController
using Plots  # For additional plotting

# You can use PointController alongside other visualization packages
# Just make sure GLMakie is activated first

# Run the point controller
run_point_controller()

# After closing, you can use other plotting packages
# (Note: You may need to switch backends for other packages)
```

### Batch Processing

```julia
using GLMakie
GLMakie.activate!()
using PointController

# Function to run multiple sessions
function run_multiple_sessions(n_sessions::Int)
    for i in 1:n_sessions
        println("Starting session $i of $n_sessions")
        run_point_controller()
        println("Session $i completed")
    end
end

# Run 3 sessions
run_multiple_sessions(3)
```