# Time Functions Tests
# Tests for time-related utility functions

using Test
using Observables: Observable
using PointController
using StaticArrays: SVector

# Define Point2f to match our implementation
const Point2f = SVector{2, Float32}

@testset "Time Functions Tests" begin
    @testset "format_current_time" begin
        # Test that format_current_time returns a string
        time_str = format_current_time()
        @test isa(time_str, String)
        @test !isempty(time_str)

        # Test that it returns a time format (HH:MM:SS)
        @test occursin(r"^\d{2}:\d{2}:\d{2}$", time_str)
    end

    @testset "create_time_observable" begin
        # Test that create_time_observable returns an observable
        time_obs = create_time_observable()
        @test isa(time_obs, Observable)
        @test isa(time_obs[], String)

        # Test that the observable contains a time string
        time_str = time_obs[]
        @test !isempty(time_str)
        @test occursin(r"^\d{2}:\d{2}:\d{2}$", time_str)
    end

    @testset "update_time_display!" begin
        # Test that update_time_display! updates the observable
        time_obs = Observable("00:00:00")
        @test_nowarn update_time_display!(time_obs)

        # Test that the observable was updated
        @test isa(time_obs[], String)
        @test !isempty(time_obs[])
        @test occursin(r"^\d{2}:\d{2}:\d{2}$", time_obs[])
    end

    @testset "update_movement_timing!" begin
        state = MovementState()
        initial_time = state.last_update_time
        initial_elapsed = state.elapsed_time

        # Test timing update with a small delay to ensure time difference
        sleep(0.001)  # Small delay to ensure time difference
        current_time = time()
        @test_nowarn update_movement_timing!(state, current_time)

        # Test that timing was updated
        @test state.last_update_time == current_time
        @test state.elapsed_time > 0.0  # Should be positive since some time passed
    end

    @testset "Movement State Timing Integration" begin
        state = MovementState()

        # Test initial timing state
        @test state.elapsed_time == 0.0
        @test state.last_update_time > 0.0  # Should be set to current time

        # Test timing update with movement
        add_key!(state, 'w')
        sleep(0.001)  # Small delay to ensure time difference
        current_time = time()
        update_movement_timing!(state, current_time)

        # Test that elapsed time is calculated correctly
        @test state.elapsed_time > 0.0
        @test state.last_update_time == current_time
    end
end
