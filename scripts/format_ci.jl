#!/usr/bin/env julia

# CI-style formatting check that does not rely on globally installed packages.
# It creates a temporary environment, installs JuliaFormatter, and checks the
# repository formatting without modifying any files.

using Pkg

println("Preparing temporary environment for formatting check…")
Pkg.activate(temp=true)
Pkg.add("JuliaFormatter")

using JuliaFormatter

println("Running JuliaFormatter in check mode (overwrite=false)…")
ok = JuliaFormatter.format(".", verbose=true, overwrite=false)

if ok
    println("Formatting check ✓")
else
    @error "Formatting check failed. Run JuliaFormatter locally to fix." 
    exit(1)
end
