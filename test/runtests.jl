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

    # Include input handler tests (backend-agnostic)
    include("test_input.jl")



    # Include error handling tests (backend-agnostic)
    include("test_error_handling.jl")
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
end
