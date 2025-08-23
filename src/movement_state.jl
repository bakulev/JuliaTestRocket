# Movement State Management
# This module handles the state of point movement and key tracking

using GLMakie

"""
    MovementState

Mutable struct to track the current movement state of the point.
Includes key press tracking, movement speed, and timing information.
"""
mutable struct MovementState
    keys_pressed::Set{String}
    movement_speed::Float64
    last_update_time::Float64
    is_moving::Bool
    
    function MovementState(speed::Float64 = 1.0)
        new(Set{String}(), speed, 0.0, false)
    end
end

"""
    reset_movement_state!(state::MovementState)

Reset the movement state to initial conditions.
"""
function reset_movement_state!(state::MovementState)
    empty!(state.keys_pressed)
    state.is_moving = false
    state.last_update_time = 0.0
    return state
end

"""
    add_key!(state::MovementState, key::String)

Add a key to the currently pressed keys set.
"""
function add_key!(state::MovementState, key::String)
    push!(state.keys_pressed, lowercase(key))
    state.is_moving = !isempty(state.keys_pressed)
    return state
end

"""
    remove_key!(state::MovementState, key::String)

Remove a key from the currently pressed keys set.
"""
function remove_key!(state::MovementState, key::String)
    delete!(state.keys_pressed, lowercase(key))
    state.is_moving = !isempty(state.keys_pressed)
    return state
end

# Key mappings for WASD controls
const KEY_MAPPINGS = Dict{String, Tuple{Float64, Float64}}(
    "w" => (0.0, 1.0),   # Up
    "s" => (0.0, -1.0),  # Down
    "a" => (-1.0, 0.0),  # Left
    "d" => (1.0, 0.0)    # Right
)

"""
    create_point_position()

Create an observable point position using GLMakie's Observable type.
Returns an Observable containing a Point2f initialized at origin (0, 0).
"""
function create_point_position()
    return Observable(Point2f(0.0, 0.0))
end

"""
    update_point_position!(position::Observable{Point2f}, x::Float64, y::Float64)

Update the observable point position with new coordinates.
"""
function update_point_position!(position::Observable{Point2f}, x::Float64, y::Float64)
    position[] = Point2f(x, y)
    return position
end

"""
    get_current_position(position::Observable{Point2f})

Get the current position as a tuple (x, y).
"""
function get_current_position(position::Observable{Point2f})
    pos = position[]
    return (pos[1], pos[2])
end