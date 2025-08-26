# Makefile for JuliaTestRocket
# Provides convenient commands for development and release management

.PHONY: help test test-fast version-current version-validate bump-patch bump-minor bump-major prepare-release clean setup release-patch release-minor release-major

# Default target
help:
	@echo "JuliaTestRocket Development Commands"
	@echo "===================================="
	@echo ""
	@echo "Development:"
	@echo "  test              Run full test suite"
	@echo "  test-fast         Run basic tests only"
	@echo "  clean             Clean build artifacts"
	@echo "  setup             Set up development environment"
	@echo ""
	@echo "Application:"
	@echo "  run-interactive   Start interactive session"
	@echo "  run-glmakie       Run with GLMakie (interactive)"
	@echo "  run-cairomakie    Run with CairoMakie (headless)"
	@echo ""
	@echo "Version Management:"
	@echo "  version-current   Show current version"
	@echo "  version-validate  Validate version and changelog"
	@echo "  bump-patch        Bump patch version (0.0.X)"
	@echo "  bump-minor        Bump minor version (0.X.0)"
	@echo "  bump-major        Bump major version (X.0.0)"
	@echo "  prepare-release   Prepare for release"
	@echo ""
	@echo "Dependencies:"
	@echo "  deps-status       Show dependency status"
	@echo "  deps-outdated     Check for outdated dependencies"
	@echo "  deps-update       Update dependencies (careful!)"
	@echo ""

# Testing targets
test:
	@echo "Running full test suite..."
	julia --project=. -e "using Pkg; Pkg.test()"

test-fast:
	@echo "Running basic tests..."
	julia --project=. test/runtests.jl

# Application targets
run-interactive:
	@echo "Starting interactive session..."
	julia --project=. -i start_interactive.jl

run-glmakie:
	@echo "Running with GLMakie..."
	julia run_glmakie.jl

run-cairomakie:
	@echo "Running with CairoMakie..."
	julia run_cairomakie.jl

# Version management targets
version-current:
	@julia scripts/version_management.jl current

version-validate:
	@julia scripts/version_management.jl validate

bump-patch:
	@echo "Bumping patch version..."
	@julia scripts/version_management.jl bump patch

bump-minor:
	@echo "Bumping minor version..."
	@julia scripts/version_management.jl bump minor

bump-major:
	@echo "Bumping major version..."
	@julia scripts/version_management.jl bump major

prepare-release:
	@julia scripts/version_management.jl prepare

# Dependency management
deps-status:
	@echo "Checking dependency status..."
	@julia --project=. -e "using Pkg; Pkg.status()"

deps-outdated:
	@echo "Checking for outdated dependencies..."
	@julia --project=. -e "using Pkg; Pkg.status(outdated=true)"

deps-update:
	@echo "⚠️  Updating all dependencies (use with caution)..."
	@julia --project=. -e "using Pkg; Pkg.update()"

# Cleanup
clean:
	@echo "Cleaning build artifacts..."
	@rm -rf Manifest.toml
	@julia --project=. -e "using Pkg; Pkg.instantiate()"

# Development setup
setup:
	@echo "Setting up development environment..."
	@julia --project=. -e "using Pkg; Pkg.instantiate()"
	@echo "✓ Development environment ready!"
	@echo ""
	@echo "To start development:"
	@echo "  make run-interactive    # Start interactive session"
	@echo "  make run-glmakie        # Run with GLMakie"
	@echo "  make run-cairomakie     # Run with CairoMakie"
	@echo "  make test               # Run tests"

# Release workflow
release-patch: version-validate test bump-patch
	@echo "Patch release prepared. Review changes and run 'git commit && git tag && git push --tags'"

release-minor: version-validate test bump-minor
	@echo "Minor release prepared. Review changes and run 'git commit && git tag && git push --tags'"

release-major: version-validate test bump-major
	@echo "Major release prepared. Review changes and run 'git commit && git tag && git push --tags'"