#!/usr/bin/env julia

# Point Controller with CairoMakie Backend
# This script runs the application with headless graphics (for CI/headless environments)

using Pkg
using Logging

# Set up logging
global_logger(ConsoleLogger(stderr, Logging.Info))

@info "Starting Point Controller with CairoMakie..."

# Activate project
Pkg.activate(@__DIR__)
Pkg.instantiate()

# Load CairoMakie and activate it
@info "Loading CairoMakie backend..."
using CairoMakie
CairoMakie.activate!()

# Load the application module
@info "Loading Point Controller..."
using PointController

@info "Starting Point Controller application (headless mode)..."

# Run the application
run_point_controller()