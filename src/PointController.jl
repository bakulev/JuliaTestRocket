"""
# PointController.jl

An interactive Julia application for controlling a point using WASD keyboard inputs
with real-time Makie visualization. This module provides a complete implementation
of an event-driven point controller with smooth movement, error handling, and
performance optimizations.

## Main Components

- **Movement State Management**: Tracks key presses and point position
- **Input Handling**: Processes keyboard events with validation
- **Visualization**: Makie-based rendering with real-time updates
- **Error Handling**: Comprehensive error recovery and user feedback

## Usage

```julia
# First, activate a Makie backend (GLMakie for interactive, CairoMakie for headless)
using GLMakie
GLMakie.activate!()

# Then use PointController
using PointController
run_point_controller()  # Start the interactive application
```

## Backend Activation

PointController requires a Makie backend to be activated before use. This follows modern Makie.jl 
patterns where users control backend activation:

```julia
# For interactive use (requires display)
using GLMakie
GLMakie.activate!()

# For headless/CI use (no display required)
using CairoMakie
CairoMakie.activate!()

# Then use PointController
using PointController
run_point_controller()
```

You can also customize the backend with options:
```julia
GLMakie.activate!(
    title = "My Point Controller",
    vsync = true,
    framerate = 60.0
)
```

## Architecture

The application follows a modular, event-driven architecture:
1. Makie provides the windowing and rendering system
2. Observable patterns handle real-time coordinate updates
3. Main loop-based movement ensures smooth animation
4. Comprehensive error handling provides robustness

## Author: Point Controller Development Team
## Version: 0.1.0
## License: MIT
"""
module PointController

# Core dependencies
using Logging
using Observables: Observable

# Export public API - functions and types that users and tests need
export run_point_controller, KEY_MAPPINGS
# Export movement state types and functions
export MovementState,
    add_key!,
    remove_key!, calculate_movement_vector, reset_movement_state!, request_quit!
export clear_all_keys_safely!, update_movement_timing!
export format_current_time
# Export input handler functions  
export handle_key_press,
    handle_key_release, is_movement_key, get_pressed_keys, setup_keyboard_events!
# Export visualization functions
export create_visualization,
    get_current_position
export apply_movement_to_position, setup_visualization_window
export update_coordinate_display!, create_time_observable
export close_all_windows

# Export logging functions
export setup_logging, get_current_log_level
export log_application_start, log_application_stop, log_glmakie_activation
export log_component_initialization, log_user_action
export log_error_with_context, log_warning_with_context
# Backend detection helpers are no longer part of the public API

# Include component modules
# Each module handles a specific aspect of the application
include("logging_config.jl")    # Logging configuration and utilities
include("movement_state.jl")    # Point position and movement state management
include("input_handler.jl")     # Keyboard event processing and validation  
include("visualization.jl")     # Makie visualization setup and rendering

"""
    run_point_controller()

Main entry point for the Point Controller application.
Creates an interactive window with a controllable point using WASD keys.

## Prerequisites

A Makie backend must be activated before calling this function:
```julia
# For interactive use
using GLMakie
GLMakie.activate!()

# For headless use
using CairoMakie
CairoMakie.activate!()

using PointController
run_point_controller()
```

## Features

- Interactive point control with WASD keys
- Real-time coordinate display
- Comprehensive error handling and robustness
- Modern Makie integration following best practices
"""
function run_point_controller()

    # Initialize logging system
    setup_logging(Logging.Info)
    log_application_start()

    local movement_state = nothing
    local fig = nothing

    try
        # Initialize backend with error handling
        log_component_initialization("Makie backend")
        if !initialize_backend_safely()
            error(
                "Failed to initialize Makie backend. Please check your graphics drivers and backend support.",
            )
        end

        # Initialize all components with error handling
        log_component_initialization("visualization")
        fig, ax, point_position, coordinate_text, time_obs = create_visualization_safely()

        # Create movement state and key state
        log_component_initialization("movement state")
        # Movement speed in units per second
        movement_state = MovementState(movement_speed = 1.5)

        # Create key state for handling keyboard input
        key_state = KeyState()

        # Set up Makie window with proper configuration and error handling
        log_component_initialization("window")
        try
            setup_visualization_window(fig)
        catch e
            log_error_with_context("Failed to display window", "window_setup", e)
            @error "This may indicate window system compatibility issues"
            rethrow(e)
        end

        # Connect all event handlers with error handling
        log_component_initialization("keyboard event handlers")
        try
            @info "Setting up keyboard events..."
            setup_keyboard_events!(fig, key_state, point_position, time_obs)
            @info "Keyboard events set up successfully"
        catch e
            log_error_with_context("Failed to set up keyboard events", "keyboard_setup", e)
            @warn "Keyboard input may not work properly"
            # Don't rethrow - application can still run without keyboard events
        end

        # Movement updates are now handled in the main loop for better responsiveness
        log_component_initialization("update timer")

        # Set up window focus handling for robustness
        setup_window_focus_handling!(fig, movement_state)

        # Ensure the window is displayed and focused
        @info "Window setup complete. Application is ready for interaction."

        # Start the application loop
        @info "Point Controller is ready! Use WASD keys to move the point. Press 'q' to quit or close the window to exit."

        # Keep the application running and responsive
        # Makie handles the event loop internally, so we just need to keep the process alive
        # and ensure proper cleanup when the window is closed

        # Set up window close handler for proper cleanup
        Main.on(Main.events(fig).window_open) do is_open
            if !is_open
                @info "Window closed. Cleaning up..."
                cleanup_application_safely(movement_state)
                log_application_stop()
            end
        end

        # Main application loop - handle movement updates and window events
        last_update_time = time()
        update_interval = 1/60  # 60 FPS

        while Main.events(fig).window_open[] && !key_state.should_quit
            current_time = time()

            # Update movement and time display at 60 FPS
            if current_time - last_update_time >= update_interval

                # Update time display
                time_obs[] = format_current_time(current_time)

                # Copy key state to movement state at the beginning of each cycle
                copy_key_state_to_movement_state!(movement_state, key_state)

                # Update timing
                update_movement_timing!(movement_state, current_time)

                # Update position based on current key states
                movement_state =
                    apply_movement_to_position(movement_state, movement_state.elapsed_time)
                point_position[] = movement_state.position

                # Debug: log movement updates (occasionally)
                if rand() < 0.01  # 1% chance to log
                    @debug "Main loop update: position = $(point_position[]), keys = $(movement_state.pressed_keys)" context = "main_loop"
                end

                last_update_time = current_time
            end

            # Check if quit was requested and break immediately
            if key_state.should_quit
                @info "Quit detected in main loop, breaking..."
                break
            end

            # Debug: occasionally log the quit state
            if rand() < 0.001  # Very rare logging to avoid spam
                @debug "Main loop quit state: $(key_state.should_quit)" context = "main_loop"
            end

            sleep(0.01)  # Small sleep to prevent busy waiting but allow responsive updates
        end

        # Handle quit request
        @info "Main loop ended. Checking quit state: $(key_state.should_quit)"
        if key_state.should_quit
            @info "Exiting application..."
            # Close the window if quit was requested via 'q' key
            cleanup_application_safely(movement_state)
            # Close all windows (backend-agnostic)
            close_all_windows()
        else
            @info "Application ended without quit request"
        end

    catch e
        handle_application_error(e, movement_state, fig)
        rethrow(e)
    end

    return log_application_stop()
end

"""
    initialize_backend_safely()

Check if Makie backend is properly activated and available.
Returns true if backend is ready to use, false otherwise.

Note: Users must call backend.activate!() before using PointController functions.
"""
function initialize_backend_safely()
    try
        # Check if backend is available and activated
        # This will fail if backend.activate!() hasn't been called by the user

        # Test basic Makie functionality to ensure backend is working
        test_fig = Main.Figure(size = (100, 100))
        # Note: Figures don't need explicit closing in modern Makie

        @info "Makie backend is ready and functional"
        return true

    catch e
        if contains(string(e), "backend") || contains(string(e), "activate")
            log_error_with_context(
                "Makie backend not activated",
                "backend_initialization",
                e,
            )
            @error "Please call a Makie backend activate function before using PointController:"
            @error "  using GLMakie; GLMakie.activate!()  # for interactive use"
            @error "  using CairoMakie; CairoMakie.activate!()  # for headless use"
        elseif contains(string(e), "OpenGL") || contains(string(e), "GL")
            log_error_with_context("OpenGL initialization failed", "graphics_system", e)
            @error "This usually indicates:"
            @error "  - Outdated graphics drivers"
            @error "  - Insufficient OpenGL version (3.3+ required)"
            @error "  - Missing graphics hardware acceleration"
            @error "Please update your graphics drivers and ensure OpenGL 3.3+ support."
        elseif contains(string(e), "display") || contains(string(e), "DISPLAY")
            log_error_with_context("Display system not available", "display_system", e)
            @error "This usually indicates:"
            @error "  - Running in headless environment without display"
            @error "  - X11 forwarding not enabled (if using SSH)"
            @error "  - Wayland compatibility issues"
            @error "Please ensure you have a working display system or use CairoMakie for headless operation."
        else
            log_error_with_context("Makie backend check failed", "backend_check", e)
            @error "Make sure to activate a Makie backend before using PointController:"
            @error "  GLMakie.activate!() or CairoMakie.activate!()"
        end
        return false
    end
end

"""
    create_visualization_safely()

Create visualization with error handling and performance optimizations.
"""
function create_visualization_safely()
    try
        return create_visualization()
    catch e
        log_error_with_context(
            "Failed to create visualization",
            "visualization_creation",
            e,
        )
        @error "This may indicate insufficient graphics memory or rendering capabilities"
        rethrow(e)
    end
end

"""
    copy_key_state_to_movement_state!(movement_state::MovementState, key_state::KeyState)

Copy the key state information from KeyState to MovementState.
This is called at the beginning of each main loop cycle to sync the states.
"""
function copy_key_state_to_movement_state!(
    movement_state::MovementState,
    key_state::KeyState,
)
    # Copy pressed keys
    empty!(movement_state.pressed_keys)
    union!(movement_state.pressed_keys, key_state.pressed_keys)

    # Copy quit state
    movement_state.should_quit = key_state.should_quit

    @debug "Copied key state to movement state: keys=$(key_state.pressed_keys), quit=$(key_state.should_quit)" context = "state_sync"
end

"""
    setup_window_focus_handling!(fig, state::MovementState)

Set up window focus change handling for robustness.
Ensures proper behavior when window loses/gains focus.
"""
function setup_window_focus_handling!(fig, state::MovementState)
    try
        # Handle window focus changes
        Main.on(Main.events(fig).hasfocus) do has_focus
            if !has_focus
                # Clear all pressed keys when window loses focus
                # This prevents "stuck" keys when focus is lost while keys are pressed
                @debug "Window lost focus - clearing key states for safety"
                clear_all_keys_safely!(state)

            else
                @debug "Window gained focus"
            end
        end

        @debug "Window focus handling set up successfully"
        return fig

    catch e
        log_warning_with_context("Could not set up window focus handling", "focus_handling")
        @warn "Application will continue but may have issues with focus changes"
        # Don't rethrow - this is not critical for basic functionality
        return fig
    end
end

"""
    handle_application_error(e::Exception, movement_state, fig)

Centralized error handling for the application.
Provides clear error messages and performs cleanup.
"""
function handle_application_error(e::Exception, movement_state, fig)
    log_error_with_context("Point Controller encountered an error", "application_error", e)

    if isa(e, InterruptException)
        @info "Application interrupted by user (Ctrl+C)"
    elseif contains(string(e), "OpenGL") || contains(string(e), "GL")
        log_error_with_context("OpenGL/Graphics error", "graphics_error", e)
        @error "This may indicate graphics driver or hardware issues"
    elseif contains(string(e), "OutOfMemoryError")
        log_error_with_context("Out of memory error", "memory_error", e)
        @error "Try closing other applications to free up memory"
    else
        log_error_with_context("Unexpected error", "unknown_error", e)
        @error "Error type: $(typeof(e))"
    end

    # Attempt cleanup
    return cleanup_application_safely(movement_state)
end

"""
    cleanup_application_safely(movement_state)

Safely clean up application resources with error handling.
"""
function cleanup_application_safely(movement_state)
    try
        if movement_state !== nothing
            clear_all_keys_safely!(movement_state)
        end
        @info "Application cleanup completed"
    catch cleanup_error
        log_warning_with_context("Error during cleanup", "cleanup", cleanup_error)
        # Continue cleanup despite errors
    end
end

"""
    close_all_windows()

Close all Makie windows in a backend-agnostic way.
"""
function close_all_windows()
    try
        # Try GLMakie.closeall() if GLMakie is loaded; otherwise rely on figure close events
        try
            eval(Meta.parse("GLMakie.closeall()"))
        catch
            # Ignore if GLMakie is not available; other backends manage window lifecycle themselves
        end
    catch e
        @warn "Could not close windows: $e"
    end
end

"""
    format_current_time(timestamp::Float64 = time())

Format the given timestamp as a string in HH:MM:SS format.
Returns a string representation of the time.

# Arguments
- `timestamp::Float64`: Unix timestamp to format (default: current time)

# Returns
- `String`: Time in HH:MM:SS format

# Examples
```julia
time_str = format_current_time()  # Current time
time_str = format_current_time(1234567890.0)  # Specific timestamp
```
"""
function format_current_time(timestamp::Float64 = time())
    try
        # Convert Unix timestamp to DateTime and format it
        current_datetime = Dates.unix2datetime(timestamp)
        return Dates.format(current_datetime, "HH:MM:SS")
    catch e
        @warn "Error formatting timestamp" exception = string(e) context = "time_formatting"
        return "00:00:00"  # Fallback time
    end
end

"""
    create_time_observable()

Create an Observable that contains the current time as a formatted string.
Returns an Observable{String} that can be updated with current time.

# Returns
- `Observable{String}`: Observable containing current time in HH:MM:SS format

# Examples
```julia
time_obs = create_time_observable()
time_obs[] = format_current_time()  # Update with current time
```
"""
function create_time_observable()
    return Observable(format_current_time())
end

end # module PointController
