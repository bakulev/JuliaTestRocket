"""
# Input Handler Module

This module provides comprehensive keyboard event processing and input validation
for the Point Controller application. It handles the translation of raw keyboard
events into application-specific actions with robust error handling.

## Key Features

- **Event Processing**: Handles Makie keyboard press and release events
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

1. Makie generates keyboard events (press/release)
2. Input handler validates and processes the events
3. Valid movement keys update the movement state
4. Movement state triggers position updates via main application loop
5. Invalid keys are silently ignored for user experience

## Usage

```julia
# Set up keyboard event handling
setup_keyboard_events!(figure, movement_state, point_position)

# Manual event processing (for testing)
handle_key_press('w', state)    # Process 'w' key press
handle_key_release('w', state)  # Process 'w' key release
```
"""

# Backend-agnostic imports
# Users must activate a backend before using this module
using Logging

"""
    handle_key_press(key::Char, state::MovementState)

Process a key press event and update the movement state with error handling.
Adds the key to the pressed keys set if it's a valid WASD key.
Handles quit request if 'q' key is pressed.
Gracefully handles invalid key inputs.
"""
function handle_key_press(key::Char, state::MovementState)
    try
        # Handle quit key
        if lowercase(key) == 'q'
            log_user_action("Quit requested", "q key pressed")
            request_quit!(state)
            return state
        end

        # Only process WASD keys for movement
        if haskey(KEY_MAPPINGS, key)
            add_key!(state, key)
            log_user_action("Key pressed", string(key))
            @debug "Key pressed: $key, pressed keys: $(state.pressed_keys)" context = "key_press"
        else
            # Silently ignore non-movement keys (don't spam console)
            # This handles invalid key inputs gracefully
            @debug "Ignored key: $key" context = "key_press"
        end

        return state

    catch e
        @warn "Error processing key press" exception=string(e) context="key_press"
        # Return state unchanged on error
        return state
    end
end

"""
    handle_key_release(key::Char, state::MovementState)

Process a key release event and update the movement state with error handling.
Removes the key from the pressed keys set if it's a valid WASD key.
Gracefully handles invalid key inputs.
"""
function handle_key_release(key::Char, state::MovementState)
    try
        # Only process WASD keys for movement
        if haskey(KEY_MAPPINGS, key)
            remove_key!(state, key)
            log_user_action("Key released", string(key))
            @debug "Key released: $key, pressed keys: $(state.pressed_keys)" context = "key_release"
        else
            # Silently ignore non-movement keys (don't spam console)
            # This handles invalid key inputs gracefully
            @debug "Ignored key release: $key" context = "key_release"
        end

        return state

    catch e
        @warn "Error processing key release" exception=string(e) context="key_release"
        # Return state unchanged on error
        return state
    end
end

"""
    is_movement_key(key::Char)

Check if a key is a valid movement key (WASD).
Returns true if the key is in the KEY_MAPPINGS dictionary.
"""
function is_movement_key(key::Char)
    return haskey(KEY_MAPPINGS, key)
end

"""
    get_pressed_keys(state::MovementState)

Get a copy of the currently pressed keys.
Returns a Set{Char} containing all currently pressed movement keys.
"""
function get_pressed_keys(state::MovementState)
    return copy(state.pressed_keys)
end

"""
    setup_keyboard_events!(fig, state::MovementState, position::Observable{Point2f}, time_obs::Union{Observable{String}, Nothing} = nothing)

Set up keyboard event handlers for the Makie figure with comprehensive error handling.
Connects key press and release events to the movement state management system.
Includes performance optimizations and robust error recovery.

Note: This function requires a Makie backend to be activated and will only work
when called from a context where Makie types are available.
"""
function setup_keyboard_events!(
    fig,
    state::MovementState,
    position::Observable{Point2f},
    time_obs::Union{Observable{String}, Nothing} = nothing,
)
    try
        # Set up key press event handler
        # This will only work if Makie is available
        Main.on(Main.events(fig).keyboardbutton) do event
            try
                # Convert Makie key (Symbol) to Char for our system
                key_string = string(event.key)
                key_char = first(key_string)

                if event.action == Main.Keyboard.press
                    handle_key_press(key_char, state)
                elseif event.action == Main.Keyboard.release
                    handle_key_release(key_char, state)
                end
            catch event_error
                @warn "Error in keyboard event handler" exception=string(event_error) context="keyboard_events"
            end
        end

        @debug "Keyboard event handlers set up successfully" context="input_handler"
        return fig

    catch e
        @error "Failed to set up keyboard events" exception=string(e) context="keyboard_setup"
        rethrow(e)
    end
end
