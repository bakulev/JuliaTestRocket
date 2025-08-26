# GLMakie Smoke Test
# Minimal test to ensure GLMakie can initialize and basic interactive features work
# This test should only run if GLMakie is available and a display is present

using Test
using GLMakie
using PointController

# Activate GLMakie for testing
GLMakie.activate!()

# Update backend detection after loading GLMakie
PointController.update_backend_detection()

@testset "GLMakie Smoke Test" begin
    @testset "Basic GLMakie Functionality" begin
        # Test that GLMakie backend is detected
        @test PointController.check_backend_loaded()
        @test PointController.get_backend_name() == "GLMakie"

        # Test basic figure creation
        fig = Figure(size = (100, 100))
        @test fig isa Figure

        # Test basic axis creation
        ax = Axis(fig[1, 1])
        @test ax isa Axis

        # Test basic point creation
        point = Observable(Point2f(0, 0))
        @test point isa Observable{Point2f}

        # Test basic scatter plot
        scatter!(ax, point, color = :red, markersize = 10)
        @test true  # If we get here, scatter worked

        # Test basic text
        text!(ax, 0, 0, text = "Test")
        @test true  # If we get here, text worked

        # Test basic event setup (without running the full app)
        state = MovementState()
        @test state isa MovementState

        # Test that we can set up keyboard events (this should not fail)
        @test_nowarn setup_keyboard_events!(fig, state, point)

        # Test basic movement calculation
        add_key!(state, 'w')
        movement = calculate_movement_vector(state)
        @test movement == [0.0, 1.0]

        # Test position update with time-based movement
        state.elapsed_time = 0.05  # 0.05 seconds
        @test_nowarn apply_movement_to_position!(point, state)
        @test point[] == Point2f(0.0, 0.1)  # 2.0 units/sec * 0.05 sec = 0.1 units

        # Clean up
        remove_key!(state, 'w')
        clear_all_keys_safely!(state)
    end

    @testset "GLMakie Event System" begin
        # Test that GLMakie events are available
        fig = Figure()
        @test hasfield(typeof(events(fig)), :keyboardbutton)
        @test hasfield(typeof(events(fig)), :window_open)
        @test hasfield(typeof(events(fig)), :hasfocus)
    end
end
