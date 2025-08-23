using Test

# Add the src directory to the load path for testing
push!(LOAD_PATH, "../src")

using PointController

@testset "PointController.jl Tests" begin
    
    @testset "Basic Module Loading" begin
        @test PointController isa Module
        @test isdefined(PointController, :run_point_controller)
    end
    
    @testset "MovementState Tests" begin
        @test isdefined(PointController, :MovementState)
        state = MovementState(2.0)
        @test state isa MovementState
        @test state.movement_speed == 2.0
        @test isempty(state.keys_pressed)
    end
    
    @testset "Key Mappings Tests" begin
        @test isdefined(PointController, :KEY_MAPPINGS)
        @test haskey(KEY_MAPPINGS, "w")
        @test haskey(KEY_MAPPINGS, "a") 
        @test haskey(KEY_MAPPINGS, "s")
        @test haskey(KEY_MAPPINGS, "d")
        @test KEY_MAPPINGS["w"] == (0.0, 1.0)
        @test KEY_MAPPINGS["s"] == (0.0, -1.0)
    end
    
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