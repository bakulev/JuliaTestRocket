#!/usr/bin/env julia

# Point Controller with GLMakie Backend
# This script runs the application with interactive graphics

using Pkg: Pkg
using Logging

# Set up logging with more detailed output
global_logger(ConsoleLogger(stderr, Logging.Info))

@info "Starting Point Controller with GLMakie..."

# Activate project
Pkg.activate(@__DIR__)
Pkg.instantiate()

# Load GLMakie and activate it with error handling
@info "Loading GLMakie backend..."
try
    # Try to install GLMakie if not available
    if !haskey(Pkg.project().dependencies, "GLMakie")
        @info "GLMakie not in dependencies, adding it for local development..."
        Pkg.add("GLMakie")
    end
    
    using GLMakie
    GLMakie.activate!()
    @info "GLMakie backend activated successfully!"
catch e
    @error "Failed to load GLMakie backend" exception=(e, catch_backtrace())
    @error "Please ensure GLMakie is installed and your graphics drivers are up to date"
    exit(1)
end

# Load the application module
@info "Loading Point Controller..."
try
    using PointController
    @info "Point Controller module loaded successfully!"
catch e
    @error "Failed to load PointController module" exception=(e, catch_backtrace())
    exit(1)
end

# Verify backend is loaded
if PointController.check_backend_loaded()
    @info "GLMakie backend verified and ready!"
    @info "Starting Point Controller application..."
    @info "Use WASD keys to move the point. Press 'q' to quit."

    # Run the application with error handling
    try
        PointController.run_point_controller()
        @info "Application completed successfully!"
    catch e
        if isa(e, InterruptException)
            @info "Application interrupted by user (Ctrl+C)"
        else
            @error "Application encountered an error" exception=(e, catch_backtrace())
            @error "If this is a graphics-related error, try:"
            @error "  - Updating your graphics drivers"
            @error "  - Restarting your system"
            @error "  - Using a different Makie backend (CairoMakie for headless)"
        end
    end
else
    @error "Failed to verify GLMakie backend"
    @error "This may indicate a graphics driver or compatibility issue"
    exit(1)
end
