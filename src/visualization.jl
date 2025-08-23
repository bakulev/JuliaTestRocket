# Visualization Module
# This module handles GLMakie visualization setup and rendering

using GLMakie

"""
    create_visualization()

Create and configure the GLMakie visualization window with point and coordinate display.
Returns the figure, axis, point observable, and coordinate text observable.
"""
function create_visualization()
    # Initialize GLMakie backend with appropriate configuration
    GLMakie.activate!()
    
    # Create figure with proper configuration
    fig = Figure(size = (800, 600), title = "Point Controller")
    
    # Create axis with coordinate system
    ax = Axis(fig[1, 1], 
        xlabel = "X Coordinate",
        ylabel = "Y Coordinate",
        title = "Interactive Point Control (Use WASD keys)",
        aspect = DataAspect(),
        limits = (-10, 10, -10, 10)
    )
    
    # Create observable point position (initialized at origin)
    point_position = create_point_position()
    
    # Implement basic point rendering using scatter plot
    scatter!(ax, point_position, 
        color = :red, 
        markersize = 20,
        marker = :circle
    )
    
    # Add coordinate text display that updates with point position
    coordinate_text = lift(point_position) do pos
        "Position: ($(round(pos[1], digits=2)), $(round(pos[2], digits=2)))"
    end
    
    # Display coordinate text in the top-left corner of the plot
    text!(ax, -9.5, 9.5, 
        text = coordinate_text,
        fontsize = 14,
        color = :black,
        align = (:left, :top)
    )
    
    # Add grid for better coordinate reference
    ax.xgridvisible = true
    ax.ygridvisible = true
    ax.xminorgridvisible = true
    ax.yminorgridvisible = true
    
    return fig, ax, point_position, coordinate_text
end

"""
    setup_visualization_window(fig::Figure)

Set up and display the GLMakie window with proper configuration.
"""
function setup_visualization_window(fig::Figure)
    # Display the figure in a window
    display(fig)
    return fig
end

"""
    update_coordinate_display!(position::Observable{Point2f})

Force update of coordinate display (useful for manual refresh).
"""
function update_coordinate_display!(position::Observable{Point2f})
    # Trigger observable update to refresh coordinate display
    notify(position)
    return position
end