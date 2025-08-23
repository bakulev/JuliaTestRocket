# Input Handler Module
# This module manages keyboard event processing and key state tracking

using GLMakie

"""
    handle_key_press(key::String, state::MovementState)

Process a key press event and update the movement state.
Adds the key to the pressed keys set if it's a valid WASD key.
Handles quit request if 'q' key is pressed.
"""
function handle_key_press(key::String, state::MovementState)
    key_lower = lowercase(key)
    
    # Handle quit key
    if key_lower == "q"
        println("Quit requested by user (q key pressed)")
        request_quit!(state)
        return state
    end
    
    # Only process WASD keys for movement
    if key_lower in keys(KEY_MAPPINGS)
        add_key!(state, key_lower)
        update_movement_timing!(state)
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
        update_movement_timing!(state)
        println("Key released: $key_lower")  # Debug output
    end
    
    return state
end



"""
    setup_keyboard_events!(fig::Figure, state::MovementState, position::Observable{Point2f})

Set up GLMakie keyboard event listeners for the given figure with timing integration.
Connects key press and release events to the movement state handlers and manages the movement timer.
"""
function setup_keyboard_events!(fig::Figure, state::MovementState, position::Observable{Point2f})
    # Set up key press event listener
    on(events(fig).keyboardbutton) do event
        if event.action == Keyboard.press
            handle_key_press(string(event.key), state)
            # Start timer if movement begins
            if state.is_moving && state.update_timer === nothing
                start_movement_timer!(state, position)
            end
        elseif event.action == Keyboard.release
            handle_key_release(string(event.key), state)
            # Stop timer if no keys are pressed
            if !state.is_moving
                stop_movement_timer!(state)
            end
        end
    end
    
    return fig
end

"""
    setup_keyboard_events!(fig::Figure, state::MovementState)

Legacy version for backward compatibility - delegates to the new version.
Note: This version won't have continuous movement without position parameter.
"""
function setup_keyboard_events!(fig::Figure, state::MovementState)
    # Set up key press event listener (basic version without timing)
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