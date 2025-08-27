# Extended Movement State Tests
# Additional tests for movement state functions not covered in existing tests

using Test
using Observables: Observable
using PointController

# Define tolerance for floating-point comparisons
const FLOAT_TOLERANCE = 1e-5
using StaticArrays: SVector

# Define Point2f to match our implementation
const Point2f = SVector{2, Float32}

@testset "Extended Movement State Tests" begin
    @testset "create_point_position" begin
        # Test that create_point_position returns an observable
        position = create_point_position()
        @test isa(position, Observable)
        @test isa(position[], Point2f)

        # Test that it starts at origin
        @test position[] == Point2f(0.0, 0.0)
    end

    @testset "get_current_position" begin
        # Test get_current_position with origin
        position = Observable(Point2f(0.0, 0.0))
        current_pos = get_current_position(position)
        @test isa(current_pos, Tuple)
        @test length(current_pos) == 2
        @test current_pos == (0.0, 0.0)

        # Test with different position
        position[] = Point2f(1.5, -2.3)
        current_pos = get_current_position(position)
        @test current_pos == (1.5f0, -2.3f0)  # Float32 precision
    end

    @testset "update_position_from_state!" begin
        # Test that update_position_from_state! is an alias for apply_movement_to_position!
        state = MovementState(movement_speed = 2.0)
        position = Observable(Point2f(0.0, 0.0))

        add_key!(state, 'w')
        state.elapsed_time = 0.5

        @test_nowarn update_position_from_state!(position, state)
        @test position[] == Point2f(0.0, 1.0)
    end

    @testset "reset_movement_state!" begin
        state = MovementState()

        # Add some keys and set quit flag
        add_key!(state, 'w')
        add_key!(state, 'a')
        state.should_quit = true
        state.elapsed_time = 1.5

        # Reset the state
        @test_nowarn reset_movement_state!(state)

        # Test that state was reset
        @test isempty(state.pressed_keys)
        @test state.should_quit == false
        @test state.elapsed_time == 0.0
        @test state.last_update_time > 0.0  # Should be updated to current time
    end

    @testset "request_quit!" begin
        state = MovementState()
        @test state.should_quit == false

        # Request quit
        @test request_quit!(state) === nothing
        @test state.should_quit == true

        # Test that other state is unchanged
        @test isempty(state.pressed_keys)
        @test state.movement_speed == 2.0
    end

    @testset "clear_all_keys_safely!" begin
        state = MovementState()

        # Add some keys
        add_key!(state, 'w')
        add_key!(state, 'a')
        add_key!(state, 's')
        @test length(state.pressed_keys) == 3

        # Clear all keys
        @test_nowarn clear_all_keys_safely!(state)
        @test isempty(state.pressed_keys)
    end

    @testset "Movement State Edge Cases" begin
        state = MovementState()

        # Test adding the same key multiple times
        add_key!(state, 'w')
        add_key!(state, 'w')
        add_key!(state, 'w')
        @test length(state.pressed_keys) == 1  # Set should only contain unique elements
        @test 'w' in state.pressed_keys

        # Test removing a key that's not pressed
        @test_nowarn remove_key!(state, 'x')
        @test 'w' in state.pressed_keys  # Should still be there

        # Test clearing keys when none are pressed
        clear_all_keys_safely!(state)
        @test_nowarn clear_all_keys_safely!(state)  # Should not error
        @test isempty(state.pressed_keys)
    end

    @testset "Movement State Boundary Conditions" begin
        state = MovementState(movement_speed = 1.0)
        position = Observable(Point2f(0.0, 0.0))

        # Test movement that would exceed boundaries
        add_key!(state, 'd')  # Move right
        state.elapsed_time = 15.0  # This would move 15 units right

        apply_movement_to_position!(position, state)

        # Should be clamped to boundary
        @test position[] == Point2f(10.0, 0.0)  # Clamped to +10

        # Test negative boundary - need to set position first, then apply movement
        position[] = Point2f(-15.0, 0.0)  # Set to beyond boundary
        # Clear previous movement and set up for left movement
        clear_all_keys_safely!(state)
        add_key!(state, 'a')  # Move left
        state.elapsed_time = 1.0  # Small movement to test clamping

        apply_movement_to_position!(position, state)
        @test position[] == Point2f(-10.0, 0.0)  # Should be clamped to -10
    end

    @testset "Movement State Performance" begin
        state = MovementState()
        position = Observable(Point2f(0.0, 0.0))

        # Test rapid state changes
        for i in 1:100
            add_key!(state, 'w')
            remove_key!(state, 'w')
        end

        @test isempty(state.pressed_keys)

        # Test rapid position updates
        add_key!(state, 'd')
        state.elapsed_time = 0.1

        for i in 1:50
            @test_nowarn apply_movement_to_position!(position, state)
        end

        # Check that we're close to the boundary (allowing for Float32 precision)
        @test abs(position[][1] - 10.0) < FLOAT_TOLERANCE
        @test position[][2] == 0.0
    end
end
