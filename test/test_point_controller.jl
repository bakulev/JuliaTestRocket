using Test
using PointController

@testset "PointController Module Tests" begin
    @testset "Module Structure and Exports" begin
        @test PointController isa Module
        
        # Test that the module exports all expected functions
        exported_names = names(PointController)
        
        # Core module functions
        @test :run_point_controller in exported_names
        @test :check_backend_loaded in exported_names
        @test :get_backend_name in exported_names
        @test :initialize_backend_safely in exported_names
        @test :update_backend_detection in exported_names
        
        # Movement state functions
        @test :MovementState in exported_names
        @test :update_position! in exported_names
        @test :get_movement_vector in exported_names
        
        # Input handler functions
        @test :handle_key_press in exported_names
        @test :handle_key_release in exported_names
        @test :setup_keyboard_events! in exported_names
        
        # Visualization functions
        @test :create_visualization in exported_names
        @test :setup_visualization_window in exported_names
        @test :update_coordinate_display! in exported_names
        
        # Logging functions
        @test :setup_logging in exported_names
        @test :get_current_log_level in exported_names
    end
    
    @testset "File Structure Integrity" begin
        # Test that all source files can be included without errors
        # This verifies that the formatting changes (blank lines) don't break syntax
        
        @test_nowarn include("../src/PointController.jl")
        @test_nowarn include("../src/input_handler.jl")
        @test_nowarn include("../src/logging_config.jl") 
        @test_nowarn include("../src/movement_state.jl")
        @test_nowarn include("../src/visualization.jl")
    end
    
    @testset "Backend Detection Functions" begin
        # Test update_backend_detection function exists and is callable
        @test hasmethod(PointController.update_backend_detection, ())
        @test_nowarn PointController.update_backend_detection()
        
        # Test backend checking functions
        @test hasmethod(PointController.check_backend_loaded, ())
        @test hasmethod(PointController.get_backend_name, ())
        
        # Test that these functions return expected types
        @test isa(PointController.check_backend_loaded(), Bool)
        backend_name = PointController.get_backend_name()
        @test isa(backend_name, String)
    end
    
    @testset "Module Constants and Types" begin
        # Test that MovementState type is defined
        @test isdefined(PointController, :MovementState)
        @test PointController.MovementState isa Type
        
        # Test that we can create a MovementState instance
        @test_nowarn PointController.MovementState()
    end
    
    @testset "Function Signatures" begin
        # Test critical function signatures are correct
        @test hasmethod(PointController.initialize_backend_safely, ())
        @test hasmethod(PointController.handle_key_press, (Char, PointController.MovementState))
        @test hasmethod(PointController.handle_key_release, (Char, PointController.MovementState))
        @test hasmethod(PointController.setup_logging, (Symbol,))
    end
    
    @testset "Module Loading Stability" begin
        # Test that the module can be loaded multiple times without issues
        # This ensures the formatting changes don't introduce loading problems
        @test_nowarn eval(:(@eval module TestPointController using PointController end))
        @test_nowarn eval(:(using PointController))
        
        # Verify module is still functional after multiple loads
        @test PointController isa Module
    end
end