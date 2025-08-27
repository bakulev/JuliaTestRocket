"""
Logging configuration for PointController application.

This module provides structured, configurable logging to replace println statements
with proper log levels and formatting.
"""

using Logging
using Dates

"""
    LogLevel

Available log levels for PointController application:
- Debug: Detailed diagnostic information
- Info: General information about application flow
- Warn: Warning conditions that don't prevent operation
- Error: Error conditions that may affect functionality
"""

"""
    setup_logging(level::LogLevel = Logging.Info; show_timestamp::Bool = true)

Configure the global logger for PointController with the specified log level.

# Arguments
- `level::LogLevel`: Minimum log level to display (default: Info)
- `show_timestamp::Bool`: Whether to include timestamps in log messages (default: true)

# Examples
```julia
# Set up info-level logging (default)
setup_logging()

# Set up debug-level logging for development
setup_logging(Logging.Debug)

# Set up warning-level logging for production
setup_logging(Logging.Warn, show_timestamp=false)
```
"""
function setup_logging(level::LogLevel = Logging.Info; show_timestamp::Bool = true)
    try
        # Create console logger with specified level
        # Note: Custom formatters require more complex setup in newer Julia versions
        logger = ConsoleLogger(stderr, level)

        # Set as global logger
        global_logger(logger)

        @info "PointController logging initialized" level=level show_timestamp=show_timestamp

        return true

    catch e
        # Fallback to basic logging if setup fails
        println("WARNING: Failed to set up logging system: $(string(e))")
        println("Falling back to basic console output")
        return false
    end
end

"""
    get_current_log_level()

Get the current global log level.

# Returns
- `LogLevel`: Current minimum log level being displayed
"""
function get_current_log_level()
    try
        logger = global_logger()
        if hasfield(typeof(logger), :min_level)
            return logger.min_level
        else
            return Logging.Info  # Default fallback
        end
    catch
        return Logging.Info  # Default fallback
    end
end

"""
    log_application_start()

Log application startup information.
"""
function log_application_start()
    @info "Point Controller application starting"
    @debug "Julia version: $(VERSION)"
    @debug "Current working directory: $(pwd())"
end

"""
    log_application_stop()

Log application shutdown information.
"""
function log_application_stop()
    @info "Point Controller application stopped"
end

"""
    log_glmakie_activation()

Log GLMakie backend activation status.
"""
function log_glmakie_activation()
    @info "GLMakie backend activation requested"
    @debug "Checking GLMakie backend compatibility"
end

"""
    log_component_initialization(component::String)

Log component initialization.

# Arguments
- `component::String`: Name of the component being initialized
"""
function log_component_initialization(component::String)
    @info "Initializing component" component=component
end

"""
    log_user_action(action::String, details::String = "")

Log user actions like key presses.

# Arguments
- `action::String`: Description of the user action
- `details::String`: Additional details about the action (optional)
"""
function log_user_action(action::String, details::String = "")
    if isempty(details)
        @debug "User action: $action"
    else
        @debug "User action: $action" details=details
    end
end

"""
    log_error_with_context(error_msg::String, context::String = "", exception = nothing)

Log errors with context information.

# Arguments
- `error_msg::String`: Main error message
- `context::String`: Context where the error occurred (optional)
- `exception`: Exception object for additional details (optional)
"""
function log_error_with_context(
    error_msg::String,
    context::String = "",
    exception = nothing,
)
    if !isempty(context) && exception !== nothing
        @error error_msg context=context exception=string(exception)
    elseif !isempty(context)
        @error error_msg context=context
    elseif exception !== nothing
        @error error_msg exception=string(exception)
    else
        @error error_msg
    end
end

"""
    log_warning_with_context(warning_msg::String, context::String = "")

Log warnings with context information.

# Arguments
- `warning_msg::String`: Main warning message
- `context::String`: Context where the warning occurred (optional)
"""
function log_warning_with_context(warning_msg::String, context::String = "")
    if !isempty(context)
        @warn warning_msg context=context
    else
        @warn warning_msg
    end
end

# Export public functions
export setup_logging, get_current_log_level
export log_application_start, log_application_stop, log_glmakie_activation
export log_component_initialization, log_user_action
export log_error_with_context, log_warning_with_context

