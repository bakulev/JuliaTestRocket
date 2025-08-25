using Test
using PointController
using GLMakie

@testset "Task 5: Movement Calculation and Position Update Tests" begin
    @testset "Movement Vector Calculation from Keys" begin
        state = MovementState(movement_speed = 2.0)

        # Test single key movements
        add_key!(state, "w")
        movement = calculate_movement_vector(state)
        @test movement == (0.0, 2.0)

        reset_movement_state!(state)
        add_key!(state, "s")
        movement = calculate_movement_vector(state)
        @test movement == (0.0, -2.0)

        reset_movement_state!(state)
        add_key!(state, "a")
        movement = calculate_movement_vector(state)
        @test movement == (-2.0, 0.0)

        reset_movement_state!(state)
        add_key!(state, "d")
        movement = calculate_movement_vector(state)
        @test movement == (2.0, 0.0)
    end

    @testset "Diagonal Movement Handling" begin
        state = MovementState(movement_speed = 2.0)

        # Test diagonal movements (normalized)
        add_key!(state, "w")
        add_key!(state, "d")
        movement = calculate_movement_vector(state)
        expected_component = 2.0 / sqrt(2.0)
        @test movement[1] ≈ expected_component atol=1e-12
        @test movement[2] ≈ expected_component atol=1e-12

        reset_movement_state!(state)
        add_key!(state, "s")
        add_key!(state, "a")
        movement = calculate_movement_vector(state)
        @test movement[1] ≈ -expected_component atol=1e-12
        @test movement[2] ≈ -expected_component atol=1e-12

        # Test opposite keys cancel out
        reset_movement_state!(state)
        add_key!(state, "w")
        add_key!(state, "s")
        movement = calculate_movement_vector(state)
        @test movement == (0.0, 0.0)

        reset_movement_state!(state)
        add_key!(state, "a")
        add_key!(state, "d")
        movement = calculate_movement_vector(state)
        @test movement == (0.0, 0.0)
    end

    @testset "Position Update Logic" begin
        position = create_point_position()

        # Test basic position updates
        apply_movement_to_position!(position, (3.0, -2.0))
        pos = get_current_position(position)
        @test pos == (3.0, -2.0)

        # Test cumulative movement
        apply_movement_to_position!(position, (1.0, 4.0))
        pos = get_current_position(position)
        @test pos == (4.0, 2.0)

        # Test negative movement
        apply_movement_to_position!(position, (-2.0, -1.0))
        pos = get_current_position(position)
        @test pos == (2.0, 1.0)

        # Test zero movement
        apply_movement_to_position!(position, (0.0, 0.0))
        pos = get_current_position(position)
        @test pos == (2.0, 1.0)
    end

    @testset "State-Based Position Updates" begin
        state = MovementState(movement_speed = 1.0)
        position = create_point_position()

        # Test no movement when no keys pressed
        @test state.is_moving == false
        update_position_from_state!(position, state)
        pos = get_current_position(position)
        @test pos == (0.0, 0.0)

        # Test movement with single key
        add_key!(state, "w")
        @test state.is_moving == true
        update_position_from_state!(position, state)
        pos = get_current_position(position)
        @test pos == (0.0, 1.0)

        # Test additional movement
        update_position_from_state!(position, state)
        pos = get_current_position(position)
        @test pos == (0.0, 2.0)

        # Test diagonal movement
        add_key!(state, "d")
        update_position_from_state!(position, state)
        pos = get_current_position(position)
        expected_component = 1.0 / sqrt(2.0)
        @test pos[1] ≈ expected_component atol=1e-6
        @test pos[2] ≈ 2.0 + expected_component atol=1e-6

        # Test stopping movement
        reset_movement_state!(state)
        @test state.is_moving == false
        prev_pos = get_current_position(position)
        update_position_from_state!(position, state)
        pos = get_current_position(position)
        @test pos == prev_pos  # Position should not change
    end

    @testset "Movement Speed Variations" begin
        # Test different movement speeds
        for speed in [0.5, 1.0, 2.0, 5.0]
            state = MovementState(movement_speed = speed)
            position = create_point_position()

            add_key!(state, "w")
            update_position_from_state!(position, state)
            pos = get_current_position(position)
            @test pos == (0.0, speed)

            # Test diagonal with speed
            add_key!(state, "d")
            reset_movement_state!(state)
            add_key!(state, "w")
            add_key!(state, "d")
            position = create_point_position()  # Reset position
            update_position_from_state!(position, state)
            pos = get_current_position(position)
            expected_component = speed / sqrt(2.0)
            @test pos[1] ≈ expected_component atol=1e-10
            @test pos[2] ≈ expected_component atol=1e-10
        end
    end

    @testset "Edge Cases and Precision" begin
        state = MovementState(movement_speed = 1.0)
        position = create_point_position()

        # Test very small movements
        apply_movement_to_position!(position, (0.001, -0.001))
        pos = get_current_position(position)
        @test pos[1] ≈ 0.001 atol=1e-15
        @test pos[2] ≈ -0.001 atol=1e-15

        # Test large movements
        apply_movement_to_position!(position, (1000.0, -500.0))
        pos = get_current_position(position)
        @test pos[1] ≈ 1000.001 atol=1e-10
        @test pos[2] ≈ -500.001 atol=1e-10

        # Test all keys pressed (should cancel out)
        reset_movement_state!(state)
        add_key!(state, "w")
        add_key!(state, "a")
        add_key!(state, "s")
        add_key!(state, "d")
        movement = calculate_movement_vector(state)
        @test movement == (0.0, 0.0)
    end
end
