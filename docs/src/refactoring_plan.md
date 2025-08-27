# Refactoring Plan: From Current to Advanced Architecture

This document provides a step-by-step plan to refactor the current PointController into the advanced architecture with Makie separation and Bayesian physics simulation.

## Current State Analysis

### Current Architecture
```
PointController.jl (Main module)
├── movement_state.jl (State management)
├── input_handler.jl (Event processing)
├── visualization.jl (Makie-specific)
└── logging_config.jl (Utilities)
```

### Current Dependencies
- All modules depend on Makie for visualization
- State management mixed with visualization logic
- No separation between core simulation and display

## Phase 1: Core State Separation

### Step 1.1: Create Core State Module

Create `src/core_state.jl`:

```julia
"""
# Core State Module

Core simulation state management without visualization dependencies.
This module provides the foundation for the simulation engine.
"""

module CoreState

using Observables: Observable
using StaticArrays: SVector
using Dates

# Type definitions
const Point2f = SVector{2, Float32}

export SimulationState, StateHistory, PhysicsEngine
export update_state!, calculate_next_state, get_current_state
export create_simulation_state, create_physics_engine

"""
    SimulationState

Core simulation state without visualization dependencies.
"""
mutable struct SimulationState
    position::Observable{Point2f}
    velocity::Observable{Point2f}
    time::Observable{Float64}
    pressed_keys::Observable{Set{Char}}
    mass::Float64
    damping::Float64
    should_quit::Bool
    
    function SimulationState(; 
        initial_position::Point2f = Point2f(0, 0),
        mass::Float64 = 1.0,
        damping::Float64 = 0.1
    )
        return new(
            Observable(initial_position),
            Observable(Point2f(0, 0)),
            Observable(0.0),
            Observable(Set{Char}()),
            mass,
            damping,
            false
        )
    end
end

"""
    StateHistory

History of states for Bayesian inference and physics calculations.
"""
mutable struct StateHistory
    states::Vector{SimulationState}
    timestamps::Vector{Float64}
    max_history::Int
    
    function StateHistory(max_history::Int = 100)
        return new(SimulationState[], Float64[], max_history)
    end
end

"""
    PhysicsEngine

Handles physics calculations and state transitions.
"""
struct PhysicsEngine
    gravity::Point2f
    friction::Float64
    time_step::Float64
    bounds::Tuple{Point2f, Point2f}
    
    function PhysicsEngine(;
        gravity::Point2f = Point2f(0, -9.81),
        friction::Float64 = 0.1,
        time_step::Float64 = 1/60,
        bounds::Tuple{Point2f, Point2f} = (Point2f(-10, -10), Point2f(10, 10))
    )
        return new(gravity, friction, time_step, bounds)
    end
end

# Core state management functions
function add_key!(state::SimulationState, key::Char)
    keys = state.pressed_keys[]
    push!(keys, key)
    state.pressed_keys[] = keys
end

function remove_key!(state::SimulationState, key::Char)
    keys = state.pressed_keys[]
    delete!(keys, key)
    state.pressed_keys[] = keys
end

function clear_keys!(state::SimulationState)
    state.pressed_keys[] = Set{Char}()
end

function request_quit!(state::SimulationState)
    state.should_quit = true
end

# Physics calculations
function calculate_movement_vector(state::SimulationState)
    keys = state.pressed_keys[]
    if isempty(keys)
        return Point2f(0, 0)
    end
    
    # Key mappings (moved from movement_state.jl)
    const KEY_MAPPINGS = Dict(
        'w' => Point2f(0, 1),    # Up
        's' => Point2f(0, -1),   # Down
        'a' => Point2f(-1, 0),   # Left
        'd' => Point2f(1, 0),    # Right
        'W' => Point2f(0, 1),    # Up (shift)
        'S' => Point2f(0, -1),   # Down (shift)
        'A' => Point2f(-1, 0),   # Left (shift)
        'D' => Point2f(1, 0),    # Right (shift)
    )
    
    total_movement = Point2f(0, 0)
    for key in keys
        if haskey(KEY_MAPPINGS, key)
            total_movement += KEY_MAPPINGS[key]
        end
    end
    
    # Normalize for consistent speed
    magnitude = sqrt(total_movement[1]^2 + total_movement[2]^2)
    if magnitude > 0
        return total_movement / magnitude
    else
        return Point2f(0, 0)
    end
end

function apply_physics!(state::SimulationState, engine::PhysicsEngine, dt::Float64)
    # Get current state
    pos = state.position[]
    vel = state.velocity[]
    
    # Calculate input force from pressed keys
    input_direction = calculate_movement_vector(state)
    input_force = input_direction * 5.0  # Input force magnitude
    
    # Calculate physics forces
    gravity_force = state.mass * engine.gravity
    damping_force = -state.damping * vel
    
    # Total force
    total_force = input_force + gravity_force + damping_force
    
    # Update velocity (F = ma)
    acceleration = total_force / state.mass
    new_velocity = vel + acceleration * dt
    
    # Update position
    new_position = pos + new_velocity * dt
    
    # Apply boundary constraints
    min_bounds, max_bounds = engine.bounds
    new_position = Point2f(
        clamp(new_position[1], min_bounds[1], max_bounds[1]),
        clamp(new_position[2], min_bounds[2], max_bounds[2])
    )
    
    # Update state
    state.position[] = new_position
    state.velocity[] = new_velocity
    state.time[] += dt
    
    return state
end

function add_to_history!(history::StateHistory, state::SimulationState)
    # Create a copy of the current state for history
    state_copy = SimulationState(
        position = Observable(state.position[]),
        velocity = Observable(state.velocity[]),
        time = Observable(state.time[]),
        pressed_keys = Observable(copy(state.pressed_keys[])),
        mass = state.mass,
        damping = state.damping
    )
    
    push!(history.states, state_copy)
    push!(history.timestamps, state.time[])
    
    # Maintain history size limit
    if length(history.states) > history.max_history
        popfirst!(history.states)
        popfirst!(history.timestamps)
    end
end

# Factory functions
function create_simulation_state(; kwargs...)
    return SimulationState(; kwargs...)
end

function create_physics_engine(; kwargs...)
    return PhysicsEngine(; kwargs...)
end

function create_state_history(max_history::Int = 100)
    return StateHistory(max_history)
end

end # module CoreState
```

### Step 1.2: Create Visualization Adapter Interface

Create `src/visualization_adapters.jl`:

```julia
"""
# Visualization Adapters

Abstract interface and implementations for different visualization backends.
"""

module VisualizationAdapters

using Observables: Observable
using StaticArrays: SVector

const Point2f = SVector{2, Float32}

export VisualizationAdapter, setup_visualization, update_visualization
export MakieAdapter, create_makie_adapter

"""
    VisualizationAdapter

Abstract type for visualization adapters.
"""
abstract type VisualizationAdapter end

"""
    setup_visualization(adapter::VisualizationAdapter, state)

Setup visualization for the given state.
"""
function setup_visualization(adapter::VisualizationAdapter, state)
    error("setup_visualization not implemented for $(typeof(adapter))")
end

"""
    update_visualization(adapter::VisualizationAdapter, state)

Update visualization with current state.
"""
function update_visualization(adapter::VisualizationAdapter, state)
    error("update_visualization not implemented for $(typeof(adapter))")
end

"""
    close_visualization(adapter::VisualizationAdapter)

Clean up visualization resources.
"""
function close_visualization(adapter::VisualizationAdapter)
    error("close_visualization not implemented for $(typeof(adapter))")
end

# Makie-specific implementation
struct MakieAdapter <: VisualizationAdapter
    fig::Any
    ax::Any
    point_plot::Any
    coordinate_text::Any
    time_text::Any
    is_setup::Bool
end

function create_makie_adapter()
    return MakieAdapter(nothing, nothing, nothing, nothing, nothing, false)
end

function setup_visualization(adapter::MakieAdapter, state)
    if adapter.is_setup
        return adapter
    end
    
    # Create Makie figure and axis
    fig = Main.Figure(
        size = (800, 600),
        title = "Point Controller",
        figure_padding = 10,
        fontsize = 12,
    )
    
    ax = Main.Axis(fig[1, 1],
        xlabel = "X Coordinate",
        ylabel = "Y Coordinate",
        title = "Interactive Point Control (Use WASD keys)",
        aspect = Main.DataAspect(),
        limits = (-10, 10, -10, 10),
    )
    
    # Create point plot
    point_plot = Main.scatter!(ax, state.position,
        color = :red,
        markersize = 20,
        marker = :circle,
        strokewidth = 0,
    )
    
    # Create coordinate text
    coordinate_text = Main.lift(state.position) do pos
        x_rounded = round(pos[1], digits = 2)
        y_rounded = round(pos[2], digits = 2)
        return "Position: ($x_rounded, $y_rounded)"
    end
    
    Main.text!(ax, -9.5, 7.5,
        text = coordinate_text,
        fontsize = 12,
        color = :black,
        align = (:left, :top),
    )
    
    # Create time text
    time_text = Main.lift(state.time) do t
        return "Time: $(round(t, digits = 1))s"
    end
    
    Main.text!(ax, -9.5, 8.5,
        text = time_text,
        fontsize = 12,
        color = :blue,
        align = (:left, :top),
    )
    
    # Add grid
    ax.xgridvisible = true
    ax.ygridvisible = true
    
    # Display figure
    Main.display(fig)
    
    # Update adapter
    adapter.fig = fig
    adapter.ax = ax
    adapter.point_plot = point_plot
    adapter.coordinate_text = coordinate_text
    adapter.time_text = time_text
    adapter.is_setup = true
    
    return adapter
end

function update_visualization(adapter::MakieAdapter, state)
    # Makie updates automatically via Observables
    # No explicit update needed
    return adapter
end

function close_visualization(adapter::MakieAdapter)
    if adapter.is_setup && adapter.fig !== nothing
        # Close Makie window
        try
            Main.close(adapter.fig)
        catch e
            @warn "Error closing Makie window" exception = string(e)
        end
    end
end

end # module VisualizationAdapters
```

### Step 1.3: Create Input Handler Module

Create `src/input_handler_core.jl`:

```julia
"""
# Core Input Handler

Input processing without Makie dependencies.
"""

module InputHandlerCore

using Logging

export handle_key_press, handle_key_release, setup_keyboard_events
export InputEvent, InputHandler

"""
    InputEvent

Represents a keyboard input event.
"""
struct InputEvent
    key::Char
    action::Symbol  # :press or :release
    timestamp::Float64
end

"""
    InputHandler

Handles input events and updates simulation state.
"""
struct InputHandler
    event_queue::Vector{InputEvent}
    is_active::Bool
end

function create_input_handler()
    return InputHandler(InputEvent[], true)
end

function handle_key_press(key::Char, state)
    try
        # Handle quit key
        if lowercase(key) == 'q'
            state.should_quit = true
            return state
        end

        # Only process WASD keys for movement
        const KEY_MAPPINGS = Dict(
            'w' => [0, 1], 's' => [0, -1], 'a' => [-1, 0], 'd' => [1, 0],
            'W' => [0, 1], 'S' => [0, -1], 'A' => [-1, 0], 'D' => [1, 0]
        )
        
        if haskey(KEY_MAPPINGS, key)
            add_key!(state, key)
            @debug "Key pressed: $key" context = "input_handler"
        else
            @debug "Ignored key: $key" context = "input_handler"
        end

        return state
    catch e
        @warn "Error processing key press" exception = string(e)
        return state
    end
end

function handle_key_release(key::Char, state)
    try
        const KEY_MAPPINGS = Dict(
            'w' => [0, 1], 's' => [0, -1], 'a' => [-1, 0], 'd' => [1, 0],
            'W' => [0, 1], 'S' => [0, -1], 'A' => [-1, 0], 'D' => [1, 0]
        )
        
        if haskey(KEY_MAPPINGS, key)
            remove_key!(state, key)
            @debug "Key released: $key" context = "input_handler"
        else
            @debug "Ignored key release: $key" context = "input_handler"
        end

        return state
    catch e
        @warn "Error processing key release" exception = string(e)
        return state
    end
end

# Makie-specific input setup (will be moved to MakieAdapter)
function setup_keyboard_events(fig, state)
    # This function will be implemented in the MakieAdapter
    # It connects Makie events to the core input handler
end

end # module InputHandlerCore
```

### Step 1.4: Refactor Main Module

Update `src/PointController.jl`:

```julia
"""
# PointController.jl

Main module using the new architecture with separated concerns.
"""

module PointController

# Core dependencies
using Logging

# Include core modules
include("core_state.jl")
include("visualization_adapters.jl")
include("input_handler_core.jl")

# Re-export core functionality
export run_point_controller, SimulationState, PhysicsEngine
export create_simulation_state, create_physics_engine

"""
    run_point_controller()

Main entry point using the new architecture.
"""
function run_point_controller()
    # Check backend
    if !check_backend_loaded()
        error("No Makie backend detected. Please activate a backend before using PointController.")
    end

    # Initialize logging
    setup_logging(Logging.Info)
    log_application_start()

    try
        # Create core simulation components
        state = create_simulation_state()
        engine = create_physics_engine()
        history = create_state_history()
        
        # Create and setup visualization
        adapter = create_makie_adapter()
        adapter = setup_visualization(adapter, state)
        
        # Setup input handling
        setup_makie_input_events(adapter.fig, state)
        
        # Main simulation loop
        last_update_time = time()
        update_interval = 1/60  # 60 FPS

        while !state.should_quit
            current_time = time()
            
            if current_time - last_update_time >= update_interval
                # Update physics
                apply_physics!(state, engine, update_interval)
                
                # Add to history
                add_to_history!(history, state)
                
                # Update visualization (automatic via Observables)
                update_visualization(adapter, state)
                
                last_update_time = current_time
            end
            
            sleep(0.001)  # Small sleep to prevent busy waiting
        end
        
        # Cleanup
        close_visualization(adapter)
        log_application_stop()
        
    catch e
        handle_application_error(e)
        rethrow(e)
    end
end

# Helper functions (simplified versions of existing functions)
function check_backend_loaded()
    # Implementation similar to current version
end

function setup_logging(level)
    # Implementation similar to current version
end

function log_application_start()
    @info "PointController started with new architecture"
end

function log_application_stop()
    @info "PointController stopped"
end

function setup_makie_input_events(fig, state)
    # Connect Makie events to core input handler
    Main.on(Main.events(fig).keyboardbutton) do event
        key_string = string(event.key)
        key_char = first(key_string)
        
        if event.action == Main.Keyboard.press
            InputHandlerCore.handle_key_press(key_char, state)
        elseif event.action == Main.Keyboard.release
            InputHandlerCore.handle_key_release(key_char, state)
        end
    end
end

function handle_application_error(e)
    @error "Application error" exception = string(e)
end

end # module PointController
```

## Phase 2: Physics Integration

### Step 2.1: Enhanced Physics Engine

Extend `src/core_state.jl` with more sophisticated physics:

```julia
# Add to CoreState module

"""
    PhysicsModel

Defines the physical laws governing the system.
"""
struct PhysicsModel
    gravity::Point2f
    force_field::Function  # Custom force field
    constraints::Vector{Constraint}
    time_step::Float64
end

"""
    Constraint

Physical constraints (boundaries, etc.)
"""
abstract type Constraint end

struct BoundaryConstraint <: Constraint
    min_bounds::Point2f
    max_bounds::Point2f
end

struct SpringConstraint <: Constraint
    anchor::Point2f
    spring_constant::Float64
    rest_length::Float64
end

# Enhanced physics calculation
function apply_physics!(state::SimulationState, model::PhysicsModel, dt::Float64)
    pos = state.position[]
    vel = state.velocity[]
    
    # Calculate all forces
    gravity_force = state.mass * model.gravity
    damping_force = -state.damping * vel
    custom_force = model.force_field(pos, vel)
    
    # Calculate constraint forces
    constraint_forces = Point2f(0, 0)
    for constraint in model.constraints
        constraint_forces += calculate_constraint_force(constraint, pos, vel)
    end
    
    # Total force
    total_force = gravity_force + damping_force + custom_force + constraint_forces
    
    # Update velocity (F = ma)
    acceleration = total_force / state.mass
    new_velocity = vel + acceleration * dt
    
    # Update position
    new_position = pos + new_velocity * dt
    
    # Apply constraints
    new_position = apply_constraints(new_position, model.constraints)
    
    # Update state
    state.position[] = new_position
    state.velocity[] = new_velocity
    state.time[] += dt
    
    return state
end

function calculate_constraint_force(constraint::BoundaryConstraint, pos, vel)
    # Boundary constraint force
    min_bounds, max_bounds = constraint.min_bounds, constraint.max_bounds
    
    force = Point2f(0, 0)
    
    # X boundary
    if pos[1] < min_bounds[1]
        force += Point2f(10.0 * (min_bounds[1] - pos[1]), 0)
    elseif pos[1] > max_bounds[1]
        force += Point2f(10.0 * (max_bounds[1] - pos[1]), 0)
    end
    
    # Y boundary
    if pos[2] < min_bounds[2]
        force += Point2f(0, 10.0 * (min_bounds[2] - pos[2]))
    elseif pos[2] > max_bounds[2]
        force += Point2f(0, 10.0 * (max_bounds[2] - pos[2]))
    end
    
    return force
end

function calculate_constraint_force(constraint::SpringConstraint, pos, vel)
    # Spring force: F = -k * (x - x0)
    displacement = pos - constraint.anchor
    distance = sqrt(displacement[1]^2 + displacement[2]^2)
    
    if distance > 0
        direction = displacement / distance
        spring_force = -constraint.spring_constant * (distance - constraint.rest_length) * direction
        return spring_force
    else
        return Point2f(0, 0)
    end
end

function apply_constraints(pos::Point2f, constraints::Vector{Constraint})
    new_pos = pos
    
    for constraint in constraints
        if constraint isa BoundaryConstraint
            min_bounds, max_bounds = constraint.min_bounds, constraint.max_bounds
            new_pos = Point2f(
                clamp(new_pos[1], min_bounds[1], max_bounds[1]),
                clamp(new_pos[2], min_bounds[2], max_bounds[2])
            )
        end
    end
    
    return new_pos
end
```

## Phase 3: Bayesian Extensibility

### Step 3.1: Bayesian State System

Create `src/bayesian_state.jl`:

```julia
"""
# Bayesian State System

Bayesian inference for physics parameter estimation.
"""

module BayesianState

using Distributions
using Observables: Observable
using StaticArrays: SVector

const Point2f = SVector{2, Float32}

export BayesianSimulationState, BayesianInferenceEngine
export evaluate_next_state, update_parameter_estimates

"""
    BayesianSimulationState

Extended state system with Bayesian inference capabilities.
"""
mutable struct BayesianSimulationState
    # Core state
    position::Observable{Point2f}
    velocity::Observable{Point2f}
    time::Observable{Float64}
    pressed_keys::Observable{Set{Char}}
    
    # Physics parameters (with uncertainty)
    mass::Observable{Normal{Float64}}
    damping::Observable{Normal{Float64}}
    
    # State history for inference
    history::Vector{Tuple{Point2f, Point2f, Float64}}  # (pos, vel, time)
    max_history::Int
    
    # Bayesian inference engine
    inference_engine::BayesianInferenceEngine
    
    function BayesianSimulationState(;
        initial_position::Point2f = Point2f(0, 0),
        prior_mass::Normal{Float64} = Normal(1.0, 0.5),
        prior_damping::Normal{Float64} = Normal(0.1, 0.05),
        max_history::Int = 100
    )
        return new(
            Observable(initial_position),
            Observable(Point2f(0, 0)),
            Observable(0.0),
            Observable(Set{Char}()),
            Observable(prior_mass),
            Observable(prior_damping),
            Tuple{Point2f, Point2f, Float64}[],
            max_history,
            BayesianInferenceEngine(prior_mass, prior_damping, 0.1, 0.01)
        )
    end
end

"""
    BayesianInferenceEngine

Handles Bayesian parameter estimation and prediction.
"""
struct BayesianInferenceEngine
    prior_mass::Normal{Float64}
    prior_damping::Normal{Float64}
    observation_noise::Float64
    learning_rate::Float64
end

"""
    evaluate_next_state

Evaluates next state using Bayesian inference and physics.
"""
function evaluate_next_state(
    state::BayesianSimulationState,
    dt::Float64,
    input_force::Point2f
)
    # 1. Update Bayesian parameter estimates from history
    updated_mass = update_mass_estimate(state)
    updated_damping = update_damping_estimate(state)
    
    # 2. Predict next state using current physics model
    current_pos = state.position[]
    current_vel = state.velocity[]
    
    # Get current parameter estimates
    mass_mean = mean(updated_mass)
    damping_mean = mean(updated_damping)
    
    # Calculate forces
    gravity = Point2f(0, -9.81)
    gravity_force = mass_mean * gravity
    damping_force = -damping_mean * current_vel
    
    total_force = input_force + gravity_force + damping_force
    
    # Update velocity (F = ma)
    acceleration = total_force / mass_mean
    new_velocity = current_vel + acceleration * dt
    
    # Update position
    new_position = current_pos + new_velocity * dt
    
    # 3. Update state
    state.position[] = new_position
    state.velocity[] = new_velocity
    state.time[] += dt
    state.mass[] = updated_mass
    state.damping[] = updated_damping
    
    # 4. Add to history for future inference
    push!(state.history, (current_pos, current_vel, state.time[]))
    
    # Maintain history size
    if length(state.history) > state.max_history
        popfirst!(state.history)
    end
    
    return state
end

"""
    update_mass_estimate

Update mass estimate using Bayesian inference from state history.
"""
function update_mass_estimate(state::BayesianSimulationState)
    if length(state.history) < 2
        return state.inference_engine.prior_mass
    end
    
    # Extract mass observations from history
    observations = extract_mass_observations(state.history)
    
    if isempty(observations)
        return state.mass[]
    end
    
    # Bayesian update (simplified)
    # In practice, you'd use more sophisticated inference
    current_mass = state.mass[]
    new_mean = mean(observations)
    new_std = std(observations) + state.inference_engine.observation_noise
    
    # Update with learning rate
    alpha = state.inference_engine.learning_rate
    updated_mean = (1 - alpha) * mean(current_mass) + alpha * new_mean
    updated_std = max(std(current_mass), new_std)
    
    return Normal(updated_mean, updated_std)
end

"""
    update_damping_estimate

Update damping estimate using Bayesian inference from state history.
"""
function update_damping_estimate(state::BayesianSimulationState)
    if length(state.history) < 2
        return state.inference_engine.prior_damping
    end
    
    # Extract damping observations from history
    observations = extract_damping_observations(state.history)
    
    if isempty(observations)
        return state.damping[]
    end
    
    # Bayesian update (simplified)
    current_damping = state.damping[]
    new_mean = mean(observations)
    new_std = std(observations) + state.inference_engine.observation_noise
    
    # Update with learning rate
    alpha = state.inference_engine.learning_rate
    updated_mean = (1 - alpha) * mean(current_damping) + alpha * new_mean
    updated_std = max(std(current_damping), new_std)
    
    return Normal(updated_mean, updated_std)
end

"""
    extract_mass_observations

Extract mass-related observations from state history.
"""
function extract_mass_observations(history::Vector{Tuple{Point2f, Point2f, Float64}})
    observations = Float64[]
    
    for i in 2:length(history)
        prev_pos, prev_vel, prev_time = history[i-1]
        curr_pos, curr_vel, curr_time = history[i]
        dt = curr_time - prev_time
        
        if dt > 0
            # Calculate observed acceleration
            velocity_change = curr_vel - prev_vel
            observed_acceleration = velocity_change / dt
            
            # Estimate mass from acceleration (simplified)
            # In practice, you'd need to know the applied force
            if norm(observed_acceleration) > 1e-6
                # Assume some force magnitude for demonstration
                estimated_mass = 1.0 / norm(observed_acceleration)
                push!(observations, estimated_mass)
            end
        end
    end
    
    return observations
end

"""
    extract_damping_observations

Extract damping-related observations from state history.
"""
function extract_damping_observations(history::Vector{Tuple{Point2f, Point2f, Float64}})
    observations = Float64[]
    
    for (pos, vel, time) in history
        if norm(vel) > 1e-6
            # Estimate damping from velocity magnitude
            # This is a simplified approach
            estimated_damping = 0.1 / norm(vel)
            push!(observations, estimated_damping)
        end
    end
    
    return observations
end

end # module BayesianState
```

## Implementation Timeline

### Week 1: Core Separation
- [ ] Create `core_state.jl` module
- [ ] Create `visualization_adapters.jl` module
- [ ] Create `input_handler_core.jl` module
- [ ] Refactor `PointController.jl` to use new architecture
- [ ] Test core functionality without visualization

### Week 2: Physics Integration
- [ ] Enhance physics engine with constraints
- [ ] Add spring forces and boundary conditions
- [ ] Implement state history management
- [ ] Test physics calculations

### Week 3: Bayesian Extensibility
- [ ] Create `bayesian_state.jl` module
- [ ] Implement parameter estimation
- [ ] Add uncertainty quantification
- [ ] Test Bayesian inference

### Week 4: Multi-Platform Support
- [ ] Create Pluto adapter
- [ ] Create Plots adapter
- [ ] Add Jupyter notebook support
- [ ] Comprehensive testing

## Benefits of This Refactoring

1. **Separation of Concerns**: Core simulation logic is independent of visualization
2. **Testability**: Core logic can be tested without graphics dependencies
3. **Portability**: Works with any visualization system
4. **Scientific Rigor**: Proper physics simulation with uncertainty quantification
5. **Educational Value**: Demonstrates Bayesian inference in physical systems
6. **Maintainability**: Clear interfaces and modular design
7. **Extensibility**: Easy to add new features and visualization backends

This refactoring plan provides a clear path to achieve your goals while preserving the reactive architecture benefits and adding sophisticated physics simulation capabilities.
