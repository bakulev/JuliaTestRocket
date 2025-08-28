# PointController Module Tests
# Backend-agnostic tests for the PointController module
# These tests don't require any Makie backend

using Test

@testset "PointController Module Tests" begin
    @testset "Module Structure and Exports" begin
        # Test that the module is loaded
        @test PointController isa Module

        # Test that key functions are exported
        exported_names = names(PointController)
        @test :run_point_controller in exported_names
        @test :MovementState in exported_names
        @test :add_key! in exported_names
        @test :remove_key! in exported_names
        @test :calculate_movement_vector in exported_names
        @test :apply_movement_to_position in exported_names
        @test :handle_key_press in exported_names
        @test :handle_key_release in exported_names
        @test :is_movement_key in exported_names
        @test :get_pressed_keys in exported_names
        @test :setup_logging in exported_names
        @test :format_current_time in exported_names
        @test :create_time_observable in exported_names
    # Backend detection helpers are no longer exported
    end

    # Backend detection tests removed

    @testset "Module Constants and Types" begin
        # Test that KEY_MAPPINGS is exported and accessible
        @test haskey(PointController.KEY_MAPPINGS, 'w')
        @test haskey(PointController.KEY_MAPPINGS, 'a')
        @test haskey(PointController.KEY_MAPPINGS, 's')
        @test haskey(PointController.KEY_MAPPINGS, 'd')

        # Test that MovementState is accessible
        @test PointController.MovementState isa Type
        @test PointController.KeyState isa Type
    end

    @testset "Module Functionality" begin
        # Test basic functionality without backend
        movement_state = PointController.MovementState()
        key_state = PointController.KeyState()

        # Test movement state operations
        @test isempty(movement_state.pressed_keys)
        PointController.add_key!(movement_state, 'w')
        @test 'w' in movement_state.pressed_keys

        # Test key state operations
        @test isempty(key_state.pressed_keys)
        PointController.handle_key_press('w', key_state)
        @test 'w' in key_state.pressed_keys

        # Test that states work independently
        @test 'w' in movement_state.pressed_keys
        @test 'w' in key_state.pressed_keys

        # Test state copying
        PointController.copy_key_state_to_movement_state!(movement_state, key_state)
        @test 'w' in movement_state.pressed_keys
    end
end
