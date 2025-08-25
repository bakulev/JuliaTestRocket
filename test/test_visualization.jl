# Test file for visualization functionality

using Test
using GLMakie
GLMakie.activate!()
using PointController

@testset "Visualization Tests" begin
    @testset "Visualization Creation" begin
        # Test that create_visualization returns the expected components
        fig, ax, point_pos, coord_text, time_obs = create_visualization()

        @test fig isa Figure
        @test ax isa Axis
        @test point_pos isa Observable{Point2f}
        @test coord_text isa Observable{String}
        @test time_obs isa Observable{String}

        # Test initial point position is at origin
        initial_pos = point_pos[]
        @test initial_pos[1] ≈ 0.0
        @test initial_pos[2] ≈ 0.0

        # Test coordinate text updates with position
        initial_text = coord_text[]
        @test occursin("Position:", initial_text)
        @test occursin("0.0", initial_text)
    end

    @testset "Point Position Updates" begin
        fig, ax, point_pos, coord_text, time_obs = create_visualization()

        # Test updating point position
        update_point_position!(point_pos, 5.0, 3.0)
        updated_pos = point_pos[]
        @test updated_pos[1] ≈ 5.0
        @test updated_pos[2] ≈ 3.0

        # Test coordinate text reflects the update
        updated_text = coord_text[]
        @test occursin("5.0", updated_text)
        @test occursin("3.0", updated_text)
    end

    @testset "Coordinate Display Update" begin
        fig, ax, point_pos, coord_text, time_obs = create_visualization()

        # Test manual coordinate display update
        result = update_coordinate_display!(point_pos)
        @test result === point_pos
    end

    @testset "Visualization Window Setup" begin
        fig, ax, point_pos, coord_text, time_obs = create_visualization()

        # Test window setup (this should not error)
        @test_nowarn setup_visualization_window(fig)
    end

    @testset "Time Display Functionality" begin
        # Test time observable creation
        time_obs = create_time_observable()
        @test time_obs isa Observable{String}

        # Test time formatting
        time_str = format_current_time()
        @test time_str isa String
        @test length(time_str) == 8  # HH:MM:SS format
        @test occursin(":", time_str)

        # Test that time observable contains properly formatted time
        @test occursin(":", time_obs[])
        @test length(time_obs[]) == 8
    end
end
