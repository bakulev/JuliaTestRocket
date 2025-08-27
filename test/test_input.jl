# Input Handler Tests
# Backend-agnostic tests for input handling
# These tests don't require any Makie backend

using Test
using Logging: with_logger, NullLogger

@testset "Input Handler Tests" begin
    @testset "Key Press Handling" begin
        state = PointController.KeyState()

        # Test WASD key presses
        @test_nowarn PointController.handle_key_press('w', state)
        @test 'w' in state.pressed_keys

        @test_nowarn PointController.handle_key_press('a', state)
        @test 'a' in state.pressed_keys
        @test length(state.pressed_keys) == 2

        # Test quit key - temporarily suppress info messages
        @test state.should_quit == false
        with_logger(NullLogger()) do
            @test_nowarn PointController.handle_key_press('q', state)
        end
        @test state.should_quit == true

        # Test invalid keys (should be ignored)
        @test_nowarn PointController.handle_key_press('x', state)
        @test 'x' ∉ state.pressed_keys
    end

    @testset "Key Release Handling" begin
        state = PointController.KeyState()

        # Add some keys first
        PointController.press_key!(state, 'w')
        PointController.press_key!(state, 's')

        # Test key releases
        @test_nowarn PointController.handle_key_release('w', state)
        @test 'w' ∉ state.pressed_keys
        @test 's' in state.pressed_keys

        @test_nowarn PointController.handle_key_release('s', state)
        @test 's' ∉ state.pressed_keys
        @test isempty(state.pressed_keys)

        # Test releasing invalid keys (should be ignored)
        @test_nowarn PointController.handle_key_release('x', state)
    end

    @testset "Movement Key Detection" begin
        # Test valid movement keys
        @test PointController.is_movement_key('w')
        @test PointController.is_movement_key('a')
        @test PointController.is_movement_key('s')
        @test PointController.is_movement_key('d')
        @test PointController.is_movement_key('W')
        @test PointController.is_movement_key('A')
        @test PointController.is_movement_key('S')
        @test PointController.is_movement_key('D')

        # Test invalid keys
        @test !PointController.is_movement_key('q')
        @test !PointController.is_movement_key('x')
        @test !PointController.is_movement_key('1')
        @test !PointController.is_movement_key(' ')
    end

    @testset "Pressed Keys Retrieval" begin
        state = PointController.KeyState()

        # Test empty state
        pressed = PointController.get_pressed_keys(state)
        @test isempty(pressed)

        # Test with some keys
        PointController.press_key!(state, 'w')
        PointController.press_key!(state, 'a')
        pressed = PointController.get_pressed_keys(state)
        @test pressed == Set(['w', 'a'])

        # Test that it's a copy
        @test pressed !== state.pressed_keys
    end

    @testset "Error Handling" begin
        state = PointController.KeyState()

        # Test that invalid inputs don't cause errors
        @test_nowarn PointController.handle_key_press('x', state)
        @test_nowarn PointController.handle_key_release('x', state)

        # Test that the state remains consistent
        @test isempty(state.pressed_keys)
        @test state.should_quit == false
    end

    @testset "Integration with Movement State" begin
        # Test that key state can be used with movement state
        key_state = PointController.KeyState()
        movement_state = PointController.MovementState()

        # Test that key presses affect movement calculation
        @test PointController.calculate_movement_vector(movement_state) == [0.0, 0.0]

        PointController.handle_key_press('w', key_state)
        # Copy key state to movement state
        PointController.copy_key_state_to_movement_state!(movement_state, key_state)
        @test PointController.calculate_movement_vector(movement_state) == [0.0, 1.0]

        PointController.handle_key_press('d', key_state)
        PointController.copy_key_state_to_movement_state!(movement_state, key_state)
        movement = PointController.calculate_movement_vector(movement_state)
        @test abs(movement[1] - (1/sqrt(2))) < 1e-10
        @test abs(movement[2] - (1/sqrt(2))) < 1e-10

        PointController.handle_key_release('w', key_state)
        PointController.copy_key_state_to_movement_state!(movement_state, key_state)
        @test PointController.calculate_movement_vector(movement_state) == [1.0, 0.0]
    end
end
