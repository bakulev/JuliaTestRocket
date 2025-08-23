# Movement State Management
# This module handles the state of point movement and key tracking

using GLMakie

"""
    MovementState

Mutable struct to track the current movement state of the point.
Includes key press tracking, movement speed, timing information, and quit flag.
"""
mutable struct MovementState
    keys_pressed::Set{String}
    movement_speed::Float64
    last_update_time::Float64
    is_moving::Bool
    update_timer::Union{Timer, Nothing}
    should_quit::Bool
    
    function MovementState(speed::Float64 = 1.0)
        new(Set{String}(), speed, 0.0, false, nothing, false)
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
    state.should_quit = false
    stop_movement_timer!(state)
    return state
end

"""
    request_quit!(state::MovementState)

Set the quit flag to request application exit.
"""
function request_quit!(state::MovementState)
    state.should_quit = true
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

"""
    apply_movement_to_position!(position::Observable{Point2f}, movement_vector::Tuple{Float64, Float64})

Apply a movement vector to the current position and update the observable.
Takes the current position and adds the movement vector components.
"""
function apply_movement_to_position!(position::Observable{Point2f}, movement_vector::Tuple{Float64, Float64})
    current_pos = get_current_position(position)
    new_x = current_pos[1] + movement_vector[1]
    new_y = current_pos[2] + movement_vector[2]
    update_point_position!(position, new_x, new_y)
    return position
end

"""
    calculate_movement_vector(state::MovementState)

Calculate the movement vector based on currently pressed keys.
Returns a tuple (dx, dy) representing the movement direction.
Handles diagonal movement when multiple keys are pressed simultaneously.
"""
function calculate_movement_vector(state::MovementState)
    dx = 0.0
    dy = 0.0
    
    # Sum up movement vectors for all currently pressed keys
    for key in state.keys_pressed
        if haskey(KEY_MAPPINGS, key)
            movement = KEY_MAPPINGS[key]
            dx += movement[1]
            dy += movement[2]
        end
    end
    
    # Normalize diagonal movement to maintain consistent speed
    if dx != 0.0 && dy != 0.0
        # Apply normalization factor for diagonal movement
        norm_factor = 1.0 / sqrt(2.0)
        dx *= norm_factor
        dy *= norm_factor
    end
    
    # Apply movement speed
    dx *= state.movement_speed
    dy *= state.movement_speed
    
    return (dx, dy)
end

"""
    update_position_from_state!(position::Observable{Point2f}, state::MovementState)

Update the point position based on the current movement state.
Calculates movement vector from pressed keys and applies it to the position.
"""
function update_position_from_state!(position::Observable{Point2f}, state::MovementState)
    if state.is_moving
        movement_vector = calculate_movement_vector(state)
        apply_movement_to_position!(position, movement_vector)
    end
    return position
end

"""
    start_movement_timer!(state::MovementState, position::Observable{Point2f}, update_interval::Float64 = 1/60)

Start a timer-based update loop for smooth continuous movement with error handling.
Creates a timer that updates the point position at regular intervals while keys are pressed.
Includes performance optimizations and robust error handling.
"""
function start_movement_timer!(state::MovementState, position::Observable{Point2f}, update_interval::Float64 = 1/60)
    try
        # Stop existing timer if running
        stop_movement_timer!(state)
        
        # Validate update interval for performance
        if update_interval <= 0.0 || update_interval > 1.0
            println("WARNING: Invalid update interval $update_interval, using default 1/60")
            update_interval = 1/60
        end
        
        # Create new timer for continuous updates with error handling
        state.update_timer = Timer(update_interval; interval=update_interval) do timer
            try
                current_time = time()
                
                # Update position if keys are pressed
                if state.is_moving && !isempty(state.keys_pressed)
                    # Calculate time-based movement for smooth animation
                    dt = current_time - state.last_update_time
                    if state.last_update_time > 0.0 && dt > 0.0 && dt < 1.0  # Sanity check on dt
                        # Scale movement by time delta for consistent speed
                        movement_vector = calculate_movement_vector(state)
                        # Performance optimization: limit movement scaling
                        scale_factor = min(dt * 60, 5.0)  # Cap scaling to prevent jumps
                        scaled_movement = (movement_vector[1] * scale_factor, movement_vector[2] * scale_factor)
                        apply_movement_to_position!(position, scaled_movement)
                    end
                end
                
                state.last_update_time = current_time
                
            catch timer_error
                println("WARNING: Error in movement timer: $(string(timer_error))")
                # Stop timer on error to prevent continuous errors
                stop_movement_timer!(state)
            end
        end
        
        return state
        
    catch e
        println("ERROR: Failed to start movement timer: $(string(e))")
        # Ensure timer is cleared on error
        state.update_timer = nothing
        return state
    end
end

"""
    stop_movement_timer!(state::MovementState)

Stop the movement timer and clean up resources with error handling.
"""
function stop_movement_timer!(state::MovementState)
    try
        if state.update_timer !== nothing
            close(state.update_timer)
            state.update_timer = nothing
        end
        return state
    catch e
        println("WARNING: Error stopping movement timer: $(string(e))")
        # Force clear timer reference even if close fails
        state.update_timer = nothing
        return state
    end
end

"""
    update_movement_timing!(state::MovementState)

Update timing information when movement state changes.
Should be called when keys are pressed or released.
"""
function update_movement_timing!(state::MovementState)
    state.last_update_time = time()
    return state
end

"""
    clear_all_keys_safely!(state::MovementState)

Safely clear all pressed keys and stop movement.
Used for robustness when window loses focus or on errors.
"""
function clear_all_keys_safely!(state::MovementState)
    try
        empty!(state.keys_pressed)
        state.is_moving = false
        stop_movement_timer!(state)
        println("All key states cleared safely.")
        return state
    catch e
        println("WARNING: Error clearing key states: $(string(e))")
        # Force reset even if there's an error
        state.keys_pressed = Set{String}()
        state.is_moving = false
        return state
    end
end