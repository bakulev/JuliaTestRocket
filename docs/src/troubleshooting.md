# Troubleshooting

## Common Issues

### GLMakie Backend Issues

**"GLMakie backend not activated"**
```julia
# Solution: Activate GLMakie before using PointController
using GLMakie
GLMakie.activate!()
using PointController
run_point_controller()
```

**"OpenGL initialization failed"**
- Update graphics drivers to latest version
- Verify OpenGL 3.3+ support: `glxinfo | grep "OpenGL version"` (Linux)
- Try software rendering if hardware acceleration unavailable

### Display Issues

**Window doesn't appear**
- Check display system configuration (DISPLAY variable on Linux)
- Verify X11 forwarding if using SSH: `ssh -X username@hostname`
- Ensure window manager is running

**Black or corrupted window**
- Update graphics drivers
- Try different GLMakie backend settings:
  ```julia
  GLMakie.activate!(debugging = true)
  ```

### Input Issues

**Keyboard input not working**
- Click on the window to ensure it has focus
- Check for conflicting key bindings in window manager
- Verify keyboard layout is standard QWERTY

**Keys get "stuck"**
- This is handled automatically when window loses focus
- If it persists, close and restart the application

### Performance Issues

**Slow or laggy movement**
- Close other graphics-intensive applications
- Reduce window size if experiencing lag
- Check system resource usage (CPU, memory, GPU)
- Try disabling vsync:
  ```julia
  GLMakie.activate!(vsync = false)
  ```

**High CPU usage**
- Enable render-on-demand mode:
  ```julia
  GLMakie.activate!(render_on_demand = true)
  ```

## Error Messages

### Graphics Errors

**"Display system not available"**
```
Solution: Ensure X11/Wayland is running or enable X11 forwarding for SSH
```

**"Out of memory error"**
```
Solution: Close other applications and restart Julia session
```

**"OpenGL context creation failed"**
```
Solution: 
1. Update graphics drivers
2. Check OpenGL support: glxinfo | grep "OpenGL"
3. Try software rendering: export LIBGL_ALWAYS_SOFTWARE=1
```

### Julia Package Errors

**"Package not found"**
```julia
# Solution: Ensure you're in the correct project environment
using Pkg
Pkg.activate(".")
Pkg.instantiate()
```

**"Method not found"**
```julia
# Solution: Restart Julia session and reload packages
# Exit Julia and restart, then:
using GLMakie
GLMakie.activate!()
using PointController
```

## Platform-Specific Issues

### Linux

**X11 Issues**
```bash
# Check if X11 is running
echo $DISPLAY

# Start X11 if needed
startx

# For SSH, enable X11 forwarding
ssh -X username@hostname
```

**Wayland Compatibility**
```bash
# Force X11 backend if Wayland causes issues
export GDK_BACKEND=x11
export QT_QPA_PLATFORM=xcb
```

### macOS

**Permission Issues**
- Grant terminal/Julia permission to control computer in System Preferences
- Ensure accessibility permissions are enabled

**Retina Display Issues**
```julia
# Use appropriate scaling
GLMakie.activate!(scalefactor = 2.0)
```

### Windows

**DirectX Issues**
- Update DirectX runtime
- Update graphics drivers
- Try OpenGL mode if DirectX fails

## Debug Mode

Enable debugging for more detailed error information:

```julia
using GLMakie
GLMakie.activate!(debugging = true)
using PointController

# This will provide more verbose error messages
run_point_controller()
```

## Getting Help

If you encounter issues not covered here:

1. **Check existing issues**: [GitHub Issues](https://github.com/bakulev/JuliaTestRocket/issues)
2. **Create a new issue** with:
   - Julia version (`versioninfo()`)
   - Operating system
   - Graphics card/driver information
   - Complete error message
   - Steps to reproduce

3. **Include system information**:
   ```julia
   # Run this and include output in your issue
   using InteractiveUtils
   versioninfo()
   
   # For graphics information (Linux)
   run(`glxinfo | grep "OpenGL"`)
   ```