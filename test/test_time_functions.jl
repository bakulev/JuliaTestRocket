# Time Functions Tests
# Backend-agnostic tests for time-related functions
# These tests don't require any Makie backend

using Test
using Observables: Observable

@testset "Time Functions Tests" begin
    @testset "PointController.format_current_time" begin
        # Test time formatting
        time_str = PointController.format_current_time()
        @test time_str isa String
        @test length(time_str) > 0

        # Test that it returns a valid time format
        @test occursin(r"\d{2}:\d{2}:\d{2}", time_str)

        # Test multiple calls return valid times (they might be the same if executed quickly)
        time1 = PointController.format_current_time()
        sleep(0.1)
        time2 = PointController.format_current_time()
        @test time1 isa String
        @test time2 isa String
        @test length(time1) > 0
        @test length(time2) > 0
        # Note: times might be the same if executed quickly, which is fine
    end

    @testset "PointController.create_time_observable" begin
        # Test time observable creation
        time_obs = PointController.create_time_observable()
        @test time_obs isa Observable
        @test time_obs[] isa String
        @test length(time_obs[]) > 0

        # Test that observable contains valid time format
        @test occursin(r"\d{2}:\d{2}:\d{2}", time_obs[])
    end

    @testset "update_movement_timing!" begin
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
    end

    @testset "Movement State Timing Integration" begin
        state = PointController.MovementState()

        # Test that timing works with movement
        PointController.add_key!(state, 'w')
        
        # Update timing
        current_time = time()
        PointController.update_movement_timing!(state, current_time)
        
        # Apply movement with timing
        new_state = PointController.apply_movement_to_position(state, state.elapsed_time)
        @test new_state.position != state.position  # Should have moved
    end
end
