using Test
using Documenter

@testset "Documentation Tests" begin
    @testset "Documentation Configuration" begin
        @testset "makedocs configuration validation" begin
            # Test that docs/make.jl exists and contains expected configuration
            make_file = joinpath("docs", "make.jl")
            @test isfile(make_file)
            
            make_content = read(make_file, String)
            
            # Test that makedocs function is called
            @test occursin("makedocs(", make_content)
            
            # Test that pages array is defined
            @test occursin("pages = [", make_content)
            
            # Test that all expected pages are included in correct order
            expected_pages = [
                "\"Home\" => \"index.md\"",
                "\"Getting Started\" => \"getting-started.md\"", 
                "\"Architecture\" => \"architecture.md\"",
                "\"Refactoring Plan\" => \"refactoring_plan.md\"",
                "\"API Reference\" => \"api.md\"",
                "\"Examples\" => \"examples.md\"",
                "\"Troubleshooting\" => \"troubleshooting.md\""
            ]
            
            for page in expected_pages
                @test occursin(page, make_content)
            end
            
            # Test that refactoring plan is positioned after architecture
            arch_pos = findfirst("\"Architecture\" => \"architecture.md\"", make_content)
            refactor_pos = findfirst("\"Refactoring Plan\" => \"refactoring_plan.md\"", make_content)
            @test arch_pos !== nothing
            @test refactor_pos !== nothing
            @test arch_pos.start < refactor_pos.start
        end
    end
    
    @testset "Documentation Files Existence" begin
        @testset "Required documentation files exist" begin
            docs_src = joinpath("docs", "src")
            
            # Test that all documentation files exist
            required_files = [
                "index.md",
                "getting-started.md", 
                "architecture.md",
                "refactoring_plan.md",
                "api.md",
                "examples.md",
                "troubleshooting.md"
            ]
            
            for file in required_files
                file_path = joinpath(docs_src, file)
                @test isfile(file_path) "Documentation file $file should exist"
            end
        end
    end
    
    @testset "Architecture Documentation Updates" begin
        @testset "Advanced Architecture Patterns section" begin
            arch_file = joinpath("docs", "src", "architecture.md")
            arch_content = read(arch_file, String)
            
            # Test that the new section was added
            @test occursin("## Advanced Architecture Patterns", arch_content)
            
            # Test key subsections exist
            expected_subsections = [
                "### Makie Separation and Portability",
                "#### Proposed Architecture Layers",
                "#### Core State System (Makie-Independent)",
                "#### Visualization Adapter Pattern",
                "### Physical Simulation with Bayesian Extensibility",
                "#### Enhanced State System",
                "#### Physics Integration",
                "#### Bayesian Parameter Learning",
                "### Implementation Strategy",
                "#### Phase 1: Core State Separation",
                "#### Phase 2: Physics Integration",
                "#### Phase 3: Bayesian Extensibility",
                "#### Phase 4: Multi-Platform Support"
            ]
            
            for subsection in expected_subsections
                @test occursin(subsection, arch_content) "Architecture should contain subsection: $subsection"
            end
            
            # Test that code examples are included
            @test occursin("```julia", arch_content)
            @test occursin("module CoreState", arch_content)
            @test occursin("VisualizationAdapter", arch_content)
        end
    end
    
    @testset "Index Page Updates" begin
        @testset "@contents directive includes refactoring plan" begin
            index_file = joinpath("docs", "src", "index.md")
            index_content = read(index_file, String)
            
            # Test that @contents section exists
            @test occursin("```@contents", index_content)
            
            # Test that refactoring_plan.md is included in the pages list
            @test occursin("refactoring_plan.md", index_content)
            
            # Test that pages are in correct order
            expected_order = [
                "getting-started.md",
                "architecture.md", 
                "refactoring_plan.md",
                "api.md",
                "examples.md",
                "troubleshooting.md"
            ]
            
            # Verify the pages appear in the correct order in the @contents section
            pages_line = match(r"Pages = \[(.*?)\]"s, index_content)
            @test pages_line !== nothing "Should find Pages array in @contents"
            
            if pages_line !== nothing
                pages_content = pages_line.captures[1]
                for page in expected_order
                    @test occursin("\"$page\"", pages_content) "Page $page should be in @contents"
                end
                
                # Test that refactoring_plan.md comes after architecture.md
                arch_pos = findfirst("architecture.md", pages_content)
                refactor_pos = findfirst("refactoring_plan.md", pages_content)
                @test arch_pos !== nothing
                @test refactor_pos !== nothing
                @test arch_pos.start < refactor_pos.start "refactoring_plan.md should come after architecture.md"
            end
        end
    end
    
    @testset "Refactoring Plan Documentation" begin
        @testset "Refactoring plan file structure and content" begin
            refactor_file = joinpath("docs", "src", "refactoring_plan.md")
            @test isfile(refactor_file) "refactoring_plan.md should exist"
            
            refactor_content = read(refactor_file, String)
            
            # Test main title and structure
            @test occursin("# Refactoring Plan: From Current to Advanced Architecture", refactor_content)
            
            # Test major sections exist
            expected_sections = [
                "## Current State Analysis",
                "## Phase 1: Core State Separation", 
                "## Phase 2: Physics Integration",
                "## Phase 3: Bayesian Extensibility",
                "## Implementation Timeline",
                "## Benefits of This Refactoring"
            ]
            
            for section in expected_sections
                @test occursin(section, refactor_content) "Should contain section: $section"
            end
            
            # Test that implementation steps are detailed
            @test occursin("### Step 1.1: Create Core State Module", refactor_content)
            @test occursin("### Step 1.2: Create Visualization Adapter Interface", refactor_content)
            @test occursin("### Step 2.1: Enhanced Physics Engine", refactor_content)
            @test occursin("### Step 3.1: Bayesian State System", refactor_content)
            
            # Test that code examples are provided
            @test occursin("```julia", refactor_content)
            @test occursin("module CoreState", refactor_content)
            @test occursin("VisualizationAdapter", refactor_content)
            
            # Test timeline sections
            @test occursin("### Week 1: Core Separation", refactor_content)
            @test occursin("### Week 2: Physics Integration", refactor_content)
            @test occursin("### Week 3: Bayesian Extensibility", refactor_content)
            @test occursin("### Week 4: Multi-Platform Support", refactor_content)
        end
    end
    
    @testset "Documentation Build Validation" begin
        @testset "Documentation can be built without errors" begin
            # Test that make.jl can be executed without syntax errors
            make_file = joinpath("docs", "make.jl")
            
            # Read and parse the make.jl file to check for syntax errors
            make_content = read(make_file, String)
            
            # Test that the file contains valid Julia syntax by trying to parse it
            @test_nowarn Meta.parse(make_content)
            
            # Test that all referenced files in pages exist
            pages_match = match(r"pages = \[(.*?)\]"s, make_content)
            if pages_match !== nothing
                pages_content = pages_match.captures[1]
                
                # Extract all markdown file references
                md_files = collect(eachmatch(r'"([^"]+\.md)"', pages_content))
                
                for file_match in md_files
                    filename = file_match.captures[1]
                    if filename != "index.md"  # index.md is in the root format
                        file_path = joinpath("docs", "src", filename)
                        @test isfile(file_path) "Referenced documentation file should exist: $filename"
                    end
                end
            end
        end
    end
end