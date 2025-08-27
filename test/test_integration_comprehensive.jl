# Comprehensive Integration Tests
# Tests for complete PointController functionality
# These tests use CairoMakie for headless CI compatibility

using Test

# Import the functions we need to test
using PointController: create_visualization, MovementState, KeyState,
    setup_keyboard_events!,
    apply_movement_to_position, add_key!, remove_key!, handle_key_press, handle_key_release

@testset "Comprehensive Integration Tests" begin
    @testset "Complete Application Flow" begin
        # Test that all components can be created and connected
        @test_nowarn begin
            # Create visualization
            fig, ax, point_position, coordinate_text, time_obs = create_visualization()

            # Create movement state and key state
            movement_state = MovementState(movement_speed = 2.0)
            key_state = KeyState()

            # Set up keyboard events
            setup_keyboard_events!(fig, key_state, point_position, time_obs)

            # Test basic functionality
            @test fig isa Figure
            @test movement_state isa MovementState
            @test key_state isa KeyState
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
        key_state = KeyState()
        point_position = Observable(Point2f(0, 0))

        # Test keyboard event setup
        @test_nowarn setup_keyboard_events!(fig, key_state, point_position)

        # Test that events are properly connected
        @test hasfield(typeof(events(fig)), :keyboardbutton)
    end

    @testset "Error Recovery" begin
        # Test that errors don't crash the system
        key_state = KeyState()

        # Test invalid key handling
        @test_nowarn handle_key_press('x', key_state)
        @test_nowarn handle_key_release('x', key_state)

        # Test state remains consistent
        @test isempty(key_state.pressed_keys)
        @test key_state.should_quit == false

        # Test quit functionality
        using Logging: with_logger, NullLogger
        with_logger(NullLogger()) do
            @test_nowarn handle_key_press('q', key_state)
        end
        @test key_state.should_quit == true
    end

    @testset "Backend Detection" begin
        # Test backend detection (should work with CairoMakie)
        @test PointController.check_backend_loaded()
        @test PointController.get_backend_name() == "CairoMakie"
    end

    @testset "Performance and Memory" begin
        # Test that repeated operations don't cause issues
        movement_state = MovementState()
        point_position = Observable(Point2f(0, 0))

        # Test many position updates with time-based movement
        for i in 1:100
            add_key!(movement_state, 'w')
            movement_state = apply_movement_to_position(movement_state, 0.1)  # 0.1 seconds per update
            point_position[] = movement_state.position
            remove_key!(movement_state, 'w')
        end

        # Test that state is still valid
        @test isempty(movement_state.pressed_keys)
        @test point_position[] == Point2f(0, 10.0)  # Should hit boundary
    end
end
