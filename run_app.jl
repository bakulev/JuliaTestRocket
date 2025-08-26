#!/usr/bin/env julia

# Point Controller Application Runner
# This script activates the project environment and runs the application

using Pkg: Pkg
using Logging

# Set up basic logging for the runner script
global_logger(ConsoleLogger(stderr, Logging.Info))

# Activate the project environment
@info "Activating Point Controller project..."
Pkg.activate(@__DIR__)

# Install dependencies if needed
@info "Checking dependencies..."
Pkg.instantiate()

# Don't activate any specific backend - let user choose
@info "Point Controller requires a Makie backend to be activated."
@info "Please choose your preferred backend:"
@info "  using GLMakie; GLMakie.activate!()     # for interactive graphics"
@info "  using CairoMakie; CairoMakie.activate!() # for static graphics"
@info "  using WGLMakie; WGLMakie.activate!()    # for web-based graphics"
@info ""
@info "Then run: using PointController; run_point_controller()"

# Load the application module
@info "Loading Point Controller..."
using PointController

@info "Point Controller loaded successfully!"
@info "Activate your preferred Makie backend and run run_point_controller() to start."
