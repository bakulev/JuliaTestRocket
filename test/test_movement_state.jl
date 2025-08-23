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
    
    @testset "Point Position with Movement State" begin
        state = MovementState(1.5)
        position = create_point_position()
        
        # Simulate adding a key and updating position
        add_key!(state, "w")
        @test state.is_moving == true
        
        # Update position based on movement
        current_pos = get_current_position(position)
        movement = KEY_MAPPINGS["w"]
        new_x = current_pos[1] + movement[1] * state.movement_speed
        new_y = current_pos[2] + movement[2] * state.movement_speed
        
        update_point_position!(position, new_x, new_y)
        updated_pos = get_current_position(position)
        
        @test updated_pos == (0.0, 1.5)  # Moved up by speed amount
    end
end