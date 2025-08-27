# Logging Tests
# Tests for logging configuration and utilities

using Test
using Logging
using PointController

@testset "Logging Configuration Tests" begin
    @testset "setup_logging" begin
        # Test default setup
        @test setup_logging() == true

        # Test with different log levels
        @test setup_logging(Logging.Debug) == true
        @test setup_logging(Logging.Info) == true
        @test setup_logging(Logging.Warn) == true
        @test setup_logging(Logging.Error) == true

        # Test with show_timestamp parameter
        @test setup_logging(Logging.Info, show_timestamp = true) == true
        @test setup_logging(Logging.Info, show_timestamp = false) == true
    end

    @testset "get_current_log_level" begin
        # Test that we can get the current log level
        level = get_current_log_level()
        @test isa(level, LogLevel)

        # Test that it returns a valid log level
        @test level in [Logging.Debug, Logging.Info, Logging.Warn, Logging.Error]
    end

    @testset "Application Logging Functions" begin
        # Test application start/stop logging
        @test log_application_start() === nothing
        @test log_application_stop() === nothing

        # Test GLMakie activation logging
        @test log_glmakie_activation() === nothing
    end

    @testset "Component Initialization Logging" begin
        # Test component initialization logging
        @test log_component_initialization("test_component") === nothing
        @test log_component_initialization("") === nothing
    end

    @testset "User Action Logging" begin
        # Test user action logging with details
        @test log_user_action("test_action", "test_details") === nothing

        # Test user action logging without details
        @test log_user_action("test_action") === nothing
        @test log_user_action("test_action", "") === nothing
    end

    @testset "Error Context Logging" begin
        # Test error logging with context
        @test log_error_with_context("test error", "test_context") === nothing

        # Test error logging without context
        @test log_error_with_context("test error") === nothing
        @test log_error_with_context("test error", "") === nothing

        # Test error logging with exception
        test_exception = ErrorException("test exception")
        @test log_error_with_context("test error", "test_context", test_exception) ===
              nothing
        @test log_error_with_context("test error", "", test_exception) === nothing
        @test log_error_with_context("test error", "", nothing) === nothing
    end

    @testset "Warning Context Logging" begin
        # Test warning logging with context
        @test log_warning_with_context("test warning", "test_context") === nothing

        # Test warning logging without context
        @test log_warning_with_context("test warning") === nothing
        @test log_warning_with_context("test warning", "") === nothing
    end

    @testset "Logging Edge Cases" begin
        # Test with empty strings
        @test log_user_action("", "") === nothing
        @test log_error_with_context("", "") === nothing
        @test log_warning_with_context("", "") === nothing

        # Test with special characters
        @test log_user_action("test with spaces", "details with spaces") === nothing
        @test log_error_with_context("error with spaces", "context with spaces") === nothing
    end
end
