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

        # Movement state functions
        @test :MovementState in exported_names
        @test :apply_movement_to_position in exported_names
        @test :calculate_movement_vector in exported_names

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

    @testset "Backend Detection Functions" begin
        # Test backend checking functions
        @test hasmethod(PointController.check_backend_loaded, ())
        @test hasmethod(PointController.get_backend_name, ())

        # Test that these functions return expected types
        @test isa(PointController.check_backend_loaded(), Bool)
        backend_name = PointController.get_backend_name()
        @test isa(backend_name, Union{String, Nothing})
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
        @test hasmethod(
            PointController.handle_key_press,
            (Char, PointController.MovementState),
        )
        @test hasmethod(
            PointController.handle_key_release,
            (Char, PointController.MovementState),
        )
        @test hasmethod(PointController.setup_logging, ())
        @test hasmethod(PointController.setup_logging, (Base.CoreLogging.LogLevel,))
    end

    @testset "Module Functionality" begin
        # Test that key functions work correctly
        @test PointController.is_movement_key('w')
        @test PointController.is_movement_key('a')
        @test PointController.is_movement_key('s')
        @test PointController.is_movement_key('d')
        @test !PointController.is_movement_key('x')

        # Test movement state creation
        state = PointController.MovementState()
        @test isa(state, PointController.MovementState)

        # Test that we can add and remove keys
        @test_nowarn PointController.add_key!(state, 'w')
        @test 'w' in PointController.get_pressed_keys(state)
        @test_nowarn PointController.remove_key!(state, 'w')
        @test !('w' in PointController.get_pressed_keys(state))
    end
end
