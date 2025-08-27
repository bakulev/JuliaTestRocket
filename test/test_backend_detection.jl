# Backend Detection Tests
# Tests for backend detection and initialization functions

using Test

@testset "Backend Detection Tests" begin
    @testset "PointController.check_backend_loaded" begin
        # Test that PointController.check_backend_loaded returns a boolean
        result = PointController.check_backend_loaded()
        @test isa(result, Bool)

        # Test that it can be called multiple times
        @test_nowarn PointController.check_backend_loaded()
        @test_nowarn PointController.check_backend_loaded()
    end

    @testset "PointController.get_backend_name" begin
        # Test that PointController.get_backend_name returns expected type
        backend_name = PointController.get_backend_name()
        @test isa(backend_name, Union{String, Nothing})

        # Test that it can be called multiple times
        @test_nowarn PointController.get_backend_name()
        @test_nowarn PointController.get_backend_name()
    end

    @testset "Backend Detection Consistency" begin
        # Test that backend detection is consistent
        backend_loaded_1 = PointController.check_backend_loaded()
        backend_loaded_2 = PointController.check_backend_loaded()
        @test backend_loaded_1 == backend_loaded_2

        # Test that backend name is consistent
        backend_name_1 = PointController.get_backend_name()
        backend_name_2 = PointController.get_backend_name()
        @test backend_name_1 == backend_name_2
    end

    @testset "Backend Detection Edge Cases" begin
        # Test multiple rapid calls
        for i in 1:10
            @test_nowarn PointController.check_backend_loaded()
            @test_nowarn PointController.get_backend_name()
        end
    end
end
