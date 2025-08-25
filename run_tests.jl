#!/usr/bin/env julia

# Test Runner for Point Controller
using Pkg
using Logging

# Set up basic logging for the test runner
global_logger(ConsoleLogger(stderr, Logging.Info))

@info "Activating project environment..."
Pkg.activate(@__DIR__)

@info "Installing dependencies..."
Pkg.instantiate()

@info "Running tests..."
Pkg.test()

@info "Tests completed!"
