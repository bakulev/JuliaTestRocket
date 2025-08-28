#!/usr/bin/env julia

#=
Run test coverage analysis locally.

This script runs the test suite with coverage tracking and generates a detailed
coverage report. It's useful for developers to check coverage before committing.

Usage:
    julia scripts/run_coverage.jl
=#

using Pkg

println("🔍 Running test coverage analysis...")

# Ensure we're in the right directory
if !isfile("Project.toml")
    error("Please run this script from the project root directory")
end

# Activate a temporary environment, develop the package into it, and add
# coverage dependencies there to avoid mutating the main Project.toml.
println("📦 Preparing temporary environment for coverage...")
Pkg.activate(; temp = true)
Pkg.develop(path = ".")
Pkg.add("CairoMakie")
Pkg.add("CoverageTools")
Pkg.instantiate()

# Clean previous coverage files
println("🧹 Cleaning previous coverage files...")
for (root, _, files) in walkdir(".")
    for file in files
        if endswith(file, ".cov")
            rm(joinpath(root, file))
        end
    end
end

# Run tests with coverage in the same temporary environment via Pkg.test
println("🧪 Running tests with coverage tracking...")
const ACTIVE_PROJECT = Base.active_project()  # path to the temp Project.toml
const ACTIVE_ENV_DIR = dirname(ACTIVE_PROJECT) # pass directory to --project

# Use the same Julia executable that is running this script to respect JULIA_BIN/juliaup
let julia_cmd = Base.julia_cmd()
    run(
        `$julia_cmd --project=$(ACTIVE_ENV_DIR) --code-coverage=user -e "using Pkg; Pkg.test(\"PointController\"; coverage=true)"`,
    )
end

# Process coverage
println("📊 Processing coverage data...")
using CoverageTools
coverage = process_folder()

# Function to calculate and display coverage
function display_coverage_report(coverage_data)
    println("\n" * "="^60)
    println("📈 COVERAGE REPORT")
    println("="^60)

    lines_count = 0
    covered_count = 0

    for fc in coverage_data
        covered = sum([x !== nothing && x > 0 ? 1 : 0 for x in fc.coverage])
        total = length(fc.coverage)
        percentage = round(covered/total*100, digits = 2)

        lines_count += total
        covered_count += covered

        # Color coding based on coverage
        if percentage >= 80
            status = "🟢"
        elseif percentage >= 50
            status = "🟡"
        else
            status = "🔴"
        end

        println("$status $(fc.filename): $(covered)/$(total) ($(percentage)%)")
    end

    # Overall coverage
    overall_percentage = round(covered_count/lines_count*100, digits = 2)
    println("\n" * "-"^60)
    println("📊 OVERALL COVERAGE: $(covered_count)/$(lines_count) ($(overall_percentage)%)")

    # Coverage status
    if overall_percentage >= 11.0
        println("✅ Coverage above threshold (11%)")
        return true
    else
        println("❌ Coverage below threshold (11%)")
        return false
    end
end

# Display coverage report
coverage_ok = display_coverage_report(coverage)

# Generate LCOV file for external tools
println("\n💾 Generating lcov.info file...")
LCOV.writefile("lcov.info", coverage)
println("✅ Coverage report saved to lcov.info")

println("\n🎉 Coverage analysis complete!")

# Exit with appropriate code
if !coverage_ok
    exit(1)
end
