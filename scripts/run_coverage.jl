#!/usr/bin/env julia

"""
Run test coverage analysis locally.

This script runs the test suite with coverage tracking and generates a detailed
coverage report. It's useful for developers to check coverage before committing.

Usage:
    julia scripts/run_coverage.jl
"""

using Pkg

println("🔍 Running test coverage analysis...")

# Ensure we're in the right directory
if !isfile("Project.toml")
    error("Please run this script from the project root directory")
end

# Activate the project
Pkg.activate(".")

# Install dependencies for coverage testing
println("📦 Installing dependencies for coverage testing...")
Pkg.add("CairoMakie")
Pkg.add("CoverageTools")

# Clean previous coverage files
println("🧹 Cleaning previous coverage files...")
run(`find . -name "*.cov" -delete`)

# Run tests with coverage
println("🧪 Running tests with coverage tracking...")
run(`julia --project=. --code-coverage=user -e "
    using CairoMakie
    CairoMakie.activate!()
    include(\"test/runtests.jl\")
"`)

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
    if overall_percentage >= 13.0
        println("✅ Coverage above threshold (13%)")
        return true
    else
        println("❌ Coverage below threshold (13%)")
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
