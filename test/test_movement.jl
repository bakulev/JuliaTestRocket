# Tests for movement state management

@testset "MovementState Creation" begin
    # Basic test to verify the module loads
    @test PointController.MovementState(movement_speed = 1.0) isa
          PointController.MovementState
end

@testset "Key Mappings" begin
    # Test that key mappings are defined
    @test haskey(PointController.KEY_MAPPINGS, "w")
    @test haskey(PointController.KEY_MAPPINGS, "a")
    @test haskey(PointController.KEY_MAPPINGS, "s")
    @test haskey(PointController.KEY_MAPPINGS, "d")
end
