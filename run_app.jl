#!/usr/bin/env julia

# Point Controller Application Runner
# This script activates the project environment and runs the application

import Pkg
using Logging

# Set up basic logging for the runner script
global_logger(ConsoleLogger(stderr, Logging.Info))

# Activate the project environment
@info "Activating Point Controller project..."
Pkg.activate(@__DIR__)

# Install dependencies if needed
@info "Checking dependencies..."
Pkg.instantiate()

# Activate GLMakie backend (required for PointController)
@info "Activating GLMakie backend..."
using GLMakie
GLMakie.activate!()

# Load and run the application
@info "Loading Point Controller..."
using PointController

@info "Starting Point Controller application..."
run_point_controller()