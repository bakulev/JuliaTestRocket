#!/usr/bin/env julia

# Unified runner that selects GLMakie (if available) or CairoMakie
# Usage:
#   julia --project=. run_app.jl                # auto-select backend
#   BACKEND=cairo julia --project=. run_app.jl  # force CairoMakie
#   BACKEND=gl julia --project=. run_app.jl     # force GLMakie (must be installed)

using Pkg
using Logging

# Activate project
Pkg.activate(@__DIR__)
Pkg.instantiate()

# Set up logging
global_logger(ConsoleLogger(stderr, Logging.Info))

backend = get(ENV, "BACKEND", "auto")

function try_activate_glmakie()
    try
        @info "Loading GLMakie backend..."
        @eval using GLMakie
        @eval GLMakie.activate!()
        return true
    catch e
        @warn "GLMakie not available or failed to activate; falling back to CairoMakie" exception=(e, catch_backtrace())
        return false
    end
end

function activate_cairomakie()
    @info "Loading CairoMakie backend..."
    @eval using CairoMakie
    @eval CairoMakie.activate!()
    return true
end

# Choose backend
if backend == "gl"
    if !try_activate_glmakie()
        @error "Requested GLMakie backend, but it is not available. Install with: using Pkg; Pkg.add(\"GLMakie\")"
        exit(1)
    end
elseif backend == "cairo"
    activate_cairomakie()
else
    if !try_activate_glmakie()
        activate_cairomakie()
    end
end

# Run application
@info "Loading Point Controller..."
using PointController

if PointController.check_backend_loaded()
    @info "Starting Point Controller application..."
    try
        PointController.run_point_controller()
        @info "Application completed successfully!"
    catch e
        if isa(e, InterruptException)
            @info "Application interrupted by user (Ctrl+C)"
        else
            @error "Application encountered an error" exception=(e, catch_backtrace())
            exit(1)
        end
    end
else
    @error "No Makie backend detected. Set BACKEND=gl (with GLMakie installed) or BACKEND=cairo."
    exit(1)
end
