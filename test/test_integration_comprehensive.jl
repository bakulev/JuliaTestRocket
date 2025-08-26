# Comprehensive Integration Tests
# Tests for complete PointController functionality
# These tests use CairoMakie for headless CI compatibility

using Test
using PointController

@testset "Comprehensive Integration Tests" begin
    @testset "Complete Application Flow" begin
        # Test that all components can be created and connected
        @test_nowarn begin
            # Create visualization
            fig, ax, point_position, coordinate_text, time_obs = create_visualization()
            
            # Create movement state
            state = MovementState(movement_speed = 0.1)
            
            # Set up keyboard events
            setup_keyboard_events!(fig, state, point_position, time_obs)
            
            # Test basic functionality
            @test fig isa Figure
            @test state isa MovementState
            @test point_position isa Observable{Point2f}
        end
    end
    
    @testset "Movement and Visualization Integration" begin
        # Test that movement affects visualization
        fig, ax, point_position, coordinate_text, time_obs = create_visualization()
        state = MovementState(movement_speed = 0.1)
        
        # Test initial position
        @test point_position[] == Point2f(0, 0)
        
        # Test movement affects position
        add_key!(state, 'w')
        apply_movement_to_position!(point_position, state)
        @test point_position[] == Point2f(0, 0.1)
        
        # Test coordinate text updates
        @test occursin("0.0", coordinate_text[])
        @test occursin("0.1", coordinate_text[])
        
        # Test diagonal movement
        add_key!(state, 'd')
        apply_movement_to_position!(point_position, state)
        expected_x = 0.0 + 0.1/sqrt(2)
        expected_y = 0.1 + 0.1/sqrt(2)
        @test abs(point_position[][1] - expected_x) < 1e-6
        @test abs(point_position[][2] - expected_y) < 1e-6
    end
    
    @testset "Event System Integration" begin
        # Test that events can be set up without errors
        fig = Figure()
        state = MovementState()
        point_position = Observable(Point2f(0, 0))
        
        # Test keyboard event setup
        @test_nowarn setup_keyboard_events!(fig, state, point_position)
        
        # Test that events are properly connected
        @test hasfield(typeof(events(fig)), :keyboardbutton)
    end
    

    
    @testset "Error Recovery" begin
        # Test that errors don't crash the system
        state = MovementState()
        
        # Test invalid key handling
        @test_nowarn handle_key_press('x', state)
        @test_nowarn handle_key_release('x', state)
        
        # Test state remains consistent
        @test isempty(state.pressed_keys)
        @test state.should_quit == false
        
        # Test quit functionality
        using Logging: with_logger, NullLogger
        with_logger(NullLogger()) do
            @test_nowarn handle_key_press('q', state)
        end
        @test state.should_quit == true
    end
    
    @testset "Backend Detection" begin
        # Test backend detection (should work with CairoMakie)
        @test PointController.check_backend_loaded()
        @test PointController.get_backend_name() == "CairoMakie"
    end
    
    @testset "Performance and Memory" begin
        # Test that repeated operations don't cause issues
        state = MovementState()
        point_position = Observable(Point2f(0, 0))
        
        # Test many position updates
        for i in 1:100
            add_key!(state, 'w')
            apply_movement_to_position!(point_position, state)
            remove_key!(state, 'w')
        end
        
        # Test that state is still valid
        @test isempty(state.pressed_keys)
        @test point_position[] == Point2f(0, 10.0)  # Should hit boundary
    end
end
