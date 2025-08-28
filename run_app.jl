#!/usr/bin/env julia

# Generic launcher for PointController that selects a Makie backend.
# Preference order:
#   1) ENV["JTR_BACKEND"] = GL|Cairo|WGL
#   2) Try GLMakie, fall back to CairoMakie on failure

using Pkg
using Logging

global_logger(ConsoleLogger(stderr, Logging.Info))

@info "Starting Point Controller (auto backend selector)…"

# Activate and instantiate project
Pkg.activate(@__DIR__)
Pkg.instantiate()

# Select and activate backend at top-level (no `using` inside functions)
const _JTR_BACKEND = lowercase(get(ENV, "JTR_BACKEND", ""))
const _JTR_SELECTED = Ref{Symbol}(:unknown)

if _JTR_BACKEND == "gl"
    @info "ENV JTR_BACKEND=GL → activating GLMakie"
    try
        using GLMakie
        GLMakie.activate!()
        _JTR_SELECTED[] = :gl
    catch e
        @warn "GLMakie activation failed, falling back to CairoMakie" exception=(
            e,
            catch_backtrace(),
        )
        using CairoMakie
        CairoMakie.activate!()
        _JTR_SELECTED[] = :cairo
    end
elseif _JTR_BACKEND == "cairo"
    @info "ENV JTR_BACKEND=Cairo → activating CairoMakie"
    using CairoMakie
    CairoMakie.activate!()
    _JTR_SELECTED[] = :cairo
elseif _JTR_BACKEND == "wgl"
    @info "ENV JTR_BACKEND=WGL → activating WGLMakie"
    using WGLMakie
    WGLMakie.activate!()
    _JTR_SELECTED[] = :wgl
else
    # Auto: try GL first, then Cairo
    try
        @info "Auto-selecting backend: trying GLMakie first…"
        using GLMakie
        GLMakie.activate!()
        _JTR_SELECTED[] = :gl
    catch e
        @warn "GLMakie activation failed, falling back to CairoMakie" exception=(
            e,
            catch_backtrace(),
        )
        using CairoMakie
        CairoMakie.activate!()
        _JTR_SELECTED[] = :cairo
    end
end

@info "Backend activated" backend=String(Symbol(_JTR_SELECTED[]))

using PointController

@info "Running Point Controller…"
PointController.run_point_controller()
