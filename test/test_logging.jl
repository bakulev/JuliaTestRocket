# Logging Tests
# Tests for logging configuration and utilities

using Test
using Logging

@testset "Logging Configuration Tests" begin
    @testset "PointController.setup_logging" begin
        # Test default setup
        @test PointController.setup_logging() == true

        # Test with different log levels
        @test PointController.setup_logging(Logging.Debug) == true
        @test PointController.setup_logging(Logging.Info) == true
        @test PointController.setup_logging(Logging.Warn) == true
        @test PointController.setup_logging(Logging.Error) == true

        # Test with show_timestamp parameter
        @test PointController.setup_logging(Logging.Info, show_timestamp = true) == true
        @test PointController.setup_logging(Logging.Info, show_timestamp = false) == true
    end

    @testset "PointController.get_current_log_level" begin
        # Test that we can get the current log level
        level = PointController.get_current_log_level()
        @test isa(level, LogLevel)

        # Test that it returns a valid log level
        @test level in [Logging.Debug, Logging.Info, Logging.Warn, Logging.Error]
    end

    @testset "Application Logging Functions" begin
        # Test application start/stop logging
        @test PointController.log_application_start() === nothing
        @test PointController.log_application_stop() === nothing

        # Test GLMakie activation logging
        @test PointController.log_glmakie_activation() === nothing
    end

    @testset "Component Initialization Logging" begin
        # Test component initialization logging
        @test PointController.log_component_initialization("test_component") === nothing
        @test PointController.log_component_initialization("") === nothing
    end

    @testset "User Action Logging" begin
        # Test user action logging with details
        @test PointController.log_user_action("test_action", "test_details") === nothing

        # Test user action logging without details
        @test PointController.log_user_action("test_action") === nothing
        @test PointController.log_user_action("test_action", "") === nothing
    end

    @testset "Error Context Logging" begin
        # Test error logging with context
        @test PointController.log_error_with_context("test error", "test_context") === nothing

        # Test error logging without context
        @test PointController.log_error_with_context("test error") === nothing
        @test PointController.log_error_with_context("test error", "") === nothing

        # Test error logging with exception
        test_exception = ErrorException("test exception")
        @test PointController.log_error_with_context("test error", "test_context", test_exception) ===
              nothing
        @test PointController.log_error_with_context("test error", "", test_exception) === nothing
        @test PointController.log_error_with_context("test error", "", nothing) === nothing
    end

    @testset "Warning Context Logging" begin
        # Test warning logging with context
        @test PointController.log_warning_with_context("test warning", "test_context") === nothing

        # Test warning logging without context
        @test PointController.log_warning_with_context("test warning") === nothing
        @test PointController.log_warning_with_context("test warning", "") === nothing
    end

    @testset "Logging Edge Cases" begin
        # Test with empty strings
        @test PointController.log_user_action("", "") === nothing
        @test PointController.log_error_with_context("", "") === nothing
        @test PointController.log_warning_with_context("", "") === nothing

        # Test with special characters
        @test PointController.log_user_action("test with spaces", "details with spaces") === nothing
        @test PointController.log_error_with_context("error with spaces", "context with spaces") === nothing
    end
end
