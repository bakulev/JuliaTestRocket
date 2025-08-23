# IDE Setup Guide for Point Controller

This guide explains how to properly run, test, and develop the Julia Point Controller project in VS Code-like IDEs (including Kiro IDE).

## Table of Contents

- [Prerequisites](#prerequisites)
- [IDE Configuration](#ide-configuration)
- [Running the Application](#running-the-application)
- [Testing](#testing)
- [Debugging](#debugging)
- [Troubleshooting](#troubleshooting)
- [IDE-Specific Notes](#ide-specific-notes)

## Prerequisites

### Required Software
- **Julia 1.6+** - [Download from julialang.org](https://julialang.org/downloads/)
- **VS Code or Kiro IDE** - Modern code editor with extension support
- **Git** - For version control (optional but recommended)

### Verify Installation
```bash
julia --version  # Should show Julia 1.6 or higher
```

## IDE Configuration

### 1. Extension Setup

#### For VS Code:
Install the **Julia Language Support** extension:
- Extension ID: `julialang.language-julia`
- Publisher: Julia Language
- Provides: Syntax highlighting, REPL, debugging, test discovery

#### For Kiro IDE:
- Julia extension may not be available in Kiro's marketplace
- Use alternative methods described below if Testing panel shows "No tests found"

### 2. Project Files Overview

The project includes several IDE configuration files:

```
.vscode/
├── extensions.json    # Recommended extensions
├── launch.json       # Run and Debug configurations
├── settings.json     # Julia-specific IDE settings
└── tasks.json        # Build and test tasks
```

## Running the Application

### Method 1: Run and Debug Panel (Recommended)

1. **Open Run and Debug panel** (`Ctrl+Shift+D` or `Cmd+Shift+D`)
2. **Select configuration** from dropdown:
   - **"Run Point Controller (Interactive)"** - Full setup with dependency installation
   - **"Run Point Controller"** - Direct module execution
3. **Click the play button** or press `F5`

### Method 2: Terminal Commands

```bash
# Option A: Use the runner script (recommended)
julia run_app.jl

# Option B: Manual setup
julia --project=. -e "using Pkg; Pkg.activate(\".\"); Pkg.instantiate(); using PointController; run_point_controller()"

# Option C: Julia REPL
julia --project=.
# Then in Julia REPL:
# using PointController
# run_point_controller()
```

### Method 3: Command Palette

1. **Open Command Palette** (`Ctrl+Shift+P` or `Cmd+Shift+P`)
2. **Search for**: "Tasks: Run Task"
3. **Select**: "Julia: Run Point Controller"

## Testing

### Testing Panel Limitations

**Important**: The Testing panel in Kiro IDE may not discover Julia tests automatically because:
- Julia support varies between IDEs
- Native test discovery requires Julia Language extension
- Some IDEs only support mainstream testing frameworks (Jest, pytest, etc.)

### Alternative Testing Methods

#### Method 1: Run and Debug Panel
1. **Open Run and Debug panel**
2. **Select**: "Run Tests" configuration
3. **Click play button**

#### Method 2: Terminal Testing
```bash
# Option A: Use test runner script
julia test_runner.jl

# Option B: Standard Julia testing
julia --project=. -e "using Pkg; Pkg.test()"

# Option C: Run specific test file
julia --project=. test/basic_test.jl
```

#### Method 3: Tasks Panel
1. **Command Palette** → "Tasks: Run Task"
2. **Select**: "Julia: Run Tests"

### Test Files Structure
```
test/
├── runtests.jl        # Main test runner
├── test_movement.jl   # Movement state tests
├── test_input.jl      # Input handler tests
├── basic_test.jl      # Simple Julia tests
└── Project.toml       # Test dependencies
```

## Debugging

### Breakpoints and Debugging
1. **Set breakpoints** by clicking in the gutter next to line numbers
2. **Start debugging** with `F5` or Run and Debug panel
3. **Use debug configurations**:
   - "Run Point Controller" - Debug the main application
   - "Run Tests" - Debug test execution

### Debug Console
- **Variables panel** - Inspect current variable values
- **Call stack** - See function call hierarchy
- **Debug console** - Execute Julia commands in debug context

## Troubleshooting

### Common Issues and Solutions

#### 1. "No tests have been found in this workspace yet"
**Cause**: IDE doesn't recognize Julia test framework
**Solutions**:
- Use Run and Debug panel instead of Testing panel
- Install Julia extension if available
- Use terminal commands: `julia test_runner.jl`

#### 2. "Missing reference: Pkg"
**Cause**: Julia standard library not properly imported
**Solution**: Use `import Pkg` instead of `using Pkg` in scripts

#### 3. GLMakie Installation Issues
**Cause**: Graphics dependencies or OpenGL compatibility
**Solutions**:
```bash
# Reinstall GLMakie
julia --project=. -e "using Pkg; Pkg.rm(\"GLMakie\"); Pkg.add(\"GLMakie\")"

# Check OpenGL support
julia --project=. -e "using GLMakie; GLMakie.activate!()"
```

#### 4. Project Not Activating
**Cause**: Julia not recognizing project environment
**Solution**:
```bash
# Force project activation
julia --project=. -e "using Pkg; Pkg.activate(\".\"); Pkg.instantiate()"
```

#### 5. Extension Not Working
**Cause**: IDE doesn't support Julia extension
**Solutions**:
- Use Run and Debug configurations instead
- Rely on terminal-based development
- Consider using VS Code if Julia support is critical

### Performance Tips

1. **Precompile packages** for faster startup:
   ```julia
   using Pkg; Pkg.precompile()
   ```

2. **Use Julia REPL** for interactive development:
   ```bash
   julia --project=.
   ```

3. **Enable render_on_demand** in GLMakie for better performance

## IDE-Specific Notes

### Kiro IDE
- **Testing Panel**: May not support Julia natively
- **Workaround**: Use Run and Debug panel or terminal
- **Extensions**: Limited Julia ecosystem compared to VS Code
- **Recommendation**: Focus on Run and Debug configurations

### VS Code
- **Full Julia Support**: With Julia Language extension
- **Testing Panel**: Should work with proper extension
- **IntelliSense**: Full autocomplete and syntax checking
- **Integrated REPL**: Built-in Julia REPL support

### Generic VS Code-like IDEs
- **Varies by IDE**: Julia support depends on specific IDE
- **Fallback**: Always use terminal commands if IDE features don't work
- **Configuration**: The .vscode/ folder should work in most VS Code-compatible editors

## Quick Reference

### Essential Commands
```bash
# Setup project
julia --project=. -e "using Pkg; Pkg.instantiate()"

# Run application
julia run_app.jl

# Run tests
julia test_runner.jl

# Start Julia REPL with project
julia --project=.
```

### Key Files
- `run_app.jl` - Application launcher
- `test_runner.jl` - Test launcher  
- `.vscode/launch.json` - Run and Debug configurations
- `Project.toml` - Julia package configuration

### Keyboard Shortcuts
- `F5` - Start debugging/running
- `Ctrl+Shift+D` - Open Run and Debug panel
- `Ctrl+Shift+P` - Command Palette
- `Ctrl+`` ` - Open integrated terminal

## Getting Help

If you encounter issues:

1. **Check this guide** for common solutions
2. **Use terminal commands** as fallback
3. **Verify Julia installation**: `julia --version`
4. **Check project activation**: Files should load without errors
5. **Try VS Code** if your IDE has limited Julia support

The project is designed to work with minimal IDE dependencies - when in doubt, use the terminal!