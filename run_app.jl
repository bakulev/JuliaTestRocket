#!/usr/bin/env julia

# Point Controller Application Runner
# This script activates the project environment and runs the application

import Pkg

# Activate the project environment
println("Activating Point Controller project...")
Pkg.activate(@__DIR__)

# Install dependencies if needed
println("Checking dependencies...")
Pkg.instantiate()

# Activate GLMakie backend (required for PointController)
println("Activating GLMakie backend...")
using GLMakie
GLMakie.activate!()

# Load and run the application
println("Loading Point Controller...")
using PointController

println("Starting Point Controller application...")
run_point_controller()