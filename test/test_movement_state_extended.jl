# Extended Movement State Tests
# Additional tests for movement state functions not covered in existing tests

using Test
using Observables: Observable

# Define tolerance for floating-point comparisons
const FLOAT_TOLERANCE = 1e-5
using StaticArrays: SVector

# Define Point2f to match our implementation
const Point2f = SVector{2, Float32}

@testset "Extended Movement State Tests" begin
    @testset "get_current_position" begin
        # Test get_current_position with origin
        state = PointController.MovementState(position = Point2f(0.0, 0.0))
        current_pos = PointController.get_current_position(state)
        @test isa(current_pos, Tuple)
        @test length(current_pos) == 2
        @test current_pos[1] ≈ 0.0 atol=1e-6
        @test current_pos[2] ≈ 0.0 atol=1e-6

        # Test with different position
        state.position = Point2f(1.5, -2.3)
        current_pos = PointController.get_current_position(state)
        @test current_pos[1] ≈ 1.5 atol=1e-6
        @test current_pos[2] ≈ -2.3 atol=1e-6
    end

    @testset "reset_movement_state!" begin
        state = PointController.MovementState()

        # Add some keys and set quit flag
        PointController.add_key!(state, 'w')
        PointController.add_key!(state, 'a')
        state.should_quit = true
        state.elapsed_time = 1.5

        # Reset the state
        @test_nowarn PointController.reset_movement_state!(state)

        # Test that state was reset
        @test isempty(state.pressed_keys)
        @test state.should_quit == false
        @test state.elapsed_time == 0.0
        @test state.last_update_time > 0.0  # Should be updated to current time
    end

    @testset "Movement State Quit Flag" begin
        state = PointController.MovementState()
        @test state.should_quit == false

        # Test that we can set the quit flag directly
        state.should_quit = true
        @test state.should_quit == true

        # Test that other state is unchanged
        @test isempty(state.pressed_keys)
        @test state.movement_speed == 2.0
    end

    @testset "clear_all_keys_safely!" begin
        state = PointController.MovementState()

        # Add some keys
        PointController.add_key!(state, 'w')
        PointController.add_key!(state, 'a')
        PointController.add_key!(state, 's')
        @test length(state.pressed_keys) == 3

        # Clear all keys
        @test_nowarn PointController.clear_all_keys_safely!(state)
        @test isempty(state.pressed_keys)
    end

    @testset "Movement State Edge Cases" begin
        state = PointController.MovementState()

        # Test adding the same key multiple times
        PointController.add_key!(state, 'w')
        PointController.add_key!(state, 'w')
        PointController.add_key!(state, 'w')
        @test length(state.pressed_keys) == 1  # Set should only contain unique elements
        @test 'w' in state.pressed_keys

        # Test removing a key that's not pressed
        @test_nowarn PointController.remove_key!(state, 'x')
        @test 'w' in state.pressed_keys  # Should still be there

        # Test clearing keys when none are pressed
        PointController.clear_all_keys_safely!(state)
        @test_nowarn PointController.clear_all_keys_safely!(state)  # Should not error
        @test isempty(state.pressed_keys)
    end

    @testset "Movement State Boundary Conditions" begin
        state = PointController.MovementState(position = Point2f(0.0, 0.0), movement_speed = 1.0)

        # Test movement that would exceed boundaries
        PointController.add_key!(state, 'd')  # Move right
        new_state = PointController.apply_movement_to_position(state, 15.0)  # This would move 15 units right

        # Should be clamped to boundary
        @test new_state.position == Point2f(10.0, 0.0)  # Clamped to +10

        # Test negative boundary - need to set position first, then apply movement
        boundary_state = PointController.MovementState(position = Point2f(-15.0, 0.0), movement_speed = 1.0)
        # Clear previous movement and set up for left movement
        PointController.clear_all_keys_safely!(boundary_state)
        PointController.add_key!(boundary_state, 'a')  # Move left
        boundary_state = PointController.apply_movement_to_position(boundary_state, 1.0)  # Small movement to test clamping

        @test boundary_state.position == Point2f(-10.0, 0.0)  # Should be clamped to -10
    end

    @testset "Movement State Performance" begin
        state = PointController.MovementState(position = Point2f(0.0, 0.0))

        # Test rapid state changes
        for i in 1:100
            PointController.add_key!(state, 'w')
            PointController.remove_key!(state, 'w')
        end

        @test isempty(state.pressed_keys)

        # Test rapid position updates
        PointController.add_key!(state, 'd')
        for i in 1:50
            @test_nowarn state = PointController.apply_movement_to_position(state, 0.1)
        end

        # Check that we're close to the boundary (allowing for Float32 precision)
        @test abs(state.position[1] - 10.0) < 1e-5
        @test state.position[2] == 0.0
    end
end
