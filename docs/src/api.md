# API Reference

```@meta
CurrentModule = PointController
```

## Main Functions

```@docs
run_point_controller
PointController
```

## Core Functions

```@docs
setup_visualization_window
setup_logging
log_application_start
log_application_stop
log_glmakie_activation
log_component_initialization
log_user_action
log_error_with_context
log_warning_with_context
get_current_log_level
```

## Movement State

```@docs
MovementState
add_key!
remove_key!
calculate_movement_vector
reset_movement_state!
clear_all_keys_safely!
update_movement_timing!
```

## Input Handling

```@docs
KeyState
handle_key_press
handle_key_release
is_movement_key
get_pressed_keys
request_quit!
setup_keyboard_events!
```

## Visualization

```@docs
create_visualization
get_current_position
update_coordinate_display!
create_time_observable
format_current_time
```

## Constants

```@docs
KEY_MAPPINGS
```