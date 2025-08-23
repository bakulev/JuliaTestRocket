# Test Keyboard Integration with GLMakie
# Tests for GLMakie keyboard event setup and integration

using Test
using PointController
using GLMakie

@testset "Keyboard Integration Tests" begin
    
    @testset "GLMakie Event Setup" begin
        # Test that we can create a figure and set up keyboard events
        # Note: GLMakie should be activated by the test runner
        GLMakie.activate!()
        fig = Figure()
        state = MovementState()
        
        # Test setup_keyboard_events! function
        result = setup_keyboard_events!(fig, state)
        @test result === fig
        
        # Test that the function doesn't throw errors
        @test_nowarn setup_keyboard_events!(fig, state)
        
        # Verify that events object exists on the figure
        @test hasfield(typeof(fig), :scene)
        @test fig.scene !== nothing
    end
    
    @testset "Event Handler Function Signatures" begin
        # Test that all required functions are exported and callable
        @test isdefined(PointController, :setup_keyboard_events!)
        @test isdefined(PointController, :handle_key_press)
        @test isdefined(PointController, :handle_key_release)
        @test isdefined(PointController, :calculate_movement_vector)
        @test isdefined(PointController, :is_movement_key)
        @test isdefined(PointController, :get_pressed_keys)
        
        # Test function signatures
        state = MovementState()
        fig = Figure()
        
        @test setup_keyboard_events!(fig, state) isa Figure
        @test handle_key_press("w", state) isa MovementState
        @test handle_key_release("w", state) isa MovementState
        @test calculate_movement_vector(state) isa Tuple{Float64, Float64}
        @test is_movement_key("w") isa Bool
        @test get_pressed_keys(state) isa Set{String}
    end
    
    @testset "Integration with Movement State" begin
        state = MovementState()
        
        # Test complete flow: press -> calculate -> release -> calculate
        @test isempty(get_pressed_keys(state))
        @test calculate_movement_vector(state) == (0.0, 0.0)
        
        # Press a key
        handle_key_press("w", state)
        @test "w" in get_pressed_keys(state)
        dx, dy = calculate_movement_vector(state)
        @test dx == 0.0
        @test dy == 1.0
        
        # Press another key for diagonal movement
        handle_key_press("d", state)
        @test length(get_pressed_keys(state)) == 2
        dx, dy = calculate_movement_vector(state)
        expected = 1.0 / sqrt(2.0)
        @test abs(dx - expected) < 1e-10
        @test abs(dy - expected) < 1e-10
        
        # Release one key
        handle_key_release("w", state)
        @test length(get_pressed_keys(state)) == 1
        @test "d" in get_pressed_keys(state)
        dx, dy = calculate_movement_vector(state)
        @test dx == 1.0
        @test dy == 0.0
        
        # Release last key
        handle_key_release("d", state)
        @test isempty(get_pressed_keys(state))
        @test calculate_movement_vector(state) == (0.0, 0.0)
    end
end