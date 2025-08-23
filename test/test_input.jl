# Tests for input handler functionality

@testset "Key Press Handling" begin
    # Basic test to verify functions exist
    state = PointController.MovementState()
    @test PointController.handle_key_press("w", state) isa Nothing
    @test PointController.handle_key_release("w", state) isa Nothing
end

@testset "Movement Vector Calculation" begin
    # Test that movement vector function exists and returns expected type
    state = PointController.MovementState()
    result = PointController.calculate_movement_vector(state)
    @test result isa Tuple{Float64, Float64}
    @test result == (0.0, 0.0)  # Should be stationary initially
end