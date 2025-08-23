#!/usr/bin/env julia

# Simple Test Runner for Kiro IDE
# This runs tests and displays results in a readable format

import Pkg

println("🧪 Point Controller Test Runner")
println("=" ^ 40)

# Activate project
println("📦 Activating project...")
Pkg.activate(@__DIR__)

# Run tests
println("🚀 Running tests...")
try
    Pkg.test()
    println("✅ All tests passed!")
catch e
    println("❌ Tests failed:")
    println(e)
end

println("=" ^ 40)
println("✨ Test run complete!")