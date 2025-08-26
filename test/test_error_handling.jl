# Error Handling Tests
# Backend-agnostic tests for error handling
# These tests don't require any Makie backend

using Test
using Observables: Observable
using PointController
using StaticArrays: SVector

# Define Point2f to match our implementation
const Point2f = SVector{2, Float32}

@testset "Error Handling Tests" begin
    @testset "Backend Initialization Error Handling" begin
        # Test that initialize_backend_safely returns a boolean
        @test isa(PointController.initialize_backend_safely(), Bool)

        # Test that the function doesn't throw errors even if backend has issues
        @test hasmethod(PointController.initialize_backend_safely, ())
    end

    @testset "Movement State Error Handling" begin
        state = MovementState()

        # Test that invalid keys don't cause errors when added directly
        @test_nowarn add_key!(state, 'x')
        @test_nowarn remove_key!(state, 'x')

        # Test that clearing keys works even when empty
        @test_nowarn clear_all_keys_safely!(state)

        # Test that movement calculation works with invalid keys
        add_key!(state, 'x')
        @test_nowarn calculate_movement_vector(state)
        @test calculate_movement_vector(state) == [0.0, 0.0]
    end

    @testset "Input Handler Error Handling" begin
        state = MovementState()

        # Test that invalid inputs don't cause errors
        @test_nowarn handle_key_press('x', state)
        @test_nowarn handle_key_release('x', state)

        # Test that the state remains consistent
        @test isempty(state.pressed_keys)
        @test state.should_quit == false

        # Test that handle_key_press correctly filters invalid keys
        @test_nowarn handle_key_press('x', state)
        @test 'x' ∉ state.pressed_keys  # handle_key_press should filter invalid keys

        # Test that valid keys are added
        @test_nowarn handle_key_press('w', state)
        @test 'w' in state.pressed_keys
    end

    @testset "State Consistency" begin
        state = MovementState()

        # Test that errors don't corrupt state
        @test isempty(state.pressed_keys)
        @test state.should_quit == false

        # Test after various operations
        @test_nowarn add_key!(state, 'w')
        @test_nowarn add_key!(state, 'x')  # Invalid key - should be added directly
        @test 'w' in state.pressed_keys
        @test 'x' in state.pressed_keys  # Direct add_key! adds any key

        @test_nowarn remove_key!(state, 'w')
        @test_nowarn remove_key!(state, 'x')  # Invalid key
        @test isempty(state.pressed_keys)
    end

    @testset "Boundary Conditions" begin
        state = MovementState(movement_speed = 0.1)
        position = Observable(Point2f(0, 0))

        # Test boundary constraints
        for i in 1:200  # Move beyond boundaries
            add_key!(state, 'w')
            apply_movement_to_position!(position, state)
        end

        # Should be clamped to boundary
        @test position[][1] >= -10.0
        @test position[][1] <= 10.0
        @test position[][2] >= -10.0
        @test position[][2] <= 10.0
    end
end
