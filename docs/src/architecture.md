# PointController Architecture

This document describes the core architectural patterns and design principles used in the PointController application, focusing on visualization and input processing systems.

## Table of Contents

1. [Overview](#overview)
2. [Visualization Architecture](#visualization-architecture)
3. [Input Processing Architecture](#input-processing-architecture)
4. [Observable System](#observable-system)
5. [Event Flow](#event-flow)
6. [Performance Considerations](#performance-considerations)
7. [Error Handling](#error-handling)

## Overview

PointController follows a **reactive, event-driven architecture** built on top of Makie's Observable system. The application is designed with clear separation of concerns, robust error handling, and performance optimizations.

### Key Architectural Principles

- **Reactive Programming**: Uses Makie's Observable system for automatic UI updates
- **Event-Driven**: Asynchronous event processing, not polling
- **Separation of Concerns**: Each module handles a specific aspect
- **State-Based**: Movement calculated from current state, not individual events
- **Error Recovery**: Graceful handling of failures at each layer

## Visualization Architecture

### Core Components

The visualization system is built around Makie's Observable pattern with the following components:

#### 1. Observable Position Management

```julia
# Create observable point position
point_position = Observable(Point2f(0, 0))

# Visual elements automatically update when position changes
Main.scatter!(ax, point_position,
    color = :red,
    markersize = 20,
    marker = :circle,
    strokewidth = 0,
)
```

#### 2. Reactive Text Display

```julia
# Coordinate text that updates automatically
coordinate_text = Main.lift(point_position) do pos
    x_rounded = round(pos[1], digits = 2)
    y_rounded = round(pos[2], digits = 2)
    return "Position: ($x_rounded, $y_rounded)"
end

# Time display
time_text = Main.lift(current_time_obs) do time_val
    return "Time: $time_val"
end
```

#### 3. Visual Layout

```julia
# Create figure with optimized configuration
fig = Main.Figure(
    size = (800, 600),
    title = "Point Controller",
    figure_padding = 10,
    fontsize = 12,
)

# Create axis with coordinate system
ax = Main.Axis(fig[1, 1],
    xlabel = "X Coordinate",
    ylabel = "Y Coordinate",
    title = "Interactive Point Control (Use WASD keys)",
    aspect = Main.DataAspect(),
    limits = (-10, 10, -10, 10),
)
```

### How Visualization Updates Work

1. **Position Change**: `point_position[] = new_value`
2. **Observable Trigger**: All connected visual elements are notified
3. **Automatic Re-render**: Makie automatically updates the display
4. **No Manual Refresh**: No explicit display calls needed

### Performance Optimizations

- **Render on Demand**: Only redraws when Observables change
- **Efficient Markers**: Optimized point rendering without overdraw
- **Minimal Grid**: Simplified grid system for better performance
- **Frame Rate Control**: 60 FPS update frequency for smooth animation

## Input Processing Architecture

### 4-Layer Event Processing System

The input processing follows a layered architecture that separates concerns and provides robust error handling.

#### Layer 1: Event Capture (Makie Backend)

```julia
# Makie captures raw keyboard events from the OS
Main.on(Main.events(fig).keyboardbutton) do event
    key_string = string(event.key)
    key_char = first(key_string)
    
    if event.action == Main.Keyboard.press
        handle_key_press(key_char, state)
    elseif event.action == Main.Keyboard.release
        handle_key_release(key_char, state)
    end
end
```

**Responsibilities:**
- Capture raw keyboard events from the operating system
- Convert events to structured format with key and action
- Trigger callback functions for each event

#### Layer 2: Event Processing (Input Handler)

```julia
function handle_key_press(key::Char, state::MovementState)
    # Handle quit key
    if lowercase(key) == 'q'
        request_quit!(state)
        return state
    end

    # Only process WASD keys for movement
    if haskey(KEY_MAPPINGS, key)
        add_key!(state, key)
        log_user_action("Key pressed", string(key))
    else
        # Silently ignore non-movement keys
        @debug "Ignored key: $key"
    end
end
```

**Responsibilities:**
- Validate and filter keyboard input
- Handle special keys (quit, movement keys)
- Update movement state
- Log user actions for debugging
- Gracefully handle invalid inputs

#### Layer 3: State Management (Movement State)

```julia
# Key mappings for movement
const KEY_MAPPINGS = Dict(
    'w' => [0, 1],    # Up
    's' => [0, -1],   # Down
    'a' => [-1, 0],   # Left
    'd' => [1, 0],    # Right
    'W' => [0, 1],    # Up (shift)
    'S' => [0, -1],   # Down (shift)
    'A' => [-1, 0],   # Left (shift)
    'D' => [1, 0],    # Right (shift)
)

function calculate_movement_vector(state::MovementState)
    if isempty(state.pressed_keys)
        return [0.0, 0.0]
    end

    # Calculate total movement vector from all pressed keys
    total_movement = [0.0, 0.0]
    for key in state.pressed_keys
        if haskey(KEY_MAPPINGS, key)
            movement = KEY_MAPPINGS[key]
            total_movement[1] += movement[1]
            total_movement[2] += movement[2]
        end
    end

    # Normalize for consistent speed
    magnitude = sqrt(total_movement[1]^2 + total_movement[2]^2)
    if magnitude > 0
        return [total_movement[1] / magnitude, total_movement[2] / magnitude]
    else
        return [0.0, 0.0]
    end
end
```

**Responsibilities:**
- Maintain set of currently pressed keys
- Map keys to movement vectors
- Calculate combined movement from multiple keys
- Normalize diagonal movement for consistent speed
- Handle movement timing and speed control

#### Layer 4: Application Loop (Main Loop)

```julia
# Main application loop at 60 FPS
while Main.events(fig).window_open[] && !movement_state.should_quit
    current_time = time()
    
    if current_time - last_update_time >= update_interval  # 60 FPS
        # Update time display
        time_obs[] = format_current_time()
        
        # Update timing
        update_movement_timing!(movement_state, current_time)
        
        # Update position based on current key states
        apply_movement_to_position!(point_position, movement_state)
        
        @debug "Main loop update: position = $(point_position[]), keys = $(movement_state.pressed_keys)"
    end
    
    sleep(0.1)  # Small sleep to prevent busy waiting
end
```

**Responsibilities:**
- Run at consistent 60 FPS for smooth movement
- Read current state of pressed keys
- Apply movement calculations to position
- Update Observables to trigger visual changes
- Handle application lifecycle (quit, window close)

## Observable System

### What are Observables?

Observables are reactive variables that automatically trigger updates when their values change. They form the backbone of the reactive visualization system.

### Observable Patterns in PointController

#### 1. Observable Creation

```julia
# Create observable with initial value
point_position = Observable(Point2f(0, 0))
time_obs = Observable(format_current_time())
```

#### 2. Observable Access

```julia
# Reading from Observable
current_pos = point_position[]                    # Get current value
@debug "position = $(point_position[])"           # Access in debug

# Writing to Observable
position[] = Point2f(new_x, new_y)               # Set new value
time_obs[] = format_current_time()               # Update time
```

#### 3. Observable Connection

```julia
# Connect Observable to visual element
Main.scatter!(ax, point_position, ...)           # Point follows Observable

# Create reactive text that updates with Observable
coordinate_text = Main.lift(point_position) do pos
    return "Position: ($(pos[1]), $(pos[2]))"
end
```

### How to Identify Observables

| Pattern | Observable | Regular Variable |
|---------|------------|------------------|
| **Creation** | `obs = Observable(value)` | `var = value` |
| **Reading** | `value = obs[]` | `value = var` |
| **Writing** | `obs[] = new_value` | `var = new_value` |
| **Type** | `Observable{T}` | `T` |
| **Behavior** | Triggers updates when changed | No automatic updates |

## Event Flow

### Complete Input-to-Display Flow

```
User presses 'W' key
        ↓
┌─────────────────────────────────────┐
│ 1. OS → Makie Backend (GLMakie)     │ ← Raw keyboard event capture
│    event.key = :w, action = :press  │
└─────────────────────────────────────┘
        ↓
┌─────────────────────────────────────┐
│ 2. Input Handler                    │ ← Event validation & processing
│    handle_key_press('w', state)     │
│    → add_key!(state, 'w')           │
└─────────────────────────────────────┘
        ↓
┌─────────────────────────────────────┐
│ 3. Movement State                   │ ← State management
│    state.pressed_keys = Set(['w'])  │
│    calculate_movement_vector()      │
│    → [0.0, 1.0] (upward vector)    │
└─────────────────────────────────────┘
        ↓
┌─────────────────────────────────────┐
│ 4. Main Loop (60 FPS)              │ ← Application loop
│    apply_movement_to_position!()    │
│    → point_position[] = new_pos     │
└─────────────────────────────────────┘
        ↓
┌─────────────────────────────────────┐
│ 5. Observable System                │ ← Reactive updates
│    point_position[] triggers        │
│    → scatter plot updates           │
│    → coordinate text updates        │
└─────────────────────────────────────┘
        ↓
┌─────────────────────────────────────┐
│ 6. Display                          │ ← Visual rendering
│    Red point moves upward           │
│    Coordinates show new position    │
└─────────────────────────────────────┘
```

### Key Benefits of This Flow

1. **Asynchronous**: Input processing doesn't block visualization
2. **State-Based**: Movement calculated from current state, not individual events
3. **Reactive**: Display updates automatically when state changes
4. **Efficient**: Only updates when necessary, not every frame
5. **Robust**: Error handling at each layer

## Performance Considerations

### Optimization Strategies

1. **Render on Demand**: Only redraw when Observables change
2. **Efficient State Management**: Use Set for pressed keys (O(1) operations)
3. **Frame Rate Control**: 60 FPS main loop for smooth animation
4. **Minimal Allocations**: Reuse objects where possible
5. **Lazy Updates**: Update timing only when needed

### Memory Management

- **Observable Cleanup**: Makie handles Observable lifecycle
- **State Reset**: Clear pressed keys when window loses focus
- **Error Recovery**: Graceful cleanup on failures

## Error Handling

### Multi-Layer Error Recovery

#### 1. Input Layer Errors

```julia
function handle_key_press(key::Char, state::MovementState)
    try
        # Process key press
        if haskey(KEY_MAPPINGS, key)
            add_key!(state, key)
        end
    catch e
        @warn "Error processing key press" exception=string(e)
        return state  # Return unchanged state
    end
end
```

#### 2. State Management Errors

```julia
function apply_movement_to_position!(position::Observable{Point2f}, state::MovementState)
    try
        # Calculate and apply movement
        position[] = new_position
    catch e
        @error "Error applying movement" exception=string(e)
        # Position remains unchanged
    end
end
```

#### 3. Visualization Errors

```julia
coordinate_text = Main.lift(point_position) do pos
    try
        return "Position: ($(pos[1]), $(pos[2]))"
    catch e
        @warn "Error updating coordinate text" exception=string(e)
        return "Position: (Error, Error)"
    end
end
```

### Error Recovery Strategies

1. **Graceful Degradation**: Continue operation with reduced functionality
2. **State Preservation**: Don't corrupt state on errors
3. **User Feedback**: Log errors for debugging
4. **Automatic Recovery**: Clear stuck states (e.g., keys on focus loss)

## Conclusion

The PointController architecture demonstrates modern reactive programming patterns with:

- **Clear separation of concerns** across multiple layers
- **Reactive visualization** using Makie's Observable system
- **Robust input processing** with comprehensive error handling
- **Performance optimizations** for smooth real-time interaction
- **Maintainable code structure** with well-defined interfaces

This architecture provides a solid foundation for interactive applications that require real-time input processing and responsive visualization.
