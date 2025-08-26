#!/usr/bin/env julia

# Interactive Point Controller Startup Script
# This script follows Julia best practices for interactive applications

using Pkg: Pkg
using Logging

# Set up logging
global_logger(ConsoleLogger(stderr, Logging.Info))

@info "Starting Point Controller in interactive mode..."

# Activate project
Pkg.activate(@__DIR__)
Pkg.instantiate()

# Load the application module
using PointController

@info "Point Controller loaded successfully!"

# Check for backends and provide guidance
if !PointController.check_backend_loaded()
    @info "No Makie backend detected."
    @info "For interactive graphics, run:"
    @info "  using GLMakie; GLMakie.activate!()"
    @info "  run_point_controller()"
    @info ""
    @info "For headless operation, run:"
    @info "  using CairoMakie; CairoMakie.activate!()"
    @info "  run_point_controller()"
else
    @info "Makie backend detected: $(PointController.get_backend_name())"
    @info "Ready to start! Run: run_point_controller()"
end

@info "Interactive session ready. Type '?' for help."
