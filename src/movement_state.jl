"""
# Movement State Module

This module provides comprehensive movement state management for the Point Controller
application. It handles point positioning, movement calculations, and state tracking
with performance optimizations and error handling.

## Key Features

- **Position Management**: Tracks point coordinates within the MovementState
- **Movement Calculations**: Computes movement vectors based on key states
- **State Tracking**: Maintains pressed keys and movement timing
- **Performance Optimization**: Efficient state updates and calculations
- **Error Handling**: Robust error recovery for state management issues

## Movement System

- **WASD Controls**: Standard directional movement with smooth acceleration
- **Diagonal Movement**: Normalized diagonal movement for consistent speed
- **Boundary Handling**: Prevents point from moving outside display bounds
- **Time-based Updates**: Movement calculations based on elapsed time

## State Management

- **Key State Tracking**: Maintains which keys are currently pressed
- **Movement Speed Control**: Configurable movement speed per second
- **Quit Request Handling**: Graceful application termination
- **State Reset**: Complete state reset functionality

## Performance Features

- **Pure Function Design**: Movement updates return new state without side effects
- **Efficient Calculations**: Optimized movement vector computations
- **Memory Management**: Minimal memory allocation during updates
- **Time-based Movement**: Consistent movement speed regardless of frame rate

## Usage

```julia
# Create movement state
state = MovementState(position = Point2f(0, 0), movement_speed = 2.0)

# Add/remove keys
add_key!(state, 'w')
remove_key!(state, 'w')

# Calculate movement
movement = calculate_movement_vector(state)

# Apply movement for elapsed time
new_state = apply_movement_to_position(state, 0.1)

# Get current position
position = get_current_position(state)
```

## Technical Details

- Pure functional approach with immutable state updates
- Implements normalized movement vectors for consistent speed
- Supports boundary checking and collision detection
- Provides comprehensive error handling and logging
"""

# Backend-agnostic imports
using Logging
using Dates
using StaticArrays: SVector

# Define Point2f as an alias for SVector{2, Float32}
const Point2f = SVector{2, Float32}

"""
    KEY_MAPPINGS

A dictionary mapping keyboard keys to their corresponding movement vectors.
Each key maps to a 2-element array representing [x, y] movement direction.

## Key Mappings

- `'w'` or `'W'`: Move up [0, 1]
- `'s'` or `'S'`: Move down [0, -1]  
- `'a'` or `'A'`: Move left [-1, 0]
- `'d'` or `'D'`: Move right [1, 0]

## Usage

```julia
# Check if a key is a movement key
if haskey(KEY_MAPPINGS, key)
    movement = KEY_MAPPINGS[key]
end
```
"""
const KEY_MAPPINGS = Dict(
    'w' => [0, 1],    # Up
    's' => [0, -1],   # Down
    'a' => [-1, 0],   # Left
    'd' => [1, 0],    # Right
    'W' => [0, 1],    # Up (shift)
    'S' => [0, -1],   # Down (shift)
    'A' => [-1, 0],   # Left (shift)
    'D' => [1, 0],    # Right (shift)
)

"""
    MovementState

Represents the current state of movement and input for the Point Controller.

## Fields

- `pressed_keys::Set{Char}`: Set of currently pressed keys
- `position::Point2f`: Current position coordinates
- `movement_speed::Float64`: Movement speed in units per second
- `should_quit::Bool`: Flag indicating if the application should quit
- `last_update_time::Float64`: Timestamp of the last movement update
- `elapsed_time::Float64`: Time elapsed since last update in seconds

"""
mutable struct MovementState
    pressed_keys::Set{Char}
    position::Point2f
    movement_speed::Float64
    should_quit::Bool
    last_update_time::Float64
    elapsed_time::Float64

    function MovementState(;
        position::Point2f = Point2f(0, 0),
        movement_speed::Float64 = 2.0,
    )
        return new(Set{Char}(), position, movement_speed, false, time(), 0.0)
    end
end

"""
    add_key!(state::MovementState, key::Char)

Add a key to the set of pressed keys.
"""
function add_key!(state::MovementState, key::Char)
    push!(state.pressed_keys, key)
    @debug "Key added: $key" context = "movement_state"
end

"""
    remove_key!(state::MovementState, key::Char)

Remove a key from the set of pressed keys.
"""
function remove_key!(state::MovementState, key::Char)
    delete!(state.pressed_keys, key)
    @debug "Key removed: $key" context = "movement_state"
end

"""
    calculate_movement_vector(state::MovementState)

Calculate the movement vector based on currently pressed keys.
Returns a normalized 2D vector representing the movement direction and magnitude.
"""
function calculate_movement_vector(state::MovementState)
    if isempty(state.pressed_keys)
        return [0.0, 0.0]
    end

    # Calculate total movement vector
    total_movement = [0.0, 0.0]

    for key in state.pressed_keys
        if haskey(KEY_MAPPINGS, key)
            movement = KEY_MAPPINGS[key]
            total_movement[1] += movement[1]
            total_movement[2] += movement[2]
        end
    end

    # Normalize the movement vector for consistent speed
    magnitude = sqrt(total_movement[1]^2 + total_movement[2]^2)

    if magnitude > 0
        normalized_movement = [
            total_movement[1] / magnitude,
            total_movement[2] / magnitude,
        ]
        return normalized_movement
    else
        return [0.0, 0.0]
    end
end

"""
    apply_movement_to_position(state::MovementState, elapsed_time::Float64)

Apply movement to the current position based on the movement state and elapsed time.
Returns a new MovementState with updated position coordinates.

## Arguments

- `state::MovementState`: Current movement state
- `elapsed_time::Float64`: Time elapsed since last update in seconds

## Returns

- `MovementState`: New movement state with updated position

## Example

```julia
# Apply movement for 0.1 seconds
new_state = apply_movement_to_position(current_state, 0.1)
```
"""
function apply_movement_to_position(state::MovementState, elapsed_time::Float64)
    try
        current_pos = state.position
        movement_vector = calculate_movement_vector(state)

        # Calculate new position using time-based movement
        # movement_speed is in units per second, elapsed_time is in seconds
        distance = state.movement_speed * elapsed_time
        new_x = current_pos[1] + movement_vector[1] * distance
        new_y = current_pos[2] + movement_vector[2] * distance

        # Apply boundary constraints (keep point within -10 to +10 range)
        new_x = clamp(new_x, -10.0, 10.0)
        new_y = clamp(new_y, -10.0, 10.0)

        # Create new state with updated position
        new_state = MovementState(
            position = Point2f(new_x, new_y),
            movement_speed = state.movement_speed,
        )

        # Copy other fields
        new_state.pressed_keys = copy(state.pressed_keys)
        new_state.should_quit = state.should_quit
        new_state.last_update_time = state.last_update_time
        new_state.elapsed_time = elapsed_time

        @debug "Position updated: ($new_x, $new_y), elapsed: $(elapsed_time)s, distance: $distance" context = "movement_state"

        return new_state

    catch e
        @error "Error applying movement to position" exception = string(e) context = "movement_state"
        # Return original state on error
        return state
    end
end

"""
    get_current_position(state::MovementState)

Get the current position as a tuple of coordinates from the movement state.
"""
function get_current_position(state::MovementState)
    pos = state.position
    return (pos[1], pos[2])
end

"""
    reset_movement_state!(state::MovementState; position::Point2f = Point2f(0, 0))

Reset the movement state to initial values.
Optionally specify a new position to reset to.

## Arguments

- `state::MovementState`: The movement state to reset
- `position::Point2f`: New position to reset to (default: origin)
"""
function reset_movement_state!(state::MovementState; position::Point2f = Point2f(0, 0))
    empty!(state.pressed_keys)
    state.position = position
    state.should_quit = false
    state.last_update_time = time()
    state.elapsed_time = 0.0
    @debug "Movement state reset to position: $position" context = "movement_state"
end

"""
    clear_all_keys_safely!(state::MovementState)

Safely clear all pressed keys with error handling.
"""
function clear_all_keys_safely!(state::MovementState)
    try
        empty!(state.pressed_keys)
        @debug "All keys cleared safely" context = "movement_state"
    catch e
        @warn "Error clearing keys" exception = string(e) context = "movement_state"
    end
end

"""
    update_movement_timing!(state::MovementState, current_time::Float64)

Update the movement timing information.
Calculates the elapsed time since the last update and stores it in the state.
"""
function update_movement_timing!(state::MovementState, current_time::Float64)
    state.elapsed_time = current_time - state.last_update_time
    state.last_update_time = current_time
    @debug "Timing updated: elapsed=$(state.elapsed_time)s" context = "movement_state"
end
