using Test
using PointController
using GLMakie

@testset "Timing System Tests" begin

    @testset "Movement Timer Management" begin
        # Test timer creation and cleanup
        state = MovementState(2.0)
        position = create_point_position()

        # Initially no timer should be running
        @test state.update_timer === nothing

        # Start timer
        start_movement_timer!(state, position, 0.1)  # 100ms interval for testing
        @test state.update_timer !== nothing

        # Stop timer
        stop_movement_timer!(state)
        @test state.update_timer === nothing
    end

    @testset "Timing Integration with Key Events" begin
        state = MovementState(1.0)
        position = create_point_position()

        # Test timing updates on key press/release
        initial_time = state.last_update_time

        # Simulate key press
        handle_key_press("w", state)
        @test state.last_update_time > initial_time

        # Simulate key release
        sleep(0.01)  # Small delay to ensure time difference
        handle_key_release("w", state)
        @test state.last_update_time > initial_time
    end

    @testset "Continuous Movement Behavior" begin
        state = MovementState(1.0)
        position = create_point_position()

        # Test that movement state is properly managed
        @test !state.is_moving
        @test isempty(state.keys_pressed)

        # Press a key - should start movement
        handle_key_press("w", state)
        @test state.is_moving
        @test "w" in state.keys_pressed

        # Release key - should stop movement
        handle_key_release("w", state)
        @test !state.is_moving
        @test isempty(state.keys_pressed)
    end

    @testset "Multiple Key Timing" begin
        state = MovementState(1.0)
        position = create_point_position()

        # Press multiple keys
        handle_key_press("w", state)
        handle_key_press("d", state)
        @test state.is_moving
        @test length(state.keys_pressed) == 2

        # Release one key - should still be moving
        handle_key_release("w", state)
        @test state.is_moving
        @test length(state.keys_pressed) == 1

        # Release last key - should stop moving
        handle_key_release("d", state)
        @test !state.is_moving
        @test isempty(state.keys_pressed)
    end

    @testset "Timer Cleanup on Reset" begin
        state = MovementState(1.0)
        position = create_point_position()

        # Start timer and add keys
        handle_key_press("w", state)
        start_movement_timer!(state, position)
        @test state.update_timer !== nothing

        # Reset should clean up timer
        reset_movement_state!(state)
        @test state.update_timer === nothing
        @test !state.is_moving
        @test isempty(state.keys_pressed)
    end

    @testset "Position Updates with Timing" begin
        state = MovementState(2.0)  # Higher speed for visible movement
        position = create_point_position()

        # Get initial position
        initial_pos = get_current_position(position)
        @test initial_pos == (0.0, 0.0)

        # Simulate movement with timing
        handle_key_press("w", state)
        update_movement_timing!(state)

        # Manual position update (simulating timer behavior)
        update_position_from_state!(position, state)

        # Position should have changed
        new_pos = get_current_position(position)
        @test new_pos[2] > initial_pos[2]  # Y should increase for 'w' key
    end
end