"""
# PointController.jl

An interactive Julia application for controlling a point using WASD keyboard inputs
with real-time GLMakie visualization. This module provides a complete implementation
of an event-driven point controller with smooth movement, error handling, and
performance optimizations.

## Main Components

- **Movement State Management**: Tracks key presses and point position
- **Input Handling**: Processes keyboard events with validation
- **Visualization**: GLMakie-based rendering with real-time updates
- **Error Handling**: Comprehensive error recovery and user feedback

## Usage

```julia
# First, activate the GLMakie backend
using GLMakie
GLMakie.activate!()

# Then use PointController
using PointController
run_point_controller()  # Start the interactive application
```

## Backend Activation

PointController requires GLMakie to be activated before use. This follows modern Makie.jl 
patterns where users control backend activation:

```julia
using GLMakie
GLMakie.activate!()  # Must be called before using PointController functions
```

You can also customize the GLMakie backend with options:
```julia
GLMakie.activate!(
    title = "My Point Controller",
    vsync = true,
    framerate = 60.0
)
```

## Architecture

The application follows a modular, event-driven architecture:
1. GLMakie provides the windowing and rendering system
2. Observable patterns handle real-time coordinate updates
3. Timer-based movement ensures smooth animation
4. Comprehensive error handling provides robustness

## Author: Point Controller Development Team
## Version: 0.1.0
## License: MIT
"""
module PointController

using GLMakie

# Export public API - functions and types that users and tests need
export run_point_controller, MovementState, KEY_MAPPINGS
# Export movement state functions
export add_key!, remove_key!, calculate_movement_vector, reset_movement_state!, request_quit!
export clear_all_keys_safely!, update_movement_timing!
# Export input handler functions  
export handle_key_press, handle_key_release, is_movement_key, get_pressed_keys, setup_keyboard_events!
# Export visualization functions
export create_visualization, create_point_position, update_point_position!, get_current_position
export apply_movement_to_position!, update_position_from_state!, setup_visualization_window
export update_coordinate_display!
# Export timer functions
export start_movement_timer!, stop_movement_timer!

# Include component modules
# Each module handles a specific aspect of the application
include("movement_state.jl")    # Point position and movement state management
include("input_handler.jl")     # Keyboard event processing and validation  
include("visualization.jl")     # GLMakie visualization setup and rendering

"""
    run_point_controller()

Main entry point for the Point Controller application.
Creates an interactive window with a controllable point using WASD keys.

## Prerequisites

GLMakie backend must be activated before calling this function:
```julia
using GLMakie
GLMakie.activate!()
using PointController
run_point_controller()
```

## Features

- Interactive point control with WASD keys
- Real-time coordinate display
- Comprehensive error handling and robustness
- Modern GLMakie integration following best practices
"""
function run_point_controller()
    println("Starting Point Controller...")
    
    local movement_state = nothing
    local fig = nothing

    try
        # Initialize GLMakie with error handling
        println("Initializing GLMakie backend...")
        if !initialize_glmakie_safely()
            error("Failed to initialize GLMakie. Please check your graphics drivers and OpenGL support.")
        end

        # Initialize all components with error handling
        println("Initializing visualization...")
        fig, ax, point_position, coordinate_text = create_visualization_safely()

        # Create movement state
        println("Setting up movement state...")
        movement_state = MovementState(movement_speed = 0.1)  # Movement speed of 0.1 units per frame

        # Set up GLMakie window with proper configuration and error handling
        println("Setting up window...")
        setup_visualization_window_safely(fig)

        # Connect all event handlers with error handling
        println("Setting up keyboard event handlers...")
        setup_keyboard_events_safely!(fig, movement_state, point_position)

        # Set up window focus handling for robustness
        setup_window_focus_handling!(fig, movement_state)

        # Start the application loop
        println("Point Controller is ready!")
        println("Use WASD keys to move the point. Press 'q' to quit or close the window to exit.")

        # Keep the application running and responsive
        # GLMakie handles the event loop internally, so we just need to keep the process alive
        # and ensure proper cleanup when the window is closed

        # Set up window close handler for proper cleanup
        on(events(fig).window_open) do is_open
            if !is_open
                println("Window closed. Cleaning up...")
                cleanup_application_safely(movement_state)
                println("Point Controller stopped.")
            end
        end

        # Wait for the window to be closed or quit requested
        # This keeps the Julia process alive while the GLMakie window is open
        while events(fig).window_open[] && !movement_state.should_quit
            sleep(0.1)  # Small sleep to prevent busy waiting
        end
        
        # Handle quit request
        if movement_state.should_quit
            println("Exiting application...")
            # Close the window if quit was requested via 'q' key
            cleanup_application_safely(movement_state)
            GLMakie.closeall()
        end

    catch e
        handle_application_error(e, movement_state, fig)
        rethrow(e)
    end

    println("Point Controller application finished.")
end

"""
    initialize_glmakie_safely()

Check if GLMakie backend is properly activated and available.
Returns true if GLMakie is ready to use, false otherwise.

Note: Users must call GLMakie.activate!() before using PointController functions.
"""
function initialize_glmakie_safely()
    try
        # Check if GLMakie backend is available and activated
        # This will fail if GLMakie.activate!() hasn't been called by the user
        
        # Test basic GLMakie functionality to ensure backend is working
        test_fig = Figure(size = (100, 100))
        # Note: Figures don't need explicit closing in GLMakie
        
        println("GLMakie backend is ready and functional.")
        return true
        
    catch e
        if contains(string(e), "backend") || contains(string(e), "activate")
            println("ERROR: GLMakie backend not activated.")
            println("Please call GLMakie.activate!() before using PointController:")
            println("  using GLMakie")
            println("  GLMakie.activate!()")
            println("  using PointController")
            println("  run_point_controller()")
        elseif contains(string(e), "OpenGL") || contains(string(e), "GL")
            println("ERROR: OpenGL initialization failed.")
            println("This usually indicates:")
            println("  - Outdated graphics drivers")
            println("  - Insufficient OpenGL version (3.3+ required)")
            println("  - Missing graphics hardware acceleration")
            println("Please update your graphics drivers and ensure OpenGL 3.3+ support.")
        elseif contains(string(e), "display") || contains(string(e), "DISPLAY")
            println("ERROR: Display system not available.")
            println("This usually indicates:")
            println("  - Running in headless environment without display")
            println("  - X11 forwarding not enabled (if using SSH)")
            println("  - Wayland compatibility issues")
            println("Please ensure you have a working display system.")
        else
            println("ERROR: GLMakie backend check failed:")
            println("  $(string(e))")
            println("Make sure to activate GLMakie before using PointController:")
            println("  GLMakie.activate!()")
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
        println("ERROR: Failed to create visualization: $(string(e))")
        println("This may indicate insufficient graphics memory or rendering capabilities.")
        rethrow(e)
    end
end

"""
    setup_visualization_window_safely(fig::Figure)

Set up visualization window with error handling.
"""
function setup_visualization_window_safely(fig::Figure)
    try
        setup_visualization_window(fig)
        return fig
    catch e
        println("ERROR: Failed to display window: $(string(e))")
        println("This may indicate window system compatibility issues.")
        rethrow(e)
    end
end

"""
    setup_keyboard_events_safely!(fig::Figure, state::MovementState, position::Observable{Point2f})

Set up keyboard events with comprehensive error handling.
"""
function setup_keyboard_events_safely!(fig::Figure, state::MovementState, position::Observable{Point2f})
    try
        setup_keyboard_events!(fig, state, position)
        return fig
    catch e
        println("ERROR: Failed to set up keyboard events: $(string(e))")
        println("Keyboard input may not work properly.")
        # Don't rethrow - application can still run without keyboard events
        return fig
    end
end

"""
    setup_window_focus_handling!(fig::Figure, state::MovementState)

Set up window focus change handling for robustness.
Ensures proper behavior when window loses/gains focus.
"""
function setup_window_focus_handling!(fig::Figure, state::MovementState)
    try
        # Handle window focus changes
        on(events(fig).hasfocus) do has_focus
            if !has_focus
                # Clear all pressed keys when window loses focus
                # This prevents "stuck" keys when focus is lost while keys are pressed
                println("Window lost focus - clearing key states for safety")
                clear_all_keys_safely!(state)
                stop_movement_timer!(state)
            else
                println("Window gained focus")
            end
        end
        
        println("Window focus handling set up successfully.")
        return fig
        
    catch e
        println("WARNING: Could not set up window focus handling: $(string(e))")
        println("Application will continue but may have issues with focus changes.")
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
    println("ERROR: Point Controller encountered an error:")
    
    if isa(e, InterruptException)
        println("Application interrupted by user (Ctrl+C)")
    elseif contains(string(e), "OpenGL") || contains(string(e), "GL")
        println("OpenGL/Graphics error: $(string(e))")
        println("This may indicate graphics driver or hardware issues.")
    elseif contains(string(e), "OutOfMemoryError")
        println("Out of memory error: $(string(e))")
        println("Try closing other applications to free up memory.")
    else
        println("Unexpected error: $(string(e))")
        println("Error type: $(typeof(e))")
    end
    
    # Attempt cleanup
    cleanup_application_safely(movement_state)
end

"""
    cleanup_application_safely(movement_state)

Safely clean up application resources with error handling.
"""
function cleanup_application_safely(movement_state)
    try
        if movement_state !== nothing
            stop_movement_timer!(movement_state)
            clear_all_keys_safely!(movement_state)
        end
        println("Application cleanup completed.")
    catch cleanup_error
        println("WARNING: Error during cleanup: $(string(cleanup_error))")
        # Continue cleanup despite errors
    end
end

# Optional automatic backend activation
# Uncomment the following function to automatically activate GLMakie when the module loads
# This is provided as a convenience option but goes against modern Makie patterns
# where users should explicitly control backend activation

# function __init__()
#     try
#         GLMakie.activate!()
#         @info "GLMakie backend automatically activated by PointController"
#     catch e
#         @warn "Failed to automatically activate GLMakie backend: $e"
#         @info "Please manually activate GLMakie: GLMakie.activate!()"
#     end
# end

end # module PointController