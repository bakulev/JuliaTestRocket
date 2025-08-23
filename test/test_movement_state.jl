using Test
using PointController
using GLMakie

@testset "MovementState Tests" begin
    
    @testset "MovementState Construction" begin
        # Test default constructor
        state = MovementState()
        @test state.movement_speed == 1.0
        @test isempty(state.keys_pressed)
        @test state.last_update_time == 0.0
        @test state.is_moving == false
        
        # Test constructor with custom speed
        state_custom = MovementState(2.5)
        @test state_custom.movement_speed == 2.5
        @test isempty(state_custom.keys_pressed)
        @test state_custom.is_moving == false
    end
    
    @testset "Key Management" begin
        state = MovementState()
        
        # Test adding keys
        add_key!(state, "w")
        @test "w" in state.keys_pressed
        @test state.is_moving == true
        
        add_key!(state, "D")  # Test case insensitive
        @test "d" in state.keys_pressed
        @test length(state.keys_pressed) == 2
        
        # Test removing keys
        remove_key!(state, "w")
        @test "w" ∉ state.keys_pressed
        @test "d" in state.keys_pressed
        @test state.is_moving == true  # Still moving because 'd' is pressed
        
        remove_key!(state, "d")
        @test isempty(state.keys_pressed)
        @test state.is_moving == false
    end
    
    @testset "Reset Movement State" begin
        state = MovementState(3.0)
        add_key!(state, "w")
        add_key!(state, "a")
        state.last_update_time = 100.0
        
        reset_movement_state!(state)
        @test isempty(state.keys_pressed)
        @test state.is_moving == false
        @test state.last_update_time == 0.0
        @test state.movement_speed == 3.0  # Speed should remain unchanged
    end
end

@testset "Key Mappings Tests" begin
    @test haskey(KEY_MAPPINGS, "w")
    @test haskey(KEY_MAPPINGS, "a")
    @test haskey(KEY_MAPPINGS, "s")
    @test haskey(KEY_MAPPINGS, "d")
    
    # Test mapping values
    @test KEY_MAPPINGS["w"] == (0.0, 1.0)   # Up
    @test KEY_MAPPINGS["s"] == (0.0, -1.0)  # Down
    @test KEY_MAPPINGS["a"] == (-1.0, 0.0)  # Left
    @test KEY_MAPPINGS["d"] == (1.0, 0.0)   # Right
    
    # Test that all mappings are normalized vectors
    for (key, (x, y)) in KEY_MAPPINGS
        magnitude = sqrt(x^2 + y^2)
        @test magnitude ≈ 1.0 atol=1e-10
    end
end

@testset "Observable Point Position Tests" begin
    # Test creation
    position = create_point_position()
    @test position isa Observable{Point2f}
    
    # Test initial position
    initial_pos = get_current_position(position)
    @test initial_pos == (0.0, 0.0)
    
    # Test updating position
    update_point_position!(position, 5.0, -3.0)
    new_pos = get_current_position(position)
    @test new_pos == (5.0, -3.0)
    
    # Test that observable updates properly
    @test position[] == Point2f(5.0, -3.0)
    
    # Test multiple updates
    update_point_position!(position, -2.5, 7.8)
    final_pos = get_current_position(position)
    @test final_pos[1] ≈ -2.5 && final_pos[2] ≈ 7.8
end

@testset "Movement Vector Calculation Tests" begin
    @testset "Single Key Movement" begin
        state = MovementState(2.0)
        
        # Test individual key movements
        add_key!(state, "w")
        movement = calculate_movement_vector(state)
        @test movement == (0.0, 2.0)  # Up with speed 2.0
        
        reset_movement_state!(state)
        add_key!(state, "s")
        movement = calculate_movement_vector(state)
        @test movement == (0.0, -2.0)  # Down with speed 2.0
        
        reset_movement_state!(state)
        add_key!(state, "a")
        movement = calculate_movement_vector(state)
        @test movement == (-2.0, 0.0)  # Left with speed 2.0
        
        reset_movement_state!(state)
        add_key!(state, "d")
        movement = calculate_movement_vector(state)
        @test movement == (2.0, 0.0)  # Right with speed 2.0
    end
    
    @testset "Diagonal Movement" begin
        state = MovementState(2.0)
        
        # Test diagonal movement (normalized)
        add_key!(state, "w")
        add_key!(state, "d")
        movement = calculate_movement_vector(state)
        expected_component = 2.0 / sqrt(2.0)  # Normalized diagonal
        @test movement[1] ≈ expected_component atol=1e-10
        @test movement[2] ≈ expected_component atol=1e-10
        
        reset_movement_state!(state)
        add_key!(state, "s")
        add_key!(state, "a")
        movement = calculate_movement_vector(state)
        @test movement[1] ≈ -expected_component atol=1e-10
        @test movement[2] ≈ -expected_component atol=1e-10
    end
    
    @testset "Opposite Key Cancellation" begin
        state = MovementState(1.0)
        
        # Test that opposite keys cancel out
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
    
    @testset "No Keys Pressed" begin
        state = MovementState(1.0)
        movement = calculate_movement_vector(state)
        @test movement == (0.0, 0.0)
    end
end

@testset "Position Update Logic Tests" begin
    @testset "Apply Movement Vector" begin
        position = create_point_position()
        
        # Test applying movement vector
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
    end
    
    @testset "Update Position from Movement State" begin
        state = MovementState(1.0)
        position = create_point_position()
        
        # Test no movement when no keys pressed
        update_position_from_state!(position, state)
        pos = get_current_position(position)
        @test pos == (0.0, 0.0)
        
        # Test movement with single key
        add_key!(state, "w")
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
    end
end

@testset "Integration Tests" begin
    @testset "Movement State with Key Mappings" begin
        state = MovementState(2.0)
        
        # Test that all valid keys can be added
        for key in keys(KEY_MAPPINGS)
            add_key!(state, key)
            @test key in state.keys_pressed
        end
        
        # Test that movement state reflects multiple keys
        @test length(state.keys_pressed) == 4
        @test state.is_moving == true
        
        # Clear all keys
        for key in keys(KEY_MAPPINGS)
            remove_key!(state, key)
        end
        @test isempty(state.keys_pressed)
        @test state.is_moving == false
    end
    
    @testset "Complete Movement Flow" begin
        state = MovementState(1.5)
        position = create_point_position()
        
        # Test complete flow: key press -> movement calculation -> position update
        add_key!(state, "w")
        @test state.is_moving == true
        
        # Calculate and apply movement
        movement = calculate_movement_vector(state)
        @test movement == (0.0, 1.5)
        
        apply_movement_to_position!(position, movement)
        pos = get_current_position(position)
        @test pos == (0.0, 1.5)
        
        # Test using the integrated function
        add_key!(state, "d")
        update_position_from_state!(position, state)
        pos = get_current_position(position)
        expected_component = 1.5 / sqrt(2.0)
        @test pos[1] ≈ expected_component atol=1e-6
        @test pos[2] ≈ 1.5 + expected_component atol=1e-6
    end
    
    @testset "Movement Speed Variations" begin
        # Test different movement speeds
        for speed in [0.5, 1.0, 2.0, 5.0]
            state = MovementState(speed)
            position = create_point_position()
            
            add_key!(state, "w")
            update_position_from_state!(position, state)
            pos = get_current_position(position)
            @test pos == (0.0, speed)
        end
    end
end