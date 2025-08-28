#!/usr/bin/env julia
# Local mirror of Documentation.yml job: prepare docs env and build
using Pkg
# Develop the package into the docs environment and instantiate deps
Pkg.develop(PackageSpec(path = pwd()))
Pkg.instantiate()
# Run the docs builder (uses CairoMakie + Documenter as defined in docs/Project.toml)
include(joinpath(pwd(), "docs", "make.jl"))
