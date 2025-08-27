# Comprehensive Integration Tests
# Tests for complete PointController functionality
# These tests use CairoMakie for headless CI compatibility

using Test
using PointController

@testset "Comprehensive Integration Tests" begin
    @testset "Complete Application Flow" begin
        # Test that all components can be created and connected
        @test_nowarn begin
            # Create visualization
            fig, ax, point_position, coordinate_text, time_obs = create_visualization()

            # Create movement state
            state = MovementState(movement_speed = 2.0)

            # Set up keyboard events
            setup_keyboard_events!(fig, state, point_position, time_obs)

            # Test basic functionality
            @test fig isa Figure
            @test state isa MovementState
            @test point_position isa Observable{Point2f}
        end
    end

    @testset "Movement and Visualization Integration" begin
        # Test that movement affects visualization
        fig, ax, point_position, coordinate_text, time_obs = create_visualization()
        state = MovementState(movement_speed = 2.0)

        # Test initial position
        @test point_position[] == Point2f(0, 0)

        # Test movement affects position with time-based movement
        add_key!(state, 'w')
        new_state = apply_movement_to_position(state, 0.5)  # 0.5 seconds
        point_position[] = new_state.position
        @test point_position[] == Point2f(0, 1.0)  # 2.0 units/sec * 0.5 sec = 1.0 unit

        # Test coordinate text updates
        @test occursin("0.0", coordinate_text[])
        @test occursin("1.0", coordinate_text[])  # Now 1.0 due to time-based movement

        # Test diagonal movement
        add_key!(new_state, 'd')
        new_state2 = apply_movement_to_position(new_state, 0.5)  # 0.5 seconds
        point_position[] = new_state2.position
        # Previous position was (0, 1.0), new movement is 1.0 units in diagonal direction
        expected_x = 1.0/sqrt(2)  # 1.0 unit * cos(45°) = 1.0/sqrt(2)
        expected_y = 1.0 + 1.0/sqrt(2)  # Previous 1.0 + 1.0 unit * sin(45°)
        @test abs(point_position[][1] - expected_x) < 1e-6
        @test abs(point_position[][2] - expected_y) < 1e-6
    end

    @testset "Event System Integration" begin
        # Test that events can be set up without errors
        fig = Figure()
        state = MovementState()
        point_position = Observable(Point2f(0, 0))

        # Test keyboard event setup
        @test_nowarn setup_keyboard_events!(fig, state, point_position)

        # Test that events are properly connected
        @test hasfield(typeof(events(fig)), :keyboardbutton)
    end

    @testset "Error Recovery" begin
        # Test that errors don't crash the system
        state = MovementState()

        # Test invalid key handling
        @test_nowarn handle_key_press('x', state)
        @test_nowarn handle_key_release('x', state)

        # Test state remains consistent
        @test isempty(state.pressed_keys)
        @test state.should_quit == false

        # Test quit functionality
        using Logging: with_logger, NullLogger
        with_logger(NullLogger()) do
            @test_nowarn handle_key_press('q', state)
        end
        @test state.should_quit == true
    end

    @testset "Backend Detection" begin
        # Test backend detection (should work with CairoMakie)
        @test PointController.check_backend_loaded()
        @test PointController.get_backend_name() == "CairoMakie"
    end

    @testset "Performance and Memory" begin
        # Test that repeated operations don't cause issues
        state = MovementState()
        point_position = Observable(Point2f(0, 0))

        # Test many position updates with time-based movement
        for i in 1:100
            add_key!(state, 'w')
            state = apply_movement_to_position(state, 0.1)  # 0.1 seconds per update
            point_position[] = state.position
            remove_key!(state, 'w')
        end

        # Test that state is still valid
        @test isempty(state.pressed_keys)
        @test point_position[] == Point2f(0, 10.0)  # Should hit boundary
    end
end
