# Input Handler Module
# This module manages keyboard event processing and key state tracking

using GLMakie

"""
    handle_key_press(key::String, state::MovementState)

Process a key press event and update the movement state.
Adds the key to the pressed keys set if it's a valid WASD key.
"""
function handle_key_press(key::String, state::MovementState)
    key_lower = lowercase(key)
    
    # Only process WASD keys
    if key_lower in keys(KEY_MAPPINGS)
        add_key!(state, key_lower)
        println("Key pressed: $key_lower")  # Debug output
    end
    
    return state
end

"""
    handle_key_release(key::String, state::MovementState)

Process a key release event and update the movement state.
Removes the key from the pressed keys set if it's a valid WASD key.
"""
function handle_key_release(key::String, state::MovementState)
    key_lower = lowercase(key)
    
    # Only process WASD keys
    if key_lower in keys(KEY_MAPPINGS)
        remove_key!(state, key_lower)
        println("Key released: $key_lower")  # Debug output
    end
    
    return state
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
    setup_keyboard_events!(fig::Figure, state::MovementState)

Set up GLMakie keyboard event listeners for the given figure.
Connects key press and release events to the movement state handlers.
"""
function setup_keyboard_events!(fig::Figure, state::MovementState)
    # Set up key press event listener
    on(events(fig).keyboardbutton) do event
        if event.action == Keyboard.press
            handle_key_press(string(event.key), state)
        elseif event.action == Keyboard.release
            handle_key_release(string(event.key), state)
        end
    end
    
    return fig
end

"""
    is_movement_key(key::String)

Check if the given key is a valid movement key (WASD).
Returns true if the key is one of the movement keys, false otherwise.
"""
function is_movement_key(key::String)
    return lowercase(key) in keys(KEY_MAPPINGS)
end

"""
    get_pressed_keys(state::MovementState)

Get a copy of the currently pressed keys set.
Returns a Set{String} containing the currently pressed keys.
"""
function get_pressed_keys(state::MovementState)
    return copy(state.keys_pressed)
end