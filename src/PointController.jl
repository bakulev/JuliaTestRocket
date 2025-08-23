module PointController

using GLMakie

# Export main functions and types
export run_point_controller, MovementState, KEY_MAPPINGS, 
       handle_key_press, handle_key_release, calculate_movement_vector

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
    # Implementation will be added in later tasks
end

end # module PointController