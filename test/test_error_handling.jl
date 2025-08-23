# Test Error Handling and Robustness Features
# This file tests the error handling and robustness improvements added in task 9

using Test
using PointController
using GLMakie

@testset "Error Handling and Robustness Tests" begin
    
    @testset "GLMakie Initialization Error Handling" begin
        # Test that initialize_glmakie_safely returns a boolean
        @test isa(initialize_glmakie_safely(), Bool)
        
        # Test that the function doesn't throw errors even if GLMakie has issues
        # (This is hard to test directly without mocking, but we can test the function exists)
        @test hasmethod(initialize_glmakie_safely, ())
    end
    
    @testset "Invalid Key Input Handling" begin
        state = MovementState(1.0)
        
        # Test handling of empty key strings
        original_keys = copy(state.keys_pressed)
        handle_key_press("", state)
        @test state.keys_pressed == original_keys  # Should be unchanged
        
        handle_key_release("", state)
        @test state.keys_pressed == original_keys  # Should be unchanged
        
        # Test handling of invalid key types (non-movement keys)
        handle_key_press("x", state)  # Invalid movement key
        @test !("x" in state.keys_pressed)  # Should not be added
        
        handle_key_press("1", state)  # Number key
        @test !("1" in state.keys_pressed)  # Should not be added
        
        handle_key_press("space", state)  # Special key
        @test !("space" in state.keys_pressed)  # Should not be added
        
        # Test that valid keys still work
        handle_key_press("w", state)
        @test "w" in state.keys_pressed
        
        handle_key_release("w", state)
        @test !("w" in state.keys_pressed)
    end
    
    @testset "Movement State Robustness" begin
        state = MovementState(1.0)
        
        # Test clear_all_keys_safely! function
        add_key!(state, "w")
        add_key!(state, "a")
        @test length(state.keys_pressed) == 2
        @test state.is_moving == true
        
        clear_all_keys_safely!(state)
        @test length(state.keys_pressed) == 0
        @test state.is_moving == false
        
        # Test that clear_all_keys_safely! doesn't throw errors
        @test_nowarn clear_all_keys_safely!(state)
        @test_nowarn clear_all_keys_safely!(state)  # Call twice to test robustness
    end
    
    @testset "Timer Error Handling" begin
        state = MovementState(1.0)
        
        # Test that stop_movement_timer! is safe to call multiple times
        @test_nowarn stop_movement_timer!(state)
        @test_nowarn stop_movement_timer!(state)
        @test state.update_timer === nothing
        
        # Test invalid update intervals are handled
        position = create_point_position()
        
        # Test with invalid intervals (should use default)
        @test_nowarn start_movement_timer!(state, position, -1.0)  # Negative
        @test_nowarn stop_movement_timer!(state)
        
        @test_nowarn start_movement_timer!(state, position, 0.0)   # Zero
        @test_nowarn stop_movement_timer!(state)
        
        @test_nowarn start_movement_timer!(state, position, 2.0)   # Too large
        @test_nowarn stop_movement_timer!(state)
    end
    
    @testset "Application Cleanup" begin
        state = MovementState(1.0)
        
        # Test cleanup function doesn't throw errors
        @test_nowarn cleanup_application_safely(state)
        @test_nowarn cleanup_application_safely(nothing)  # Test with nothing
        
        # Test cleanup with active timer
        position = create_point_position()
        start_movement_timer!(state, position)
        @test_nowarn cleanup_application_safely(state)
        @test state.update_timer === nothing
    end
    
    @testset "Error Message Functions" begin
        # Test that error handling functions exist and can be called
        @test hasmethod(handle_application_error, (Exception, Any, Any))
        @test hasmethod(cleanup_application_safely, (Any,))
        
        # Test error handling with different exception types
        test_error = ErrorException("Test error")
        @test_nowarn handle_application_error(test_error, nothing, nothing)
        
        interrupt_error = InterruptException()
        @test_nowarn handle_application_error(interrupt_error, nothing, nothing)
    end
    
    @testset "Performance Optimizations" begin
        # Test that visualization functions include performance settings
        @test hasmethod(create_visualization_safely, ())
        @test hasmethod(setup_visualization_window_safely, (Figure,))
        
        # Test that movement calculations are bounded for performance
        state = MovementState(1.0)
        add_key!(state, "w")
        add_key!(state, "d")  # Diagonal movement
        
        movement = calculate_movement_vector(state)
        # Check that diagonal movement is normalized (should be less than individual axis movement)
        @test abs(movement[1]) < 1.0
        @test abs(movement[2]) < 1.0
        @test movement[1] ≈ movement[2]  # Should be equal for diagonal
    end
    
    @testset "Robustness Features" begin
        # Test that all robustness functions exist
        @test hasmethod(setup_window_focus_handling!, (Figure, MovementState))
        @test hasmethod(setup_keyboard_events_safely!, (Figure, MovementState, Observable{Point2f}))
        
        # Test movement state validation
        state = MovementState(1.0)
        
        # Test that movement speed is properly bounded
        @test state.movement_speed > 0.0
        @test state.movement_speed < 10.0  # Reasonable upper bound
        
        # Test that timing updates are safe
        @test_nowarn update_movement_timing!(state)
        @test state.last_update_time > 0.0
    end
end

println("Error handling and robustness tests completed successfully!")