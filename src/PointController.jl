module PointController

using GLMakie

# Export main functions and types
export run_point_controller, MovementState, KEY_MAPPINGS,
    handle_key_press, handle_key_release, calculate_movement_vector,
    reset_movement_state!, add_key!, remove_key!, request_quit!, clear_all_keys_safely!,
    create_point_position, update_point_position!, get_current_position,
    apply_movement_to_position!, update_position_from_state!,
    create_visualization, setup_visualization_window, update_coordinate_display!,
    setup_keyboard_events!, is_movement_key, get_pressed_keys,
    start_movement_timer!, stop_movement_timer!, update_movement_timing!,
    initialize_glmakie_safely, create_visualization_safely, setup_visualization_window_safely,
    setup_keyboard_events_safely!, setup_window_focus_handling!, handle_application_error,
    cleanup_application_safely

# Include component modules
include("movement_state.jl")
include("input_handler.jl")
include("visualization.jl")

"""
    run_point_controller()

Main entry point for the Point Controller application.
Creates an interactive window with a controllable point using WASD keys.
Includes comprehensive error handling and robustness features.
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
        movement_state = MovementState(0.1)  # Movement speed of 0.1 units per frame

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

Safely initialize GLMakie with comprehensive error handling.
Returns true if successful, false otherwise.
"""
function initialize_glmakie_safely()
    try
        # Check if GLMakie can be activated
        GLMakie.activate!()
        
        # Test basic GLMakie functionality
        test_fig = Figure(size = (100, 100))
        # Note: Figures don't need explicit closing in GLMakie
        
        println("GLMakie initialized successfully.")
        return true
        
    catch e
        if contains(string(e), "OpenGL") || contains(string(e), "GL")
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
            println("ERROR: GLMakie initialization failed with unexpected error:")
            println("  $(string(e))")
            println("Please check your GLMakie installation and system compatibility.")
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

end # module PointController