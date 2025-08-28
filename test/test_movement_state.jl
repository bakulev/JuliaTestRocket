# Movement State Tests
# Backend-agnostic tests for movement state management
# These tests don't require any Makie backend

using Test
using Observables: Observable
using StaticArrays: SVector

# Define Point2f to match our implementation
const Point2f = SVector{2, Float32}

@testset "Movement State Tests" begin
    @testset "MovementState Creation" begin
        # Test default constructor
        state = PointController.MovementState()
        @test state.pressed_keys == Set{Char}()
        @test state.movement_speed == 2.0
        @test state.should_quit == false
        @test state.elapsed_time == 0.0

        # Test custom movement speed
        state = PointController.MovementState(movement_speed = 5.0)
        @test state.movement_speed == 5.0
    end

    @testset "Key Management" begin
        state = PointController.MovementState()

        # Test adding keys
        PointController.add_key!(state, 'w')
        @test 'w' in state.pressed_keys
        @test length(state.pressed_keys) == 1

        PointController.add_key!(state, 'a')
        @test 'a' in state.pressed_keys
        @test length(state.pressed_keys) == 2

        # Test removing keys
        PointController.remove_key!(state, 'w')
        @test 'w' ∉ state.pressed_keys
        @test 'a' in state.pressed_keys
        @test length(state.pressed_keys) == 1

        # Test clearing all keys
        PointController.clear_all_keys_safely!(state)
        @test isempty(state.pressed_keys)
    end

    @testset "Movement Vector Calculation" begin
        state = PointController.MovementState()

        # Test no movement when no keys pressed
        movement = PointController.calculate_movement_vector(state)
        @test movement == [0.0, 0.0]

        # Test single key movement
        PointController.add_key!(state, 'w')
        movement = PointController.calculate_movement_vector(state)
        @test movement == [0.0, 1.0]

        PointController.add_key!(state, 'a')
        movement = PointController.calculate_movement_vector(state)
        # Diagonal movement should be normalized
        expected_magnitude = sqrt(0.5^2 + 0.5^2)
        @test abs(movement[1] - (-1/sqrt(2))) < 1e-10
        @test abs(movement[2] - (1/sqrt(2))) < 1e-10

        # Test all four directions
        PointController.clear_all_keys_safely!(state)
        PointController.add_key!(state, 's')
        movement = PointController.calculate_movement_vector(state)
        @test movement == [0.0, -1.0]

        PointController.clear_all_keys_safely!(state)
        PointController.add_key!(state, 'd')
        movement = PointController.calculate_movement_vector(state)
        @test movement == [1.0, 0.0]
    end

    @testset "Position Updates" begin
        state = PointController.MovementState(
            position = Point2f(0.0, 0.0),
            movement_speed = 2.0,
        )

        # Test movement from origin with time-based movement
        PointController.add_key!(state, 'w')
        new_state = PointController.apply_movement_to_position(state, 0.5)  # 0.5 seconds
        @test new_state.position == Point2f(0.0, 1.0)  # 2.0 units/sec * 0.5 sec = 1.0 unit

        # Test diagonal movement
        PointController.add_key!(new_state, 'd')
        new_state2 = PointController.apply_movement_to_position(new_state, 0.5)  # 0.5 seconds
        # Should move diagonally with normalized speed
        # Previous position was (0, 1.0), new movement is 1.0 units in diagonal direction
        expected_x = 1.0/sqrt(2)  # 1.0 unit * cos(45°) = 1.0/sqrt(2)
        expected_y = 1.0 + 1.0/sqrt(2)  # Previous 1.0 + 1.0 unit * sin(45°)
        @test abs(new_state2.position[1] - expected_x) < 1e-6
        @test abs(new_state2.position[2] - expected_y) < 1e-6
    end

    @testset "State Management" begin
        state = PointController.MovementState()

        # Test state reset
        PointController.add_key!(state, 'w')
        PointController.reset_movement_state!(state)
        @test isempty(state.pressed_keys)
        @test state.should_quit == false
    end

    @testset "Utility Functions" begin
        state = PointController.MovementState()

        # Test movement key detection
        @test PointController.is_movement_key('w')
        @test PointController.is_movement_key('a')
        @test PointController.is_movement_key('s')
        @test PointController.is_movement_key('d')
        @test !PointController.is_movement_key('q')
        @test !PointController.is_movement_key('x')

        # Test time formatting
        time_str = PointController.format_current_time()
        @test time_str isa String
        @test length(time_str) > 0
    end

    @testset "Timing Management" begin
        state = PointController.MovementState()

        # Test initial timing state
        initial_time = state.last_update_time
        @test state.elapsed_time == 0.0

        # Test timing update
        sleep(0.1)  # Wait a bit to ensure time difference
        current_time = time()
        PointController.update_movement_timing!(state, current_time)
        @test state.elapsed_time > 0.0
        @test state.last_update_time > initial_time

        # Test multiple timing updates
        sleep(0.1)  # Wait again
        current_time = time()
        PointController.update_movement_timing!(state, current_time)
        @test state.elapsed_time > 0.0  # Should be positive
        @test state.last_update_time > initial_time  # Should be updated

        # Test reset clears timing
        PointController.reset_movement_state!(state)
        @test state.elapsed_time == 0.0
    end

    @testset "Error Handling" begin
        state = PointController.MovementState()

        # Test that invalid keys don't cause errors
        @test_nowarn PointController.add_key!(state, 'x')
        @test_nowarn PointController.remove_key!(state, 'x')

        # Test that clearing keys works even when empty
        @test_nowarn PointController.clear_all_keys_safely!(state)

        # Test that movement calculation works with invalid keys
        PointController.add_key!(state, 'x')
        @test_nowarn PointController.calculate_movement_vector(state)
        @test PointController.calculate_movement_vector(state) == [0.0, 0.0]
    end
end
