#!/usr/bin/env julia

# Script to fix warnings in the Point Controller application
# This script updates dependencies to suppress known warnings

using Pkg: Pkg

println("Fixing warnings in Point Controller...")

# Activate the project
Pkg.activate(@__DIR__)

# Update StableHashTraits to suppress the warning
println("Updating StableHashTraits to fix deprecation warning...")
try
    # Try to add the latest version
    Pkg.add("StableHashTraits")
    println("✓ StableHashTraits updated successfully")
catch e
    println("⚠ Could not update StableHashTraits: $e")
    println("  This warning is harmless and can be ignored")
end

# Update other dependencies that might have warnings
println("Updating other dependencies...")
try
    Pkg.update()
    println("✓ Dependencies updated successfully")
catch e
    println("⚠ Could not update dependencies: $e")
end

println("Warning fixes completed!")
println("You can now run 'julia run_glmakie.jl' with fewer warnings.")
println("Note: The StableHashTraits warning is harmless and doesn't affect functionality.")
