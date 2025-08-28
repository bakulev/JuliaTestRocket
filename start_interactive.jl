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

@info "Interactive session ready. Type '?' for help."
