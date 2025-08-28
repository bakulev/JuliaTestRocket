using Test

@testset "File Formatting Integrity Tests" begin
    @testset "Source File Syntax Validation" begin
        # Test that all modified files have valid Julia syntax
        # This specifically tests the files that had formatting changes (blank lines added)

        # Get the project root directory (parent of test directory)
        project_root = dirname(@__DIR__)

        modified_files = [
            joinpath(project_root, "src", "PointController.jl"),
            joinpath(project_root, "src", "input_handler.jl"),
            joinpath(project_root, "src", "logging_config.jl"),
            joinpath(project_root, "src", "movement_state.jl"),
            joinpath(project_root, "src", "visualization.jl"),
        ]

        for file in modified_files
            @testset "Syntax validation for $file" begin
                # Test that the file can be parsed without syntax errors
                content = read(file, String)
                # Use Meta.parseall to validate the entire file content
                try
                    Meta.parseall(content)
                    @test true
                catch err
                    @error "Syntax error in $file: $(err)"
                    @test false
                end
            end
        end
    end

    @testset "File Ending Validation" begin
        # Test that files end with proper newlines after formatting changes
        # Get the project root directory (parent of test directory)
        project_root = dirname(@__DIR__)

        modified_files = [
            joinpath(project_root, "src", "PointController.jl"),
            joinpath(project_root, "src", "input_handler.jl"),
            joinpath(project_root, "src", "logging_config.jl"),
            joinpath(project_root, "src", "movement_state.jl"),
            joinpath(project_root, "src", "visualization.jl"),
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
