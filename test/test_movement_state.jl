# Movement State Tests
# Backend-agnostic tests for movement state management
# These tests don't require any Makie backend

using Test
using Observables: Observable
using PointController
using StaticArrays: SVector

# Define Point2f to match our implementation
const Point2f = SVector{2, Float32}

@testset "Movement State Tests" begin
    @testset "MovementState Creation" begin
        # Test default constructor
        state = MovementState()
        @test state.pressed_keys == Set{Char}()
        @test state.movement_speed == 0.1
        @test state.should_quit == false

        # Test custom movement speed
        state = MovementState(movement_speed = 0.5)
        @test state.movement_speed == 0.5
    end

    @testset "Key Management" begin
        state = MovementState()

        # Test adding keys
        add_key!(state, 'w')
        @test 'w' in state.pressed_keys
        @test length(state.pressed_keys) == 1

        add_key!(state, 'a')
        @test 'a' in state.pressed_keys
        @test length(state.pressed_keys) == 2

        # Test removing keys
        remove_key!(state, 'w')
        @test 'w' ∉ state.pressed_keys
        @test 'a' in state.pressed_keys
        @test length(state.pressed_keys) == 1

        # Test clearing all keys
        clear_all_keys_safely!(state)
        @test isempty(state.pressed_keys)
    end

    @testset "Movement Vector Calculation" begin
        state = MovementState()

        # Test no movement when no keys pressed
        movement = calculate_movement_vector(state)
        @test movement == [0.0, 0.0]

        # Test single key movement
        add_key!(state, 'w')
        movement = calculate_movement_vector(state)
        @test movement == [0.0, 1.0]

        add_key!(state, 'a')
        movement = calculate_movement_vector(state)
        # Diagonal movement should be normalized
        expected_magnitude = sqrt(0.5^2 + 0.5^2)
        @test abs(movement[1] - (-1/sqrt(2))) < 1e-10
        @test abs(movement[2] - (1/sqrt(2))) < 1e-10

        # Test all four directions
        clear_all_keys_safely!(state)
        add_key!(state, 's')
        movement = calculate_movement_vector(state)
        @test movement == [0.0, -1.0]

        clear_all_keys_safely!(state)
        add_key!(state, 'd')
        movement = calculate_movement_vector(state)
        @test movement == [1.0, 0.0]
    end

    @testset "Position Updates" begin
        state = MovementState(movement_speed = 0.1)

        # Create a mock position observable (we don't need actual Makie for this)
        position = Observable(Point2f(0.0, 0.0))

        # Test movement from origin
        add_key!(state, 'w')
        apply_movement_to_position!(position, state)
        @test position[] == Point2f(0.0, 0.1)

        # Test diagonal movement
        add_key!(state, 'd')
        apply_movement_to_position!(position, state)
        # Should move diagonally with normalized speed
        expected_x = 0.0 + 0.1/sqrt(2)
        expected_y = 0.1 + 0.1/sqrt(2)
        @test abs(position[][1] - expected_x) < 1e-6
        @test abs(position[][2] - expected_y) < 1e-6

        # Test boundary constraints
        # Move to boundary
        for i in 1:100
            apply_movement_to_position!(position, state)
        end
        @test position[][1] <= 10.0
        @test position[][2] <= 10.0
        @test position[][1] >= -10.0
        @test position[][2] >= -10.0
    end

    @testset "State Management" begin
        state = MovementState()

        # Test quit request
        @test state.should_quit == false
        request_quit!(state)
        @test state.should_quit == true

        # Test state reset
        add_key!(state, 'w')
        reset_movement_state!(state)
        @test isempty(state.pressed_keys)
        @test state.should_quit == false
    end

    @testset "Utility Functions" begin
        state = MovementState()

        # Test movement key detection
        @test is_movement_key('w')
        @test is_movement_key('a')
        @test is_movement_key('s')
        @test is_movement_key('d')
        @test !is_movement_key('q')
        @test !is_movement_key('x')

        # Test pressed keys retrieval
        add_key!(state, 'w')
        add_key!(state, 'a')
        pressed = get_pressed_keys(state)
        @test pressed == Set(['w', 'a'])
        @test pressed !== state.pressed_keys  # Should be a copy

        # Test time formatting
        time_str = format_current_time()
        @test time_str isa String
        @test length(time_str) > 0
    end

    @testset "Error Handling" begin
        state = MovementState()

        # Test that invalid keys don't cause errors
        @test_nowarn add_key!(state, 'x')
        @test_nowarn remove_key!(state, 'x')

        # Test that clearing keys works even when empty
        @test_nowarn clear_all_keys_safely!(state)

        # Test that movement calculation works with invalid keys
        add_key!(state, 'x')
        @test_nowarn calculate_movement_vector(state)
        @test calculate_movement_vector(state) == [0.0, 0.0]
    end
end
