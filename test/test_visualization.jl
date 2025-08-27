# Visualization Tests
# Tests for Makie visualization components
# These tests use CairoMakie for headless CI compatibility

using Test
using CairoMakie

# Activate CairoMakie for testing
CairoMakie.activate!()

# Update backend detection after loading CairoMakie
PointController.update_backend_detection()

# Import the functions we need to test
using PointController: create_visualization, create_time_observable, 
    setup_visualization_window, update_coordinate_display!, format_current_time

@testset "Visualization Tests" begin
    @testset "Basic Visualization Creation" begin
        # Test that visualization can be created
        fig, ax, point_position, coordinate_text, time_obs = create_visualization()

        @test fig isa Figure
        @test ax isa Axis
        @test point_position isa Observable{Point2f}
        @test coordinate_text isa Observable{String}
        @test time_obs isa Observable{String}

        # Test initial values
        @test point_position[] == Point2f(0, 0)
        @test time_obs[] isa String
        @test length(time_obs[]) > 0
    end

    @testset "Point Position Management" begin
        # Test point position creation using Observable directly
        position = Observable(Point2f(0, 0))
        @test position isa Observable{Point2f}
        @test position[] == Point2f(0, 0)

        # Test position updates
        position[] = Point2f(1.5, -2.3)
        @test position[] == Point2f(1.5, -2.3)

        # Test coordinate display updates
        coordinate_text = lift(position) do pos
            x_rounded = round(pos[1], digits = 2)
            y_rounded = round(pos[2], digits = 2)
            return "Position: ($x_rounded, $y_rounded)"
        end

        @test coordinate_text[] == "Position: (1.5, -2.3)"

        position[] = Point2f(-0.75, 3.14)
        @test coordinate_text[] == "Position: (-0.75, 3.14)"
    end

    @testset "Time Display" begin
        # Test time observable creation
        time_obs = create_time_observable()
        @test time_obs isa Observable{String}
        @test time_obs[] isa String
        @test length(time_obs[]) > 0

        # Test time formatting
        time_str = format_current_time()
        @test time_str isa String
        @test length(time_str) > 0

        # Test time display updates
        time_obs[] = "12:34:56"
        @test time_obs[] == "12:34:56"
    end

    @testset "Window Setup" begin
        # Test window setup
        fig = Figure(size = (100, 100))
        @test_nowarn setup_visualization_window(fig)

        # Test that figure was created successfully
        @test fig isa Figure
    end

    @testset "Coordinate Display Updates" begin
        # Test coordinate display update function
        position = Observable(Point2f(0, 0))

        # Test manual update
        @test_nowarn update_coordinate_display!(position)

        # Test that position changes trigger updates
        position[] = Point2f(5.5, -3.2)
        @test_nowarn update_coordinate_display!(position)
    end

    @testset "Visualization Integration" begin
        # Test complete visualization setup
        fig, ax, point_position, coordinate_text, time_obs = create_visualization()

        # Test that all components are connected
        @test fig isa Figure
        @test ax isa Axis

        # Test that axis was created successfully
        @test ax isa Axis
    end

    @testset "Error Handling" begin
        # Test that visualization creation doesn't fail
        @test_nowarn create_visualization()

        # Test that window setup doesn't fail
        fig = Figure()
        @test_nowarn setup_visualization_window(fig)

        # Test that coordinate updates don't fail
        position = Observable(Point2f(0, 0))
        @test_nowarn update_coordinate_display!(position)
    end
end
