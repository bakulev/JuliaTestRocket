#!/usr/bin/env julia

# Test Runner for Point Controller
using Pkg

println("Activating project environment...")
Pkg.activate(@__DIR__)

println("Installing dependencies...")
Pkg.instantiate()

println("Running tests...")
Pkg.test()

println("Tests completed!")