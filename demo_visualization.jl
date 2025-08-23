#!/usr/bin/env julia

# Demo script to test the GLMakie visualization setup
# This script demonstrates the basic visualization functionality

using Pkg
Pkg.activate(".")

using PointController
using GLMakie

println("Testing GLMakie visualization setup...")

# Create the visualization
println("Creating visualization components...")
fig, ax, point_pos, coord_text = create_visualization()

# Test updating the point position
println("Testing point position updates...")
update_point_position!(point_pos, 3.0, 2.0)
println("Point moved to: $(get_current_position(point_pos))")

# Test coordinate display
println("Current coordinate text: $(coord_text[])")

# Test another position update
update_point_position!(point_pos, -2.5, 4.1)
println("Point moved to: $(get_current_position(point_pos))")
println("Updated coordinate text: $(coord_text[])")

# Setup the window (this will display the visualization)
println("Setting up visualization window...")
setup_visualization_window(fig)

println("Visualization setup complete!")
println("The window should display a red point with coordinate text.")
println("Press Ctrl+C to exit.")

# Keep the script running to show the window
try
    while true
        sleep(0.1)
    end
catch InterruptException
    println("\nExiting...")
end