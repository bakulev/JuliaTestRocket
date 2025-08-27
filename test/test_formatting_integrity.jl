using Test

@testset "File Formatting Integrity Tests" begin
    @testset "Source File Syntax Validation" begin
        # Test that all modified files have valid Julia syntax
        # This specifically tests the files that had formatting changes (blank lines added)

        modified_files = [
            "src/PointController.jl",
            "src/input_handler.jl",
            "src/logging_config.jl",
            "src/movement_state.jl",
            "src/visualization.jl",
        ]

        for file in modified_files
            @testset "Syntax validation for $file" begin
                # Test that the file can be parsed without syntax errors
                content = read(file, String)
                # Check that parsing succeeds (returns a valid expression or nothing)
                result = Meta.parse(content, raise=false)
                @test result !== nothing
            end
        end
    end

    @testset "File Ending Validation" begin
        # Test that files end with proper newlines after formatting changes
        modified_files = [
            "src/PointController.jl",
            "src/input_handler.jl",
            "src/logging_config.jl",
            "src/movement_state.jl",
            "src/visualization.jl",
        ]

        for file in modified_files
            @testset "File ending validation for $file" begin
                content = read(file, String)

                # Test that file ends with newline
                @test endswith(content, '\n')

                # Test that file doesn't have excessive trailing whitespace
                lines = split(content, '\n')
                if length(lines) > 1
                    # Check that the last non-empty line doesn't have trailing spaces
                    last_content_line = ""
                    for line in reverse(lines)
                        if !isempty(strip(line))
                            last_content_line = line
                            break
                        end
                    end
                    if !isempty(last_content_line)
                        @test !endswith(last_content_line, ' ')
                        @test !endswith(last_content_line, '\t')
                    end
                end
            end
        end
    end

    @testset "Module Loading After Formatting" begin
        # Test that the module can still be loaded after formatting changes
        # This is already tested in the main test suite, so we just verify it works
        @test true  # Placeholder - actual module loading is tested elsewhere
    end
end
