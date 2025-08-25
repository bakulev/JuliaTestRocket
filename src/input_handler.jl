"""
# Input Handler Module

This module provides comprehensive keyboard event processing and input validation
for the Point Controller application. It handles the translation of raw keyboard
events into application-specific actions with robust error handling.

## Key Features

- **Event Processing**: Handles GLMakie keyboard press and release events
- **Input Validation**: Validates and filters keyboard input for security
- **Error Recovery**: Graceful handling of invalid or unexpected input
- **State Integration**: Seamless integration with movement state management
- **Performance Optimization**: Efficient event processing with minimal overhead

## Supported Input

- **WASD Keys**: Primary movement controls (W=up, A=left, S=down, D=right)
- **Q Key**: Application quit command
- **Invalid Keys**: Gracefully ignored without error messages
- **Simultaneous Keys**: Multiple key presses for diagonal movement

## Event Flow

1. GLMakie generates keyboard events (press/release)
2. Input handler validates and processes the events
3. Valid movement keys update the movement state
4. Movement state triggers position updates via timer system
5. Invalid keys are silently ignored for user experience

## Usage

```julia
# Set up keyboard event handling
setup_keyboard_events!(figure, movement_state, point_position)

# Manual event processing (for testing)
handle_key_press("w", state)    # Process 'w' key press
handle_key_release("w", state)  # Process 'w' key release
```
"""

using GLMakie
using Logging

"""
    handle_key_press(key::String, state::MovementState)

Process a key press event and update the movement state with error handling.
Adds the key to the pressed keys set if it's a valid WASD key.
Handles quit request if 'q' key is pressed.
Gracefully handles invalid key inputs.
"""
function handle_key_press(key::String, state::MovementState)
    try
        # Validate input
        if isempty(key)
            return state  # Ignore empty key strings
        end
        
        key_lower = lowercase(string(key))  # Ensure string conversion
        
        # Handle quit key
        if key_lower == "q"
            log_user_action("Quit requested", "q key pressed")
            request_quit!(state)
            return state
        end
        
        # Only process WASD keys for movement
        if key_lower in keys(KEY_MAPPINGS)
            add_key!(state, key_lower)
            update_movement_timing!(state)
            log_user_action("Key pressed", key_lower)
        else
            # Silently ignore non-movement keys (don't spam console)
            # This handles invalid key inputs gracefully
        end
        
        return state
        
    catch e
        @warn "Error processing key press" exception=string(e) context="key_press"
        # Return state unchanged on error
        return state
    end
end

"""
    handle_key_release(key::String, state::MovementState)

Process a key release event and update the movement state with error handling.
Removes the key from the pressed keys set if it's a valid WASD key.
Gracefully handles invalid key inputs.
"""
function handle_key_release(key::String, state::MovementState)
    try
        # Validate input
        if isempty(key)
            return state  # Ignore empty key strings
        end
        
        key_lower = lowercase(string(key))  # Ensure string conversion
        
        # Only process WASD keys
        if key_lower in keys(KEY_MAPPINGS)
            remove_key!(state, key_lower)
            update_movement_timing!(state)
            log_user_action("Key released", key_lower)
        else
            # Silently ignore non-movement keys (don't spam console)
            # This handles invalid key inputs gracefully
        end
        
        return state
        
    catch e
        @warn "Error processing key release" exception=string(e) context="key_release"
        # Return state unchanged on error
        return state
    end
end



"""
    setup_keyboard_events!(fig::Figure, state::MovementState, position::Observable{Point2f}, time_obs::Union{Observable{String}, Nothing} = nothing)

Set up GLMakie keyboard event listeners for the given figure with timing integration and error handling.
Connects key press and release events to the movement state handlers and manages the movement timer.
Includes robust error handling for keyboard event processing.
If time_obs is provided, the timer will also update the time display.
"""
function setup_keyboard_events!(fig::Figure, state::MovementState, position::Observable{Point2f}, time_obs::Union{Observable{String}, Nothing} = nothing)
    # Set up key press event listener with error handling
    on(events(fig).keyboardbutton) do event
        try
            if event.action == Keyboard.press
                handle_key_press(string(event.key), state)
                # Start timer if movement begins or if timer is not running (for time updates)
                if state.update_timer === nothing
                    start_movement_timer!(state, position, time_obs)
                end
            elseif event.action == Keyboard.release
                handle_key_release(string(event.key), state)
                # Note: Timer continues running for time updates even when not moving
            end
        catch e
            @warn "Error in keyboard event handler" exception=string(e) context="event_handler"
            # Clear key states on error to prevent stuck keys
            clear_all_keys_safely!(state)
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