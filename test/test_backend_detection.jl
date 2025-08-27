# Backend Detection Tests
# Tests for backend detection and initialization functions

using Test
using PointController

@testset "Backend Detection Tests" begin
    @testset "check_backend_loaded" begin
        # Test that check_backend_loaded returns a boolean
        result = check_backend_loaded()
        @test isa(result, Bool)
        
        # Test that it can be called multiple times
        @test_nowarn check_backend_loaded()
        @test_nowarn check_backend_loaded()
    end
    
    @testset "get_backend_name" begin
        # Test that get_backend_name returns expected type
        backend_name = get_backend_name()
        @test isa(backend_name, Union{String, Nothing})
        
        # Test that it can be called multiple times
        @test_nowarn get_backend_name()
        @test_nowarn get_backend_name()
    end
    
    @testset "Backend Detection Consistency" begin
        # Test that backend detection is consistent
        backend_loaded_1 = check_backend_loaded()
        backend_loaded_2 = check_backend_loaded()
        @test backend_loaded_1 == backend_loaded_2
        
        # Test that backend name is consistent
        backend_name_1 = get_backend_name()
        backend_name_2 = get_backend_name()
        @test backend_name_1 == backend_name_2
    end
    
    @testset "Backend Detection Edge Cases" begin
        # Test multiple rapid calls
        for i in 1:10
            @test_nowarn check_backend_loaded()
            @test_nowarn get_backend_name()
        end
    end
end
