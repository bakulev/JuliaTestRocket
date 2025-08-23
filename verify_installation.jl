#!/usr/bin/env julia

"""
Installation Verification Script for PointController

This script verifies that the PointController package is properly installed
and configured. It checks dependencies, module loading, and basic functionality
without requiring a graphics display.

Usage:
    julia verify_installation.jl
"""

using Pkg

println("=== PointController Installation Verification ===\n")

# Check Julia version
println("1. Checking Julia version...")
julia_version = VERSION
println("   Julia version: $julia_version")
if julia_version >= v"1.6"
    println("   ✓ Julia version is compatible (1.6+ required)")
else
    println("   ✗ Julia version is too old (1.6+ required)")
    exit(1)
end

# Check project activation
println("\n2. Checking project activation...")
try
    Pkg.activate(".")
    println("   ✓ Project activated successfully")
catch e
    println("   ✗ Failed to activate project: $e")
    exit(1)
end

# Check dependencies
println("\n3. Checking dependencies...")
try
    Pkg.instantiate()
    println("   ✓ Dependencies resolved successfully")
catch e
    println("   ✗ Failed to resolve dependencies: $e")
    exit(1)
end

# Check module loading
println("\n4. Checking module loading...")
try
    using PointController
    println("   ✓ PointController module loaded successfully")
catch e
    println("   ✗ Failed to load PointController module: $e")
    exit(1)
end

# Check exported functions
println("\n5. Checking exported functions...")
required_functions = [
    :run_point_controller,
    :MovementState,
    :KEY_MAPPINGS,
    :handle_key_press,
    :handle_key_release,
    :calculate_movement_vector
]

for func in required_functions
    if isdefined(PointController, func)
        println("   ✓ $func is available")
    else
        println("   ✗ $func is missing")
        exit(1)
    end
end

# Test basic functionality (without graphics)
println("\n6. Testing basic functionality...")
try
    # Test MovementState creation
    state = PointController.MovementState(0.1)
    println("   ✓ MovementState creation works")
    
    # Test key handling
    PointController.add_key!(state, "w")
    if "w" in state.keys_pressed
        println("   ✓ Key press handling works")
    else
        println("   ✗ Key press handling failed")
        exit(1)
    end
    
    # Test movement calculation
    vector = PointController.calculate_movement_vector(state)
    if vector == (0.0, 0.1)
        println("   ✓ Movement calculation works")
    else
        println("   ✗ Movement calculation failed: expected (0.0, 0.1), got $vector")
        exit(1)
    end
    
    # Test key removal
    PointController.remove_key!(state, "w")
    if isempty(state.keys_pressed)
        println("   ✓ Key release handling works")
    else
        println("   ✗ Key release handling failed")
        exit(1)
    end
    
catch e
    println("   ✗ Basic functionality test failed: $e")
    exit(1)
end

# Check GLMakie availability (without initializing graphics)
println("\n7. Checking GLMakie availability...")
try
    using GLMakie
    println("   ✓ GLMakie is available")
    println("   ⚠ Note: Graphics functionality requires OpenGL 3.3+ and display system")
    println("   ⚠ Run 'julia run_app.jl' to test full graphics functionality")
catch e
    println("   ✗ GLMakie is not available: $e")
    exit(1)
end

println("\n=== Installation Verification Complete ===")
println("✓ All checks passed!")
println("\nTo run the application:")
println("  julia run_app.jl")
println("\nTo run tests:")
println("  julia --project=. test/runtests.jl")
println("\nFor help:")
println("  See README.md for detailed usage instructions")