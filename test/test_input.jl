# Test Input Handler Module
# Tests for keyboard event processing and key state tracking

using Test
using PointController

@testset "Input Handler Tests" begin
    
    @testset "Key Press Handling" begin
        state = MovementState()
        
        # Test valid key press
        handle_key_press("w", state)
        @test "w" in state.keys_pressed
        @test state.is_moving == true
        
        # Test multiple key presses
        handle_key_press("d", state)
        @test "w" in state.keys_pressed
        @test "d" in state.keys_pressed
        @test length(state.keys_pressed) == 2
        @test state.is_moving == true
        
        # Test case insensitive key press
        handle_key_press("A", state)
        @test "a" in state.keys_pressed
        @test length(state.keys_pressed) == 3
        
        # Test invalid key press (should be ignored)
        handle_key_press("x", state)
        @test "x" ∉ state.keys_pressed
        @test length(state.keys_pressed) == 3
        
        # Test duplicate key press (should not add duplicate)
        handle_key_press("w", state)
        @test length(state.keys_pressed) == 3
    end
    
    @testset "Key Release Handling" begin
        state = MovementState()
        
        # Add some keys first
        handle_key_press("w", state)
        handle_key_press("d", state)
        @test length(state.keys_pressed) == 2
        
        # Test valid key release
        handle_key_release("w", state)
        @test "w" ∉ state.keys_pressed
        @test "d" in state.keys_pressed
        @test length(state.keys_pressed) == 1
        @test state.is_moving == true
        
        # Test case insensitive key release
        handle_key_release("D", state)
        @test "d" ∉ state.keys_pressed
        @test length(state.keys_pressed) == 0
        @test state.is_moving == false
        
        # Test invalid key release (should be ignored)
        handle_key_release("x", state)
        @test length(state.keys_pressed) == 0
        
        # Test releasing non-pressed key (should be safe)
        handle_key_release("s", state)
        @test length(state.keys_pressed) == 0
    end
    
    @testset "Movement Vector Calculation" begin
        state = MovementState(2.0)  # Set movement speed to 2.0
        
        # Test no movement
        dx, dy = calculate_movement_vector(state)
        @test dx == 0.0
        @test dy == 0.0
        
        # Test single key movements
        handle_key_press("w", state)
        dx, dy = calculate_movement_vector(state)
        @test dx == 0.0
        @test dy == 2.0
        
        reset_movement_state!(state)
        handle_key_press("s", state)
        dx, dy = calculate_movement_vector(state)
        @test dx == 0.0
        @test dy == -2.0
        
        reset_movement_state!(state)
        handle_key_press("a", state)
        dx, dy = calculate_movement_vector(state)
        @test dx == -2.0
        @test dy == 0.0
        
        reset_movement_state!(state)
        handle_key_press("d", state)
        dx, dy = calculate_movement_vector(state)
        @test dx == 2.0
        @test dy == 0.0
        
        # Test diagonal movement (should be normalized)
        reset_movement_state!(state)
        handle_key_press("w", state)
        handle_key_press("d", state)
        dx, dy = calculate_movement_vector(state)
        expected_diagonal = 2.0 / sqrt(2.0)
        @test abs(dx - expected_diagonal) < 1e-10
        @test abs(dy - expected_diagonal) < 1e-10
        
        # Test opposite key cancellation
        reset_movement_state!(state)
        handle_key_press("w", state)
        handle_key_press("s", state)
        dx, dy = calculate_movement_vector(state)
        @test dx == 0.0
        @test dy == 0.0
        
        reset_movement_state!(state)
        handle_key_press("a", state)
        handle_key_press("d", state)
        dx, dy = calculate_movement_vector(state)
        @test dx == 0.0
        @test dy == 0.0
        
        # Test all keys pressed (should cancel out)
        reset_movement_state!(state)
        handle_key_press("w", state)
        handle_key_press("a", state)
        handle_key_press("s", state)
        handle_key_press("d", state)
        dx, dy = calculate_movement_vector(state)
        @test dx == 0.0
        @test dy == 0.0
    end
    
    @testset "Movement Key Validation" begin
        # Test valid movement keys
        @test is_movement_key("w") == true
        @test is_movement_key("W") == true
        @test is_movement_key("a") == true
        @test is_movement_key("A") == true
        @test is_movement_key("s") == true
        @test is_movement_key("S") == true
        @test is_movement_key("d") == true
        @test is_movement_key("D") == true
        
        # Test invalid keys
        @test is_movement_key("x") == false
        @test is_movement_key("1") == false
        @test is_movement_key(" ") == false
        @test is_movement_key("") == false
        @test is_movement_key("wasd") == false
    end
    
    @testset "Key State Tracking" begin
        state = MovementState()
        
        # Test empty state
        pressed_keys = get_pressed_keys(state)
        @test isempty(pressed_keys)
        @test state.is_moving == false
        
        # Test adding keys
        handle_key_press("w", state)
        handle_key_press("d", state)
        pressed_keys = get_pressed_keys(state)
        @test length(pressed_keys) == 2
        @test "w" in pressed_keys
        @test "d" in pressed_keys
        @test state.is_moving == true
        
        # Test that returned set is a copy (modifications don't affect original)
        push!(pressed_keys, "x")
        original_keys = get_pressed_keys(state)
        @test length(original_keys) == 2
        @test "x" ∉ original_keys
        
        # Test removing keys
        handle_key_release("w", state)
        pressed_keys = get_pressed_keys(state)
        @test length(pressed_keys) == 1
        @test "d" in pressed_keys
        @test state.is_moving == true
        
        # Test removing last key
        handle_key_release("d", state)
        pressed_keys = get_pressed_keys(state)
        @test isempty(pressed_keys)
        @test state.is_moving == false
    end
    
    @testset "Edge Cases and Error Handling" begin
        state = MovementState()
        
        # Test empty string key
        handle_key_press("", state)
        @test isempty(state.keys_pressed)
        
        # Test special characters
        handle_key_press("!", state)
        handle_key_press("@", state)
        handle_key_press("#", state)
        @test isempty(state.keys_pressed)
        
        # Test numbers
        handle_key_press("1", state)
        handle_key_press("2", state)
        @test isempty(state.keys_pressed)
        
        # Test very long string (should be handled gracefully)
        handle_key_press("this_is_a_very_long_key_name", state)
        @test isempty(state.keys_pressed)
        
        # Test movement calculation with zero speed
        state.movement_speed = 0.0
        handle_key_press("w", state)
        dx, dy = calculate_movement_vector(state)
        @test dx == 0.0
        @test dy == 0.0
        
        # Test movement calculation with negative speed
        state.movement_speed = -1.0
        dx, dy = calculate_movement_vector(state)
        @test dx == 0.0
        @test dy == -1.0  # Should move in opposite direction
    end
end