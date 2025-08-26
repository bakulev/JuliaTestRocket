#!/usr/bin/env julia

# Point Controller with GLMakie Backend
# This script runs the application with interactive graphics

using Pkg: Pkg
using Logging

# Set up logging
global_logger(ConsoleLogger(stderr, Logging.Info))

@info "Starting Point Controller with GLMakie..."

# Activate project
Pkg.activate(@__DIR__)
Pkg.instantiate()

# Load GLMakie and activate it
@info "Loading GLMakie backend..."
using GLMakie
GLMakie.activate!()

# Load the application module
@info "Loading Point Controller..."
using PointController

# Verify backend is loaded
if PointController.check_backend_loaded()
    @info "GLMakie backend activated successfully!"
    @info "Starting Point Controller application..."

    # Run the application
    run_point_controller()
else
    @error "Failed to load GLMakie backend"
    exit(1)
end
