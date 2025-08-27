using Test

# Add the src directory to the load path for testing
push!(LOAD_PATH, "../src")

# Load the PointController module
using PointController

# Backend-agnostic tests (no rendering)
@testset "PointController.jl Tests" begin
    @testset "Basic Module Loading" begin
        @test PointController isa Module
        @test isdefined(PointController, :run_point_controller)
    end

    # Include comprehensive movement state tests (backend-agnostic)
    include("test_movement_state.jl")
    
    # Include PointController module tests (backend-agnostic)
    include("test_point_controller.jl")
    
    # Include input handler tests (backend-agnostic)
    include("test_input.jl")
    
    # Include formatting integrity tests (backend-agnostic)
    include("test_formatting_integrity.jl")
    
    # Include error handling tests (backend-agnostic)
    include("test_error_handling.jl")
    
    # Include logging tests (backend-agnostic)
    include("test_logging.jl")
    
    # Include time function tests (backend-agnostic)
    include("test_time_functions.jl")
    
    # Include backend detection tests (backend-agnostic)
    include("test_backend_detection.jl")
    
    # Include extended movement state tests (backend-agnostic)
    include("test_movement_state_extended.jl")
end

# Backend-specific tests (only run if backend is available)
@testset "Backend-Specific Tests" begin
    # Test with CairoMakie (headless, deterministic)
    @testset "CairoMakie Tests" begin
        try
            using CairoMakie
            CairoMakie.activate!()

            # Include visualization tests with CairoMakie
            include("test_visualization.jl")

            # Include integration tests with CairoMakie
            include("test_integration_comprehensive.jl")

        catch e
            @warn "CairoMakie not available, skipping CairoMakie tests: $e"
        end
    end

    # Test with GLMakie (interactive, requires display)
    # Skip in CI environments where display is not available
    if !haskey(ENV, "CI") || get(ENV, "CI", "false") != "true"
        @testset "GLMakie Tests" begin
            try
                using GLMakie
                GLMakie.activate!()

                # Include GLMakie-specific tests
                include("test_glmakie_smoke.jl")

            catch e
                @warn "GLMakie not available, skipping GLMakie tests: $e"
            end
        end
    else
        @testset "GLMakie Tests" begin
            @test_skip "GLMakie tests skipped in CI environment"
        end
    end
end
