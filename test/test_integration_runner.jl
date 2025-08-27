# Integration Test Runner
# Specialized test runner for comprehensive integration tests

using Test

# Add the src directory to the load path for testing
push!(LOAD_PATH, "../src")

using GLMakie

println("Starting Comprehensive Integration Tests...")
println("=" ^ 60)

# Activate GLMakie backend for testing
GLMakie.activate!()

@testset "Comprehensive Integration Test Suite" begin

    # Include the comprehensive integration tests
    include("test_integration_comprehensive.jl")

    @testset "Integration Test Validation" begin
        @testset "All Required Functions Available" begin
            # Verify all functions needed for integration are exported
            required_functions = [
                :MovementState, :KEY_MAPPINGS,
                :handle_key_press, :handle_key_release, :calculate_movement_vector,
                :reset_movement_state!, :add_key!, :remove_key!, :request_quit!,
                :create_point_position, :update_point_position!, :get_current_position,
                :apply_movement_to_position!, :update_position_from_state!,
                :create_visualization, :setup_visualization_window,
                :update_coordinate_display!,
                :create_time_observable, :format_current_time,
                :setup_keyboard_events!, :is_movement_key, :get_pressed_keys]

            for func in required_functions
                @test isdefined(PointController, func)
            end
        end

        @testset "GLMakie Integration Validation" begin
            # Test figure creation
            fig = Figure()
            @test fig isa Figure

            # Test observable creation
            obs = Observable(Point2f(0.0, 0.0))
            @test obs isa Observable{Point2f}

            # Test event system availability
            @test hasfield(typeof(fig), :scene)
            @test fig.scene !== nothing

            # Test that GLMakie is activated
            @test_nowarn GLMakie.activate!()
        end

        @testset "Module Integration Validation" begin
            # Test that all modules are properly integrated
            @test isdefined(PointController, :MovementState)
            @test isdefined(PointController, :create_visualization)
            @test isdefined(PointController, :setup_keyboard_events!)

            # Test module exports
            @test MovementState isa Type
            @test KEY_MAPPINGS isa Dict

            # Test function signatures match expected interface
            state = MovementState()
            @test state isa MovementState

            position = create_point_position()
            @test position isa Observable{Point2f}

            fig, ax, pos, text, time_obs = create_visualization()
            @test fig isa Figure
            @test pos isa Observable{Point2f}
            @test text isa Observable{String}
        end
    end
end

println("=" ^ 60)
println("Integration tests completed!")
println("Run manual tests using: julia --project=. run_app.jl")
println("Manual testing procedures: test/manual_testing_procedures.md")
