# GLMakie Backend Activation Guide

This document explains the modern backend activation patterns used in PointController, following current Makie.jl best practices.

## Overview

PointController follows modern Makie.jl patterns where **users control backend activation**. This means you must explicitly activate GLMakie before using PointController functions.

## Why This Pattern?

### Modern Makie Best Practices
- **User Control**: Users decide which backend to use and when to activate it
- **Flexibility**: Allows switching between backends (GLMakie, CairoMakie, WGLMakie)
- **No Side Effects**: Libraries don't automatically change global state
- **Explicit Dependencies**: Clear separation between backend and application logic

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

## Usage Examples

### Basic Usage
```julia
using GLMakie
GLMakie.activate!()
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

## Backend Configuration Options

GLMakie.activate!() accepts many configuration options:

### Window Settings
- `title::String = "Makie"`: Window title
- `fullscreen = false`: Start in fullscreen mode
- `visible = true`: Window visibility
- `decorated = true`: Show window decorations
- `float = false`: Window floats above others
- `focus_on_show = false`: Focus window when opened

### Rendering Settings
- `vsync = false`: Enable vertical sync
- `framerate = 30.0`: Target frames per second
- `render_on_demand = true`: Only render when needed
- `fxaa = true`: Enable anti-aliasing
- `ssao = true`: Enable ambient occlusion
- `oit = false`: Enable order-independent transparency

### Display Settings
- `scalefactor = automatic`: Window scaling factor
- `px_per_unit = automatic`: Pixel density
- `monitor = nothing`: Target monitor

### Performance Settings
- `pause_renderloop = false`: Start with paused rendering
- `max_lights = 64`: Maximum number of lights
- `transparency_weight_scale = 1000f0`: Transparency rendering scale

## Error Handling

### Backend Not Activated
```julia
# This will fail with helpful error message
using PointController
run_point_controller()  # ERROR: GLMakie backend not activated
```

**Solution:**
```julia
using GLMakie
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

## Alternative Backends

You can use other Makie backends instead of GLMakie:

### CairoMakie (Vector Graphics)
```julia
using CairoMakie
CairoMakie.activate!()
# Note: PointController requires interactive features, so CairoMakie may not work fully
```

### WGLMakie (Web-based)
```julia
using WGLMakie
WGLMakie.activate!()
# Note: PointController keyboard events may not work in web environments
```

## Testing Considerations

### Test Files
Test files should activate GLMakie at the beginning:
```julia
using Test
using GLMakie
GLMakie.activate!()  # Required for tests
using PointController

@testset "PointController Tests" begin
    # ... tests
end
```

### CI/CD Environments
For headless testing environments:
```julia
# Use virtual display
ENV["DISPLAY"] = ":99"
using GLMakie
GLMakie.activate!(visible = false)
```

## Optional Automatic Activation

PointController includes commented-out code for automatic activation:

```julia
# In src/PointController.jl (commented out by default)
function __init__()
    try
        GLMakie.activate!()
        @info "GLMakie backend automatically activated"
    catch e
        @warn "Failed to automatically activate GLMakie: $e"
    end
end
```

**To enable automatic activation:**
1. Uncomment the `__init__()` function in `src/PointController.jl`
2. Restart Julia session
3. PointController will automatically activate GLMakie when loaded

**Note:** This goes against modern Makie patterns and is not recommended for production use.

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
using GLMakie
GLMakie.activate!()
using PointController
run_point_controller()
```

### Batch Update
For multiple scripts, you can create a helper function:
```julia
function setup_pointcontroller()
    using GLMakie
    GLMakie.activate!()
    using PointController
end

# Then in your scripts:
setup_pointcontroller()
run_point_controller()
```

## Troubleshooting

### Common Issues

**"GLMakie backend not activated"**
- Solution: Call `GLMakie.activate!()` before using PointController

**"OpenGL initialization failed"**
- Solution: Update graphics drivers, check OpenGL 3.3+ support

**"Display system not available"**
- Solution: Ensure X11/Wayland is running, enable X11 forwarding for SSH

**Performance issues**
- Solution: Try `GLMakie.activate!(vsync = false, render_on_demand = true)`

### Debug Mode
Enable debugging for more information:
```julia
GLMakie.activate!(debugging = true)
```

## References

- [Makie.jl Documentation](https://docs.makie.org/)
- [GLMakie Backend Guide](https://docs.makie.org/stable/explanations/backends/glmakie/)
- [Backend Configuration Options](https://docs.makie.org/stable/explanations/backends/backends/)