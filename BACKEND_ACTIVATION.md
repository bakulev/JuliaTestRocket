# Makie Backend Activation Guide

This document explains the modern backend activation patterns used in PointController, following current Makie.jl best practices.

## Overview

PointController follows modern Makie.jl patterns where **users control backend activation**. This means you must explicitly activate your preferred Makie backend before using PointController functions.

## Why This Pattern?

### Modern Makie Best Practices
- **User Control**: Users decide which backend to use and when to activate it
- **Flexibility**: Allows switching between backends (GLMakie, CairoMakie, WGLMakie)
- **No Side Effects**: Libraries don't automatically change global state
- **Explicit Dependencies**: Clear separation between backend and application logic
- **CI Compatibility**: Different backends for different environments

### Previous Anti-Pattern
```julia
# OLD WAY (not recommended)
function create_visualization()
    GLMakie.activate!()  # Library controls backend - BAD
    # ... rest of function
end
```

### Modern Pattern
```julia
# NEW WAY (recommended)
# User activates backend first
using GLMakie
GLMakie.activate!()

# Then uses library
using PointController
run_point_controller()
```

## Available Backends

### GLMakie (Interactive Graphics)
```julia
using GLMakie
GLMakie.activate!()
```
- **Best for**: Interactive applications, real-time graphics
- **Features**: Full OpenGL acceleration, interactive windows
- **Requirements**: OpenGL 3.3+, display system

### CairoMakie (Static Graphics)
```julia
using CairoMakie
CairoMakie.activate!()
```
- **Best for**: Publication-quality plots, CI environments
- **Features**: Vector graphics, no display required
- **Requirements**: None (works in headless environments)

### WGLMakie (Web Graphics)
```julia
using WGLMakie
WGLMakie.activate!()
```
- **Best for**: Web applications, browser-based graphics
- **Features**: WebGL-based, runs in browsers
- **Requirements**: WebGL-capable browser

## Usage Examples

### Basic Usage (Interactive)
```julia
using GLMakie
GLMakie.activate!()
using PointController
run_point_controller()
```

### For Publication/Static Graphics
```julia
using CairoMakie
CairoMakie.activate!()
using PointController
run_point_controller()
```

### For Web Applications
```julia
using WGLMakie
WGLMakie.activate!()
using PointController
run_point_controller()
```

### With Custom Configuration
```julia
using GLMakie

# Activate with custom settings
GLMakie.activate!(
    title = "My Point Controller",
    vsync = true,
    framerate = 60.0,
    fxaa = true,
    ssao = true
)

using PointController
run_point_controller()
```

### For HiDPI/Retina Displays
```julia
using GLMakie

# Activate with scaling for high-resolution displays
GLMakie.activate!(
    scalefactor = 2.0,
    px_per_unit = 2.0
)

using PointController
run_point_controller()
```

### For Development/Testing
```julia
using GLMakie

# Activate with debugging enabled
GLMakie.activate!(
    debugging = true,
    visible = true,
    vsync = false  # Disable for faster testing
)

using PointController
run_point_controller()
```

## CI/Testing Environment

For CI environments, PointController automatically uses CairoMakie:

```julia
# In CI (automatic)
using CairoMakie
CairoMakie.activate!()
using PointController
run_point_controller()
```

This approach:
- ✅ **No display setup required** - works in any headless environment
- ✅ **No Xvfb needed** - eliminates all display complexity
- ✅ **Fast and reliable** - perfect for CI testing
- ✅ **Follows best practices** - users can still choose GLMakie locally

## Backend Configuration Options

### GLMakie Configuration
```julia
GLMakie.activate!(
    # Window Settings
    title = "Makie",
    fullscreen = false,
    visible = true,
    decorated = true,
    float = false,
    focus_on_show = false,
    
    # Rendering Settings
    vsync = false,
    framerate = 30.0,
    render_on_demand = true,
    fxaa = true,
    ssao = true,
    oit = false,
    
    # Display Settings
    scalefactor = automatic,
    px_per_unit = automatic,
    monitor = nothing,
    
    # Performance Settings
    pause_renderloop = false,
    max_lights = 64,
    transparency_weight_scale = 1000f0
)
```

### CairoMakie Configuration
```julia
CairoMakie.activate!(
    type = "png",  # or "svg"
    pt_per_unit = 0.75,  # for vector formats
    px_per_unit = 1      # for png
)
```

## Error Handling

### Backend Not Activated
```julia
# This will fail with helpful error message
using PointController
run_point_controller()  # ERROR: No Makie backend activated
```

**Solution:**
```julia
using GLMakie  # or CairoMakie, WGLMakie
GLMakie.activate!()
using PointController
run_point_controller()  # Works correctly
```

### Graphics Issues
If you encounter graphics-related errors:

1. **Update graphics drivers**
2. **Check OpenGL version**: `glxinfo | grep "OpenGL version"` (Linux)
3. **Try software rendering**: `GLMakie.activate!(debugging = true)`
4. **Check display system**: Ensure X11/Wayland is working
5. **Use CairoMakie**: For headless environments or static graphics

## Testing Considerations

### Test Files
Test files should activate an appropriate backend:
```julia
using Test
using CairoMakie  # Use CairoMakie for tests
CairoMakie.activate!()
using PointController

@testset "PointController Tests" begin
    # ... tests
end
```

### CI/CD Environments
For headless testing environments:
```julia
# Use CairoMakie (no display needed)
using CairoMakie
CairoMakie.activate!()
```

## Migration Guide

### From Old Pattern
If you have code using the old pattern:
```julia
# OLD
using PointController
run_point_controller()  # This used to work
```

### To New Pattern
Update to the new pattern:
```julia
# NEW
using GLMakie  # or your preferred backend
GLMakie.activate!()
using PointController
run_point_controller()
```

### Batch Update
For multiple scripts, you can create a helper function:
```julia
function setup_pointcontroller(backend = :glmakie)
    if backend == :glmakie
        using GLMakie
        GLMakie.activate!()
    elseif backend == :cairomakie
        using CairoMakie
        CairoMakie.activate!()
    elseif backend == :wglmakie
        using WGLMakie
        WGLMakie.activate!()
    end
    using PointController
end

# Then in your scripts:
setup_pointcontroller(:glmakie)  # for interactive
setup_pointcontroller(:cairomakie)  # for static
run_point_controller()
```

## Troubleshooting

### Common Issues

**"No Makie backend activated"**
- Solution: Call `GLMakie.activate!()` (or other backend) before using PointController

**"OpenGL initialization failed"**
- Solution: Update graphics drivers, check OpenGL 3.3+ support

**"Display system not available"**
- Solution: Use CairoMakie instead: `using CairoMakie; CairoMakie.activate!()`

**Performance issues**
- Solution: Try `GLMakie.activate!(vsync = false, render_on_demand = true)`

### Debug Mode
Enable debugging for more information:
```julia
GLMakie.activate!(debugging = true)
```

## References

- [Makie.jl Documentation](https://docs.makie.org/)
- [Backends & Output Guide](https://tlienart.github.io/Makie.jl/dev/documentation/backends_and_output/)
- [GLMakie Backend Guide](https://docs.makie.org/stable/explanations/backends/glmakie/)
- [CairoMakie Backend Guide](https://docs.makie.org/stable/explanations/backends/cairomakie/)
- [WGLMakie Backend Guide](https://docs.makie.org/stable/explanations/backends/wglmakie/)