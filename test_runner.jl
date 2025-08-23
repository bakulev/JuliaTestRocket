#!/usr/bin/env julia

# Simple Test Runner for Kiro IDE
# This runs tests and displays results in a readable format

import Pkg
using Logging

# Set up basic logging for the test runner
global_logger(ConsoleLogger(stderr, Logging.Info))

@info "🧪 Point Controller Test Runner"
@info "=" ^ 40

# Activate project
@info "📦 Activating project..."
Pkg.activate(@__DIR__)

# Run tests
@info "🚀 Running tests..."
try
    Pkg.test()
    @info "✅ All tests passed!"
catch e
    @error "❌ Tests failed:" exception=string(e)
end

@info "=" ^ 40
@info "✨ Test run complete!"