# Input Handler Tests
# Backend-agnostic tests for input handling
# These tests don't require any Makie backend

using Test
using Logging: with_logger, NullLogger
using PointController

@testset "Input Handler Tests" begin
    @testset "Key Press Handling" begin
        state = MovementState()
        
        # Test WASD key presses
        @test_nowarn handle_key_press('w', state)
        @test 'w' in state.pressed_keys
        
        @test_nowarn handle_key_press('a', state)
        @test 'a' in state.pressed_keys
        @test length(state.pressed_keys) == 2
        
        # Test quit key - temporarily suppress info messages
        @test state.should_quit == false
        with_logger(NullLogger()) do
            @test_nowarn handle_key_press('q', state)
        end
        @test state.should_quit == true
        
        # Test invalid keys (should be ignored)
        @test_nowarn handle_key_press('x', state)
        @test 'x' ∉ state.pressed_keys
    end
    
    @testset "Key Release Handling" begin
        state = MovementState()
        
        # Add some keys first
        add_key!(state, 'w')
        add_key!(state, 's')
        
        # Test key releases
        @test_nowarn handle_key_release('w', state)
        @test 'w' ∉ state.pressed_keys
        @test 's' in state.pressed_keys
        
        @test_nowarn handle_key_release('s', state)
        @test 's' ∉ state.pressed_keys
        @test isempty(state.pressed_keys)
        
        # Test releasing invalid keys (should be ignored)
        @test_nowarn handle_key_release('x', state)
    end
    
    @testset "Movement Key Detection" begin
        # Test valid movement keys
        @test is_movement_key('w')
        @test is_movement_key('a')
        @test is_movement_key('s')
        @test is_movement_key('d')
        @test is_movement_key('W')
        @test is_movement_key('A')
        @test is_movement_key('S')
        @test is_movement_key('D')
        
        # Test invalid keys
        @test !is_movement_key('q')
        @test !is_movement_key('x')
        @test !is_movement_key('1')
        @test !is_movement_key(' ')
    end
    
    @testset "Pressed Keys Retrieval" begin
        state = MovementState()
        
        # Test empty state
        pressed = get_pressed_keys(state)
        @test isempty(pressed)
        
        # Test with some keys
        add_key!(state, 'w')
        add_key!(state, 'a')
        pressed = get_pressed_keys(state)
        @test pressed == Set(['w', 'a'])
        
        # Test that it's a copy
        @test pressed !== state.pressed_keys
    end
    
    @testset "Error Handling" begin
        state = MovementState()
        
        # Test that invalid inputs don't cause errors
        @test_nowarn handle_key_press('x', state)
        @test_nowarn handle_key_release('x', state)
        
        # Test that the state remains consistent
        @test isempty(state.pressed_keys)
        @test state.should_quit == false
    end
    
    @testset "Integration with Movement State" begin
        state = MovementState()
        
        # Test that key presses affect movement calculation
        @test calculate_movement_vector(state) == [0.0, 0.0]
        
        handle_key_press('w', state)
        @test calculate_movement_vector(state) == [0.0, 1.0]
        
        handle_key_press('d', state)
        movement = calculate_movement_vector(state)
        @test abs(movement[1] - (1/sqrt(2))) < 1e-10
        @test abs(movement[2] - (1/sqrt(2))) < 1e-10
        
        handle_key_release('w', state)
        @test calculate_movement_vector(state) == [1.0, 0.0]
    end
end
