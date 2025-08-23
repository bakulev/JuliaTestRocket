# Movement State Management
# This module handles the state of point movement and key tracking

"""
    MovementState

Mutable struct to track the current movement state of the point.
"""
mutable struct MovementState
    keys_pressed::Set{String}
    movement_speed::Float64
    last_update_time::Float64
    
    function MovementState(speed::Float64 = 1.0)
        new(Set{String}(), speed, 0.0)
    end
end

# Key mappings for WASD controls
const KEY_MAPPINGS = Dict(
    "w" => (0.0, 1.0),   # Up
    "s" => (0.0, -1.0),  # Down
    "a" => (-1.0, 0.0),  # Left
    "d" => (1.0, 0.0)    # Right
)

# Functions will be implemented in later tasks