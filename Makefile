# Makefile for JuliaTestRocket
# Provides convenient commands for development and release management

# Use a configurable Julia binary to simulate different versions locally.
# Override like:
#   JULIA_BIN=/Applications/Julia-1.10.app/Contents/Resources/julia/bin/julia make ci-local
# Defaults to the `julia` on PATH.
JULIA_BIN ?= julia
# Match CI default threads unless overridden by environment
export JULIA_NUM_THREADS ?= 2

.PHONY: help test test-fast prepush format format-check coverage coverage-clean quality-ci docs-build smoke-glmakie security ci-local version-current version-validate bump-patch bump-minor bump-major prepare-release clean setup release-patch release-minor release-major

# Default target
help:
	@echo "JuliaTestRocket Development Commands"
	@echo "===================================="
	@echo ""
	@echo "Development:"
	@echo "  test              Run full test suite"
	@echo "  test-fast         Run basic tests only"
	@echo "  format            Format code with JuliaFormatter (writes changes)"
	@echo "  format-check      Check formatting without writing (CI-style)"
	@echo "  prepush           Run CI-style checks before pushing (format, Aqua, tests)"
	@echo "  clean             Clean build artifacts"
	@echo "  setup             Set up development environment"
	@echo "  (Tip) Override JULIA_BIN to simulate Julia 1.10/1.11 locally"
	@echo ""
	@echo "Application:"
	@echo "  run-interactive   Start interactive session"
	@echo "  run-glmakie       Run with GLMakie (interactive)"
	@echo "  run-cairomakie    Run with CairoMakie (headless)"
	@echo "  run-app           Run auto-selecting launcher (env JTR_BACKEND=gl|cairo|wgl)"
	@echo ""
	@echo "Coverage:"
	@echo "  coverage          Run tests with coverage and produce lcov.info"
	@echo "  coverage-clean    Remove generated .cov files"
	@echo ""
	@echo "Quality & Docs:"
	@echo "  quality-ci        Run Aqua in CI mode (mirrors workflow)"
	@echo "  docs-build        Build documentation locally (mirrors workflow)"
	@echo ""
	@echo "GL Smoke & Security:"
	@echo "  smoke-glmakie     Run GLMakie smoke test (optional; requires GLMakie & display)"
	@echo "  security          Run Trivy scan if installed (optional)"
	@echo ""
	@echo "All-in-one:"
	@echo "  ci-local          Run local mirror of all green-gating CI jobs (format, quality, tests+coverage, docs)"
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
	$(JULIA_BIN) --project=. -e "using Pkg; Pkg.test()"

test-fast:
	@echo "Running basic tests..."
	$(JULIA_BIN) --project=. test/runtests.jl

# CI-style pre-push checklist target
prepush:
	@echo "Checking formatting (CI-style)..."
	$(JULIA_BIN) scripts/format_ci.jl
	@echo "\nRunning Aqua quality suite in a clean environment (CI-style)..."
	$(JULIA_BIN) scripts/quality_ci.jl
	@echo "\nInstalling dependencies (Pkg.instantiate) to mirror CI..."
	$(JULIA_BIN) --project=. -e 'using Pkg; Pkg.instantiate()'
	@echo "\nRunning full test suite (Pkg.test)..."
	$(JULIA_BIN) --project=. -e 'using Pkg; Pkg.test()'
# Formatting targets
format:
	@echo "Running JuliaFormatter (writes changes)..."
	@$(JULIA_BIN) -e 'using Pkg; Pkg.activate(; temp=true); Pkg.add("JuliaFormatter"); using JuliaFormatter; format(".", verbose=true, overwrite=true)'

format-check:
	@echo "Checking formatting (no changes)..."
	@$(JULIA_BIN) -e 'using Pkg; Pkg.activate(; temp=true); Pkg.add("JuliaFormatter"); using JuliaFormatter; ok = format(".", verbose=true, overwrite=false); if !ok; println("Formatting check failed. Run: make format"); exit(1); end; println("Formatting check ✓")'

# Application targets
run-interactive:
	@echo "Starting interactive session..."
	$(JULIA_BIN) --project=. -i start_interactive.jl

run-glmakie:
	@echo "Running with GLMakie..."
	$(JULIA_BIN) run_glmakie.jl

run-cairomakie:
	@echo "Running with CairoMakie..."
	$(JULIA_BIN) run_cairomakie.jl

run-app:
	@echo "Running auto-selecting launcher... (set JTR_BACKEND=gl|cairo|wgl to force)"
	$(JULIA_BIN) run_app.jl

# Coverage helpers
coverage:
	@echo "Running coverage script..."
	$(JULIA_BIN) scripts/run_coverage.jl

coverage-clean:
	@echo "Cleaning coverage files..."
	$(JULIA_BIN) scripts/clean_coverage.jl

# Quality (CI-style) matches .github/workflows/CI.yml quality job
quality-ci:
	@echo "Running Aqua in CI mode (ambiguities=false, stale_deps=false) with CairoMakie..."
	$(JULIA_BIN) --project=test scripts/quality_ci.jl

# Docs build mirrors Documentation.yml
docs-build:
	@echo "Building documentation..."
	$(JULIA_BIN) --project=docs scripts/docs_build.jl

# GLMakie smoke test (optional)
smoke-glmakie:
	@echo "Running GLMakie smoke test (requires GLMakie and a working GL/display)..."
	$(JULIA_BIN) --project=. -e 'using Pkg; try Pkg.add("GLMakie"); catch; end; using GLMakie; GLMakie.activate!(); include("test/test_glmakie_smoke.jl")'

# Security scan (optional; requires trivy)
security:
	@echo "Running Trivy filesystem scan (if trivy is installed)..."
	@command -v trivy >/dev/null 2>&1 && trivy fs . || echo "trivy not found; install from https://aquasecurity.github.io/trivy/ to run locally."

# One command to mirror all green-gating CI jobs
ci-local: prepush coverage docs-build
	@echo "\n✓ Local CI mirror finished. If all steps above passed, CI should be green."

# Version management targets
version-current:
	@$(JULIA_BIN) scripts/version_management.jl current

version-validate:
	@$(JULIA_BIN) scripts/version_management.jl validate

bump-patch:
	@echo "Bumping patch version..."
	@$(JULIA_BIN) scripts/version_management.jl bump patch

bump-minor:
	@echo "Bumping minor version..."
	@$(JULIA_BIN) scripts/version_management.jl bump minor

bump-major:
	@echo "Bumping major version..."
	@$(JULIA_BIN) scripts/version_management.jl bump major

prepare-release:
	@$(JULIA_BIN) scripts/version_management.jl prepare

# Dependency management
deps-status:
	@echo "Checking dependency status..."
	@$(JULIA_BIN) --project=. -e "using Pkg; Pkg.status()"

deps-outdated:
	@echo "Checking for outdated dependencies..."
	@$(JULIA_BIN) --project=. -e "using Pkg; Pkg.status(outdated=true)"

deps-update:
	@echo "⚠️  Updating all dependencies (use with caution)..."
	@$(JULIA_BIN) --project=. -e "using Pkg; Pkg.update()"

# Cleanup
clean:
	@echo "Cleaning build artifacts..."
	@rm -rf Manifest.toml
	@$(JULIA_BIN) --project=. -e "using Pkg; Pkg.instantiate()"

# Development setup
setup:
	@echo "Setting up development environment..."
	@$(JULIA_BIN) --project=. -e "using Pkg; Pkg.instantiate()"
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