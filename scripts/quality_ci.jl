#!/usr/bin/env julia

# Mirror of .github/workflows/CI.yml quality job
# Runs Aqua test_all with CairoMakie activated, using the test environment

using Pkg

# Ensure we are in repo root (script is expected to be run from repo root)
if !isfile("Project.toml") || !isdir("test")
    @error "Run this script from the repository root"
    exit(1)
end

# Use a temporary environment to mirror CI isolation
Pkg.activate(; temp = true)
Pkg.develop(PackageSpec(path = "."))
Pkg.instantiate()

# Use CairoMakie for headless CI quality checks
try
    Pkg.add("CairoMakie")
catch err
    @warn "Failed to add CairoMakie" err
end

using CairoMakie
CairoMakie.activate!()

# Run Aqua checks
Pkg.add("Aqua")
using Aqua

# Load the package under test
using PointController

# Match CI config: turn off ambiguities and stale_deps in this job
Aqua.test_all(PointController; ambiguities = false, stale_deps = false)

println("\n✓ Quality CI checks completed")
