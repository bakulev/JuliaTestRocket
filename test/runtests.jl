using Test

# Add the src directory to the load path for testing
push!(LOAD_PATH, "../src")

using PointController

@testset "PointController.jl Tests" begin
    
    @testset "Basic Module Loading" begin
        @test PointController isa Module
        @test isdefined(PointController, :run_point_controller)
    end
    
    # Include comprehensive movement state tests
    include("test_movement_state.jl")
    
    # Include visualization tests
    include("test_visualization.jl")
    
    # Include comprehensive input handler tests
    include("test_input.jl")
    
end