module PointController

using GLMakie

# Export main functions and types
export run_point_controller, MovementState, KEY_MAPPINGS,
    handle_key_press, handle_key_release, calculate_movement_vector,
    reset_movement_state!, add_key!, remove_key!, request_quit!,
    create_point_position, update_point_position!, get_current_position,
    apply_movement_to_position!, update_position_from_state!,
    create_visualization, setup_visualization_window, update_coordinate_display!,
    setup_keyboard_events!, is_movement_key, get_pressed_keys,
    start_movement_timer!, stop_movement_timer!, update_movement_timing!

# Include component modules
include("movement_state.jl")
include("input_handler.jl")
include("visualization.jl")

"""
    run_point_controller()

Main entry point for the Point Controller application.
Creates an interactive window with a controllable point using WASD keys.
"""
function run_point_controller()
    println("Starting Point Controller...")

    try
        # Initialize all components
        println("Initializing visualization...")
        fig, ax, point_position, coordinate_text = create_visualization()

        # Create movement state
        println("Setting up movement state...")
        movement_state = MovementState(0.1)  # Movement speed of 0.1 units per frame

        # Set up GLMakie window with proper configuration
        println("Setting up window...")
        setup_visualization_window(fig)

        # Connect all event handlers
        println("Setting up keyboard event handlers...")
        setup_keyboard_events!(fig, movement_state, point_position)

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
                stop_movement_timer!(movement_state)
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
            GLMakie.closeall()
        end

    catch e
        println("Error starting Point Controller: $e")
        # Ensure cleanup on error
        try
            if @isdefined movement_state
                stop_movement_timer!(movement_state)
            end
        catch cleanup_error
            println("Error during cleanup: $cleanup_error")
        end
        rethrow(e)
    end

    println("Point Controller application finished.")
end

end # module PointController