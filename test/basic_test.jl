using Test

@testset "Basic Julia Test" begin
    @test 1 + 1 == 2
    @test "hello" * " world" == "hello world"
    @test length([1, 2, 3]) == 3
end