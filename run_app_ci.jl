#!/usr/bin/env julia

# Point Controller CI Runner
# This script is specifically for CI environments and uses CairoMakie

using Pkg: Pkg
using Logging

# Set up basic logging for the CI runner script
global_logger(ConsoleLogger(stderr, Logging.Info))

# Activate the project environment
@info "Activating Point Controller project for CI..."
Pkg.activate(@__DIR__)

# Install dependencies if needed
@info "Checking dependencies..."
Pkg.instantiate()

# Use CairoMakie for CI (no display required)
@info "Activating CairoMakie backend for CI environment..."
using CairoMakie
CairoMakie.activate!()

# Load and run the application
@info "Loading Point Controller..."
using PointController

@info "Starting Point Controller application in CI mode..."
run_point_controller()
