# Point Controller Troubleshooting Guide

This guide helps you resolve common issues when running the Point Controller application.

## Quick Fixes

### 1. Fix Warnings (Recommended)
Run the warning fix script to suppress known warnings:
```bash
julia scripts/fix_warnings.jl
```

### 2. Run the Application
```bash
julia run_glmakie.jl
```

## Common Issues and Solutions

### GLFW Error Warning
**Symptoms**: Warning about "GLFW library is not initialized" during cleanup
**Cause**: This is a harmless cleanup warning that occurs when the application closes
**Solution**: This warning can be safely ignored - it doesn't affect functionality

### StableHashTraits Warning
**Symptoms**: Warning about `stable_hash(x; version < 4)` not being supported
**Cause**: Using an older version of StableHashTraits
**Solution**: Run `julia scripts/fix_warnings.jl` to update the dependency

### Graphics Driver Issues
**Symptoms**: Application fails to start or crashes with OpenGL errors
**Solutions**:
1. Update your graphics drivers
2. Restart your system
3. Try using CairoMakie instead: `julia run_cairomakie.jl`

### Missing Dependencies
**Symptoms**: "Package not found" errors
**Solution**: Run `julia -e 'using Pkg; Pkg.instantiate()'` in the project directory

### Permission Issues
**Symptoms**: "Permission denied" errors
**Solution**: Ensure you have write permissions in the project directory

## Alternative Backends

If GLMakie doesn't work, try CairoMakie (headless rendering):
```bash
julia run_cairomakie.jl
```

## Getting Help

1. Check the logs for detailed error messages
2. Ensure your Julia version is 1.10 or higher
3. Try running the test suite: `julia test/runtests.jl`
4. Check the documentation in the `docs/` directory

## System Requirements

- Julia 1.10 or higher
- Graphics drivers that support OpenGL 3.3+ (for GLMakie)
- At least 4GB RAM
- Display server (X11, Wayland, or macOS window server)

## Performance Tips

- Close other graphics-intensive applications
- Use a wired connection if running remotely
- Consider using CairoMakie for headless environments
