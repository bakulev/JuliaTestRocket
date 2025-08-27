# Error Handling Tests
# Backend-agnostic tests for error handling
# These tests don't require any Makie backend

using Test
using Logging: with_logger, NullLogger

@testset "Error Handling Tests" begin
    @testset "Backend Initialization Error Handling" begin
        # Test that backend check works (may or may not have backend)
        backend_loaded = PointController.check_backend_loaded()
        backend_name = PointController.get_backend_name()
        
        # Test that functions don't throw errors
        @test_nowarn PointController.check_backend_loaded()
        @test_nowarn PointController.get_backend_name()
        
        # If backend is loaded, it should have a name
        if backend_loaded
            @test backend_name !== nothing
            @test backend_name isa String
        else
            @test backend_name === nothing
        end
    end

    @testset "Movement State Error Handling" begin
        state = PointController.MovementState()

        # Test that invalid operations don't cause errors
        @test_nowarn PointController.add_key!(state, 'x')
        @test_nowarn PointController.remove_key!(state, 'x')
        @test_nowarn PointController.clear_all_keys_safely!(state)

        # Test movement calculation with invalid keys
        @test_nowarn PointController.calculate_movement_vector(state)
        @test PointController.calculate_movement_vector(state) == [0.0, 0.0]
    end

    @testset "Input Handler Error Handling" begin
        state = PointController.KeyState()

        # Test that invalid inputs don't cause errors
        @test_nowarn PointController.handle_key_press('x', state)
        @test_nowarn PointController.handle_key_release('x', state)

        # Test that the state remains consistent
        @test isempty(state.pressed_keys)
        @test state.should_quit == false
    end

    @testset "State Consistency" begin
        # Test that states remain consistent after errors
        movement_state = PointController.MovementState()
        key_state = PointController.KeyState()

        # Test movement state consistency
        @test_nowarn PointController.add_key!(movement_state, 'w')
        @test 'w' in movement_state.pressed_keys

        # Test key state consistency
        @test_nowarn PointController.handle_key_press('w', key_state)
        @test 'w' in key_state.pressed_keys
    end

    @testset "Boundary Conditions" begin
        # Test edge cases and boundary conditions
        movement_state = PointController.MovementState()

        # Test with empty state
        @test_nowarn PointController.calculate_movement_vector(movement_state)
        @test PointController.calculate_movement_vector(movement_state) == [0.0, 0.0]

        # Test with all keys pressed
        for key in ['w', 'a', 's', 'd']
            PointController.add_key!(movement_state, key)
        end
        @test_nowarn PointController.calculate_movement_vector(movement_state)
        movement = PointController.calculate_movement_vector(movement_state)
        @test length(movement) == 2
        @test all(isfinite, movement)
    end
end
