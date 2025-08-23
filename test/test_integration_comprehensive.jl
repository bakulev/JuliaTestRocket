# Comprehensive Integration Tests
# Tests for complete keyboard-to-movement flow, simultaneous key combinations,
# coordinate display accuracy, and end-to-end validation

using Test
using PointController
using GLMakie

@testset "Comprehensive Integration Tests" begin
    
    @testset "Complete Keyboard-to-Movement Flow" begin
        # Test the complete flow from keyboard input to position update
        # Note: GLMakie should be activated by the test runner
        GLMakie.activate!()
        
        # Initialize all components
        fig, ax, point_position, coordinate_text = create_visualization()
        movement_state = MovementState(movement_speed = 1.0)
        
        # Set up keyboard events
        setup_keyboard_events!(fig, movement_state, point_position)
        
        # Test initial state
        @test get_current_position(point_position) == (0.0, 0.0)
        @test isempty(get_pressed_keys(movement_state))
        @test !movement_state.is_moving
        
        # Simulate key press and verify complete flow
        handle_key_press("w", movement_state)
        @test "w" in get_pressed_keys(movement_state)
        @test movement_state.is_moving
        
        # Calculate and apply movement
        movement_vector = calculate_movement_vector(movement_state)
        @test movement_vector == (0.0, 1.0)
        
        # Apply movement to position
        apply_movement_to_position!(point_position, movement_vector)
        new_pos = get_current_position(point_position)
        @test new_pos == (0.0, 1.0)
        
        # Verify coordinate display updates
        coord_display = coordinate_text[]
        @test occursin("0.0", coord_display)
        @test occursin("1.0", coord_display)
        
        # Test key release completes the flow
        handle_key_release("w", movement_state)
        @test isempty(get_pressed_keys(movement_state))
        @test !movement_state.is_moving
        
        # Verify no further movement occurs
        old_pos = get_current_position(point_position)
        update_position_from_state!(point_position, movement_state)
        @test get_current_position(point_position) == old_pos
    end
    
    @testset "Simultaneous Key Press Combinations for Diagonal Movement" begin
        movement_state = MovementState(movement_speed = 2.0)
        point_position = create_point_position()
        
        # Test all diagonal combinations
        diagonal_combinations = [
            (["w", "d"], "up-right"),
            (["w", "a"], "up-left"), 
            (["s", "d"], "down-right"),
            (["s", "a"], "down-left")
        ]
        
        for (keys, direction) in diagonal_combinations
            # Reset state for each test
            reset_movement_state!(movement_state)
            update_point_position!(point_position, 0.0, 0.0)
            
            # Press both keys simultaneously
            for key in keys
                handle_key_press(key, movement_state)
            end
            
            # Verify both keys are registered
            pressed_keys = get_pressed_keys(movement_state)
            @test length(pressed_keys) == 2
            for key in keys
                @test key in pressed_keys
            end
            @test movement_state.is_moving
            
            # Calculate diagonal movement vector
            movement_vector = calculate_movement_vector(movement_state)
            expected_magnitude = 2.0 / sqrt(2.0)  # Normalized diagonal with speed 2.0
            
            # Verify diagonal movement is properly normalized
            actual_magnitude = sqrt(movement_vector[1]^2 + movement_vector[2]^2)
            @test abs(actual_magnitude - 2.0) < 1e-10  # Should maintain original speed
            
            # Verify direction is correct
            if direction == "up-right"
                @test movement_vector[1] ≈ expected_magnitude atol=1e-10
                @test movement_vector[2] ≈ expected_magnitude atol=1e-10
            elseif direction == "up-left"
                @test movement_vector[1] ≈ -expected_magnitude atol=1e-10
                @test movement_vector[2] ≈ expected_magnitude atol=1e-10
            elseif direction == "down-right"
                @test movement_vector[1] ≈ expected_magnitude atol=1e-10
                @test movement_vector[2] ≈ -expected_magnitude atol=1e-10
            elseif direction == "down-left"
                @test movement_vector[1] ≈ -expected_magnitude atol=1e-10
                @test movement_vector[2] ≈ -expected_magnitude atol=1e-10
            end
            
            # Apply movement and verify position
            apply_movement_to_position!(point_position, movement_vector)
            final_pos = get_current_position(point_position)
            
            # Verify the point moved in the correct diagonal direction
            if direction == "up-right"
                @test final_pos[1] > 0.0 && final_pos[2] > 0.0
            elseif direction == "up-left"
                @test final_pos[1] < 0.0 && final_pos[2] > 0.0
            elseif direction == "down-right"
                @test final_pos[1] > 0.0 && final_pos[2] < 0.0
            elseif direction == "down-left"
                @test final_pos[1] < 0.0 && final_pos[2] < 0.0
            end
            
            # Test releasing keys one by one
            handle_key_release(keys[1], movement_state)
            @test length(get_pressed_keys(movement_state)) == 1
            @test keys[2] in get_pressed_keys(movement_state)
            @test movement_state.is_moving  # Should still be moving with one key
            
            handle_key_release(keys[2], movement_state)
            @test isempty(get_pressed_keys(movement_state))
            @test !movement_state.is_moving
        end
    end
    
    @testset "Coordinate Display Accuracy During Movement" begin
        # Note: GLMakie should be activated by the test runner
        GLMakie.activate!()
        fig, ax, point_position, coordinate_text = create_visualization()
        movement_state = MovementState(movement_speed = 0.5)  # Slower speed for precision testing
        
        # Test coordinate display accuracy with various movements
        test_movements = [
            ("w", (0.0, 0.5)),
            ("d", (0.5, 0.5)),
            ("s", (0.5, 0.0)),
            ("a", (0.0, 0.0))
        ]
        
        for (key, expected_pos) in test_movements
            # Press key and apply movement
            handle_key_press(key, movement_state)
            movement_vector = calculate_movement_vector(movement_state)
            apply_movement_to_position!(point_position, movement_vector)
            
            # Verify position accuracy
            actual_pos = get_current_position(point_position)
            @test abs(actual_pos[1] - expected_pos[1]) < 1e-10
            @test abs(actual_pos[2] - expected_pos[2]) < 1e-10
            
            # Verify coordinate display reflects accurate position
            coord_display = coordinate_text[]
            @test occursin("Position:", coord_display)
            
            # Extract coordinates from display string and verify accuracy
            # The display format should be "Position: (x.x, y.y)"
            pos_match = match(r"Position:\s*\(\s*([-+]?\d*\.?\d+)\s*,\s*([-+]?\d*\.?\d+)\s*\)", coord_display)
            if pos_match !== nothing
                display_x = parse(Float64, pos_match.captures[1])
                display_y = parse(Float64, pos_match.captures[2])
                @test abs(display_x - expected_pos[1]) < 1e-6
                @test abs(display_y - expected_pos[2]) < 1e-6
            end
            
            # Release key for next iteration
            handle_key_release(key, movement_state)
        end
        
        # Test coordinate display with diagonal movement
        handle_key_press("w", movement_state)
        handle_key_press("d", movement_state)
        
        movement_vector = calculate_movement_vector(movement_state)
        apply_movement_to_position!(point_position, movement_vector)
        
        actual_pos = get_current_position(point_position)
        coord_display = coordinate_text[]
        
        # Verify diagonal coordinates are displayed accurately
        expected_component = 0.5 / sqrt(2.0)
        @test abs(actual_pos[1] - expected_component) < 1e-6
        @test abs(actual_pos[2] - expected_component) < 1e-6
        
        # Clean up
        handle_key_release("w", movement_state)
        handle_key_release("d", movement_state)
    end
    
    @testset "Complex Multi-Key Scenarios" begin
        movement_state = MovementState(movement_speed = 1.0)
        point_position = create_point_position()
        
        # Test rapid key press/release sequences
        key_sequence = ["w", "d", "s", "a", "w", "d"]
        
        for key in key_sequence
            handle_key_press(key, movement_state)
            @test key in get_pressed_keys(movement_state)
            @test movement_state.is_moving
            
            # Apply movement
            movement_vector = calculate_movement_vector(movement_state)
            old_pos = get_current_position(point_position)
            apply_movement_to_position!(point_position, movement_vector)
            new_pos = get_current_position(point_position)
            
            # Verify position changed (unless opposite keys cancel out)
            if length(get_pressed_keys(movement_state)) > 1
                # Check if opposite keys are pressed
                pressed = get_pressed_keys(movement_state)
                has_opposite = ("w" in pressed && "s" in pressed) || ("a" in pressed && "d" in pressed)
                if !has_opposite
                    # Position should change if no opposite keys
                    @test new_pos != old_pos
                end
            else
                # Single key should always cause movement
                @test new_pos != old_pos
            end
        end
        
        # Test releasing keys in different order
        release_sequence = ["s", "w", "a", "d"]
        for key in release_sequence
            if key in get_pressed_keys(movement_state)
                handle_key_release(key, movement_state)
                @test key ∉ get_pressed_keys(movement_state)
            end
        end
        
        @test isempty(get_pressed_keys(movement_state))
        @test !movement_state.is_moving
    end
    
    @testset "Opposite Key Cancellation Integration" begin
        movement_state = MovementState(movement_speed = 1.0)
        point_position = create_point_position()
        
        # Test that opposite keys cancel movement
        opposite_pairs = [("w", "s"), ("a", "d")]
        
        for (key1, key2) in opposite_pairs
            reset_movement_state!(movement_state)
            initial_pos = get_current_position(point_position)
            
            # Press both opposite keys
            handle_key_press(key1, movement_state)
            handle_key_press(key2, movement_state)
            
            # Verify both keys are registered but movement is cancelled
            pressed_keys = get_pressed_keys(movement_state)
            @test key1 in pressed_keys
            @test key2 in pressed_keys
            @test movement_state.is_moving  # State shows moving but vector should be zero
            
            # Calculate movement - should be zero due to cancellation
            movement_vector = calculate_movement_vector(movement_state)
            @test movement_vector == (0.0, 0.0)
            
            # Apply "movement" - position should not change
            apply_movement_to_position!(point_position, movement_vector)
            final_pos = get_current_position(point_position)
            @test final_pos == initial_pos
            
            # Release one key - should resume movement
            handle_key_release(key1, movement_state)
            movement_vector = calculate_movement_vector(movement_state)
            @test movement_vector != (0.0, 0.0)  # Should have movement now
            
            # Clean up
            handle_key_release(key2, movement_state)
        end
    end
    
    @testset "Timing and Continuous Movement Integration" begin
        movement_state = MovementState(movement_speed = 1.0)
        point_position = create_point_position()
        
        # Test timing system integration
        @test movement_state.update_timer === nothing
        @test movement_state.last_update_time == 0.0
        
        # Simulate starting movement timer
        handle_key_press("w", movement_state)
        update_movement_timing!(movement_state)
        @test movement_state.last_update_time > 0.0
        
        # Test multiple position updates simulate continuous movement
        initial_pos = get_current_position(point_position)
        
        for i in 1:5
            update_position_from_state!(point_position, movement_state)
            current_pos = get_current_position(point_position)
            @test current_pos[2] > initial_pos[2]  # Y should keep increasing
            @test current_pos[2] ≈ i * 1.0 atol=1e-10  # Should be i units up
        end
        
        # Test stopping movement
        handle_key_release("w", movement_state)
        final_pos = get_current_position(point_position)
        
        # Apply update - position should not change
        update_position_from_state!(point_position, movement_state)
        @test get_current_position(point_position) == final_pos
    end
    
    @testset "Error Handling and Edge Cases" begin
        movement_state = MovementState(movement_speed = 1.0)
        point_position = create_point_position()
        
        # Test invalid key handling
        invalid_keys = ["", "x", "1", "!", "wasd", "W A S D"]
        
        for invalid_key in invalid_keys
            initial_keys = copy(get_pressed_keys(movement_state))
            handle_key_press(invalid_key, movement_state)
            @test get_pressed_keys(movement_state) == initial_keys  # Should be unchanged
        end
        
        # Test case insensitivity
        handle_key_press("W", movement_state)
        @test "w" in get_pressed_keys(movement_state)
        handle_key_release("w", movement_state)
        @test isempty(get_pressed_keys(movement_state))
        
        # Test releasing non-pressed keys
        @test_nowarn handle_key_release("s", movement_state)
        @test_nowarn handle_key_release("invalid", movement_state)
        
        # Test with zero movement speed
        movement_state.movement_speed = 0.0
        handle_key_press("w", movement_state)
        movement_vector = calculate_movement_vector(movement_state)
        @test movement_vector == (0.0, 0.0)
        
        # Test with negative movement speed
        movement_state.movement_speed = -1.0
        movement_vector = calculate_movement_vector(movement_state)
        @test movement_vector == (0.0, -1.0)  # Should move in opposite direction
        
        handle_key_release("w", movement_state)
    end
    
    @testset "Quit Functionality Integration" begin
        movement_state = MovementState(movement_speed = 1.0)
        
        # Test initial quit state
        @test !movement_state.should_quit
        
        # Test quit key press
        handle_key_press("q", movement_state)
        @test movement_state.should_quit
        
        # Test that quit doesn't interfere with movement keys
        movement_state2 = MovementState(movement_speed = 1.0)
        handle_key_press("w", movement_state2)
        handle_key_press("q", movement_state2)
        @test "w" in get_pressed_keys(movement_state2)
        @test movement_state2.is_moving
        @test movement_state2.should_quit
        
        # Test reset clears quit flag
        reset_movement_state!(movement_state2)
        @test !movement_state2.should_quit
        @test !movement_state2.is_moving
        @test isempty(get_pressed_keys(movement_state2))
    end
end