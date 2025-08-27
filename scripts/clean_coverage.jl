#!/usr/bin/env julia

"""
Clean up old coverage files.

This script removes all .cov files from the project directory.
It's useful to run periodically to keep the project clean.

Usage:
    julia scripts/clean_coverage.jl
"""

using Base.Filesystem

println("🧹 Cleaning up coverage files...")

# Find all .cov files
cov_files = String[]
for (root, dirs, files) in walkdir(".")
    for file in files
        if endswith(file, ".cov")
            push!(cov_files, joinpath(root, file))
        end
    end
end

if isempty(cov_files)
    println("✅ No coverage files found to clean.")
else
    println("📁 Found $(length(cov_files)) coverage files:")
    for file in cov_files
        println("  - $file")
    end
    
    println("\n🗑️  Removing coverage files...")
    for file in cov_files
        rm(file, force=true)
    end
    
    println("✅ Cleaned up $(length(cov_files)) coverage files.")
end

println("\n💡 Tip: Coverage files are automatically generated during test runs.")
println("   They are ignored by git and can be safely deleted.")
