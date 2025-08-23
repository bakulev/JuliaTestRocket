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
    
    @testset "Input Handler Tests" begin
        @test isdefined(PointController, :handle_key_press)
        @test isdefined(PointController, :handle_key_release)
        @test isdefined(PointController, :calculate_movement_vector)
        
        state = MovementState()
        @test handle_key_press("w", state) === nothing
        @test handle_key_release("w", state) === nothing
        
        result = calculate_movement_vector(state)
        @test result isa Tuple{Float64, Float64}
        @test result == (0.0, 0.0)
    end
    
end