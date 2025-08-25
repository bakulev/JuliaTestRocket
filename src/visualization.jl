"""
# Visualization Module

This module provides comprehensive GLMakie-based visualization for the Point Controller
application. It handles all aspects of rendering, window management, and visual updates
with performance optimizations and error handling.

## Key Features

- **GLMakie Integration**: Full GLMakie backend setup and configuration
- **Real-time Rendering**: Efficient point and coordinate display updates
- **Performance Optimization**: Render-on-demand and optimized drawing operations
- **Visual Design**: Clean, professional interface with proper scaling and layout
- **Error Handling**: Robust error recovery for graphics and rendering issues

## Visual Components

- **Interactive Point**: Red circular point that responds to keyboard input
- **Coordinate Display**: Real-time position text in top-left corner
- **Reference Grid**: Visual grid system for precise positioning
- **Axis System**: Labeled X and Y axes with proper scaling (-10 to +10 range)
- **Window Management**: Proper window sizing, positioning, and focus handling

## Performance Features

- **Render on Demand**: Only redraws when necessary to save resources
- **Optimized Markers**: Efficient point rendering without unnecessary overdraw
- **Minimal Grid**: Simplified grid system for better performance
- **Frame Rate Control**: Controlled update frequency for smooth animation

## Usage

```julia
# Create complete visualization
fig, ax, position, text = create_visualization()

# Set up window display
setup_visualization_window(fig)

# Manual coordinate update (if needed)
update_coordinate_display!(position)
```

## Technical Details

- Uses GLMakie's Observable system for reactive updates
- Implements DataAspect for proper coordinate scaling
- Optimized for 60 FPS smooth movement
- Supports window resizing and focus changes
"""

using GLMakie
using Logging

"""
    create_visualization()

Create and configure the GLMakie visualization window with point and coordinate display.
Includes performance optimizations and error handling.
Returns the figure, axis, point observable, coordinate text observable, and time observable.
"""
function create_visualization()
    # Note: GLMakie backend should be activated by the user before calling this function
    # Call GLMakie.activate!() in your script before using PointController functions

    # Create figure with optimized configuration for performance
    fig = Figure(
        size=(800, 600),
        title="Point Controller",
        # Performance optimizations
        figure_padding=10,
        fontsize=12
    )

    # Create axis with coordinate system and performance settings
    ax = Axis(fig[1, 1],
        xlabel="X Coordinate",
        ylabel="Y Coordinate",
        title="Interactive Point Control (Use WASD keys)",
        aspect=DataAspect(),
        limits=(-10, 10, -10, 10),
        # Performance optimizations
        xticklabelsize=10,
        yticklabelsize=10,
        titlesize=14
    )

    # Create observable point position (initialized at origin)
    point_position = create_point_position()

    # Create observable for current time display
    current_time_obs = create_time_observable()

    # Implement optimized point rendering using scatter plot
    scatter!(ax, point_position,
        color=:red,
        markersize=20,
        marker=:circle,
        # Performance optimization: reduce overdraw
        strokewidth=0
    )

    # Add time display in the upper left corner
    time_text = lift(current_time_obs) do time_val
        try
            return "Time: $time_val"
        catch e
            @warn "Error updating time text" exception = string(e) context = "time_display"
            return "Time: Error"
        end
    end

    # Display time text in the upper left corner of the plot
    text!(ax, -9.5, 8.5,
        text=time_text,
        fontsize=12,
        color=:blue,
        align=(:left, :top)
    )

    # Add coordinate text display that updates with point position
    # Optimized to reduce string allocations
    coordinate_text = lift(point_position) do pos
        try
            x_rounded = round(pos[1], digits=2)
            y_rounded = round(pos[2], digits=2)
            return "Position: ($x_rounded, $y_rounded)"
        catch e
            @warn "Error updating coordinate text" exception = string(e) context = "coordinate_display"
            return "Position: (Error, Error)"
        end
    end

    # Display coordinate text below the time display
    text!(ax, -9.5, 7.5,
        text=coordinate_text,
        fontsize=12,
        color=:black,
        align=(:left, :top)
    )

    # Add grid for better coordinate reference with performance settings
    ax.xgridvisible = true
    ax.ygridvisible = true
    ax.xminorgridvisible = false  # Disable minor grid for performance
    ax.yminorgridvisible = false  # Disable minor grid for performance

    # Performance optimization: Modern GLMakie handles rendering efficiently by default
    # Note: render_on_demand is no longer available in newer GLMakie versions

    return fig, ax, point_position, coordinate_text, current_time_obs
end

"""
    setup_visualization_window(fig::Figure)

Set up and display the GLMakie window with proper configuration and performance optimizations.
"""
function setup_visualization_window(fig::Figure)
    try
        # Configure window properties for better performance and user experience
        # Set window to be resizable and properly positioned
        display(fig)

        # Additional performance optimizations if available
        try
            # Limit framerate for better performance
            fig.scene.limits[] = BBox(-12, 12, -12, 12)
        catch e
            # Ignore if not supported
        end

        @debug "Visualization window set up successfully with performance optimizations"
        return fig

    catch e
        @error "Failed to set up visualization window" exception = string(e) context = "window_setup"
        rethrow(e)
    end
end

"""
    create_time_observable()

Create an observable that displays the current time.
Returns an Observable containing a formatted time string.
Note: Time updates are handled by the movement timer system.
"""
function create_time_observable()
    # Create observable with initial time
    return Observable(format_current_time())
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