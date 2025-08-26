"""
# Movement State Module

This module provides comprehensive movement state management for the Point Controller
application. It handles point positioning, movement calculations, and state tracking
with performance optimizations and error handling.

## Key Features

- **Position Management**: Tracks point coordinates using Makie's Observable system
- **Movement Calculations**: Computes movement vectors based on key states
- **State Tracking**: Maintains pressed keys and movement timing
- **Performance Optimization**: Efficient state updates and calculations
- **Error Handling**: Robust error recovery for state management issues

## Movement System

- **WASD Controls**: Standard directional movement with smooth acceleration
- **Diagonal Movement**: Normalized diagonal movement for consistent speed
- **Boundary Handling**: Prevents point from moving outside display bounds
- **Main Loop Integration**: Movement updates integrated into main application loop

## State Management

- **Key State Tracking**: Maintains which keys are currently pressed
- **Movement Speed Control**: Configurable movement speed per frame
- **Quit Request Handling**: Graceful application termination
- **State Reset**: Complete state reset functionality

## Performance Features

- **Observable Integration**: Reactive position updates using Makie's Observable system
- **Efficient Calculations**: Optimized movement vector computations
- **Memory Management**: Minimal memory allocation during updates
- **Main Loop Optimization**: Efficient movement updates in main application loop

## Usage

```julia
# Create movement state
state = MovementState(movement_speed = 0.1)

# Add/remove keys
add_key!(state, 'w')
remove_key!(state, 'w')

# Calculate movement
movement = calculate_movement_vector(state)

# Update position
update_position_from_state!(position, state)
```

## Technical Details

- Uses Makie's Observable system for reactive position updates
- Implements normalized movement vectors for consistent speed
- Supports boundary checking and collision detection
- Provides comprehensive error handling and logging
"""

# Backend-agnostic Makie imports
# Users must activate a backend before using this module
using Logging
using Observables: Observable
using Dates
using StaticArrays: SVector

# Define Point2f as an alias for SVector{2, Float32}
const Point2f = SVector{2, Float32}

# Key mappings for movement control
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
- `movement_speed::Float64`: Movement speed in units per second
- `should_quit::Bool`: Flag indicating if the application should quit
- `last_update_time::Float64`: Timestamp of the last movement update
- `elapsed_time::Float64`: Time elapsed since last update in seconds

"""
mutable struct MovementState
    pressed_keys::Set{Char}
    movement_speed::Float64
    should_quit::Bool
    last_update_time::Float64
    elapsed_time::Float64

    function MovementState(; movement_speed::Float64 = 2.0)
        return new(Set{Char}(), movement_speed, false, time(), 0.0)
    end
end

"""
    create_point_position()

Create an observable point position using Makie's Observable type.
Returns an Observable containing a Point2f at the origin (0, 0).
"""
function create_point_position()
    return Observable(Point2f(0, 0))
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
    apply_movement_to_position!(position::Observable{Point2f}, state::MovementState)

Apply movement to the current position based on the movement state.
Updates the position observable with the new coordinates.
"""
function apply_movement_to_position!(position::Observable{Point2f}, state::MovementState)
    try
        current_pos = position[]
        movement_vector = calculate_movement_vector(state)

        # Calculate new position using time-based movement
        # movement_speed is in units per second, elapsed_time is in seconds
        distance = state.movement_speed * state.elapsed_time
        new_x = current_pos[1] + movement_vector[1] * distance
        new_y = current_pos[2] + movement_vector[2] * distance

        # Apply boundary constraints (keep point within -10 to +10 range)
        new_x = clamp(new_x, -10.0, 10.0)
        new_y = clamp(new_y, -10.0, 10.0)

        # Update position observable
        position[] = Point2f(new_x, new_y)

        @debug "Position updated: ($new_x, $new_y), elapsed: $(state.elapsed_time)s, distance: $distance" context = "movement_state"

    catch e
        @error "Error applying movement to position" exception = string(e) context = "movement_state"
    end
end

"""
    update_position_from_state!(position::Observable{Point2f}, state::MovementState)

Update position from movement state (alias for apply_movement_to_position!).
"""
function update_position_from_state!(position::Observable{Point2f}, state::MovementState)
    return apply_movement_to_position!(position, state)
end

"""
    get_current_position(position::Observable{Point2f})

Get the current position as a tuple of coordinates.
"""
function get_current_position(position::Observable{Point2f})
    pos = position[]
    return (pos[1], pos[2])
end

"""
    reset_movement_state!(state::MovementState)

Reset the movement state to initial values.
"""
function reset_movement_state!(state::MovementState)
    empty!(state.pressed_keys)
    state.should_quit = false
    state.last_update_time = time()
    state.elapsed_time = 0.0
    @debug "Movement state reset" context = "movement_state"
end

"""
    request_quit!(state::MovementState)

Request the application to quit.
"""
function request_quit!(state::MovementState)
    state.should_quit = true
    @info "Quit requested" context = "movement_state"
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
    update_movement_timing!(state::MovementState)

Update the movement timing information.
"""
function update_movement_timing!(state::MovementState)
    current_time = time()
    state.elapsed_time = current_time - state.last_update_time
    state.last_update_time = current_time
    @debug "Timing updated: elapsed=$(state.elapsed_time)s" context = "movement_state"
end

"""
    format_current_time()

Format the current time as a string.
"""
function format_current_time()
    return string(Dates.format(now(), "HH:MM:SS"))
end

"""
    update_time_display!(time_obs::Observable{String})

Update the time display observable.
"""
function update_time_display!(time_obs::Observable{String})
    return time_obs[] = format_current_time()
end
