# Contributing to JuliaTestRocket

Thank you for your interest in contributing to JuliaTestRocket! 🎉

## Development Setup

### Prerequisites
- Julia 1.10 or higher
- Git
- For interactive development: OpenGL 3.3+ compatible graphics
- For headless development: No graphics hardware required

### Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork**:
   ```bash
   git clone https://github.com/yourusername/JuliaTestRocket.git
   cd JuliaTestRocket
   ```
3. **Set up the development environment**:
   ```bash
   julia --project=. -e "using Pkg; Pkg.instantiate()"
   ```
4. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

## Development Workflow

### Code Style

We use [JuliaFormatter.jl](https://github.com/domluna/JuliaFormatter.jl) for consistent code formatting.

**Before committing, format your code**:
```bash
julia -e "using JuliaFormatter; format(\".\")"
```

**Check formatting** (what CI will do):
```bash
julia -e "using JuliaFormatter; format(\".\", overwrite=false) || exit(1)"
```

### Testing

**Run the full test suite**:
```bash
julia --project=. -e "using Pkg; Pkg.test()"
```

**Run specific test files**:
```bash
julia --project=. test/test_movement_state.jl
```

**Add tests for new functionality**:
- Create test files in the `test/` directory
- Follow existing test patterns
- Ensure good test coverage
- Use appropriate backends for tests (CairoMakie for most tests, GLMakie for smoke tests)

### Pre-push CI checklist

Before pushing a branch or opening a PR, run these commands locally to mirror CI and ensure green checks:

1) Verify formatting (non-destructive check):
```bash
julia -e 'using JuliaFormatter; ok = format(".", verbose=true, overwrite=false); if !ok; exit(1); end; println("Formatting check ✓")'
```

2) Run Aqua quality suite in a clean temp environment (stale deps, compat, piracy, etc.):
```bash
julia -e 'using Pkg; Pkg.activate(; temp=true); Pkg.add("Aqua"); Pkg.develop(path="."); using Aqua, PointController; Aqua.test_all(PointController)'
```

3) Run the full test suite:
```bash
julia --project=. -e 'using Pkg; Pkg.test()'
```

Optional (interactive backend smoke): if you want to quickly exercise GLMakie locally:
```bash
julia run_glmakie.jl
```

Notes:
- CI’s format job runs JuliaFormatter in check mode (no file changes). Step 1 mirrors that.
- Tests are backend-agnostic by default; GLMakie smoke tests are skipped if GLMakie isn’t installed.
- Recommended Julia: 1.10.x (project supports ≥1.10). 1.11 works locally but format behavior should match CI.

### Coverage (optional, to mirror Codecov CI)

Generate a local coverage report and an lcov.info file (used by Codecov):

```bash
# One-shot script (does cleanup, runs tests with coverage, prints summary, writes lcov.info)
julia scripts/run_coverage.jl

# Or via Makefile shortcuts
make coverage         # run coverage
make coverage-clean   # remove .cov files if needed
```

Details:
- The coverage script activates CairoMakie and runs `test/runtests.jl` with `--code-coverage=user`.
- It computes per-file and overall coverage and writes lcov.info at the repo root.
- A minimal threshold (11%) is enforced; adjust in `scripts/run_coverage.jl` if policy changes.

### Documentation

**Build documentation locally**:
```bash
julia --project=docs -e "using Pkg; Pkg.instantiate()"
julia --project=docs docs/make.jl
```

**Add docstrings** for new public functions:
```julia
"""
    my_function(arg1, arg2)

Brief description of what the function does.

# Arguments
- `arg1::Type`: Description of arg1
- `arg2::Type`: Description of arg2

# Returns
- `ReturnType`: Description of return value

# Examples
```julia
result = my_function(1, 2)
```
"""
function my_function(arg1, arg2)
    # implementation
end
```

## Contribution Guidelines

### Commit Messages

We follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

**Types**:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

**Examples**:
```bash
feat(movement): add support for custom movement speeds
fix(input): handle edge case with simultaneous key releases
docs: update installation instructions
test(visualization): add comprehensive CairoMakie tests
```

### Pull Request Process

1. **Ensure all tests pass**:
   ```bash
   julia --project=. -e "using Pkg; Pkg.test()"
   ```

2. **Format your code**:
   ```bash
   jl -e "using JuliaFormatter; format(\".\")"
   ```

3. **Update documentation** if needed

4. **Create a pull request** with:
   - Clear title and description
   - Reference any related issues
   - Include screenshots for UI changes
   - Fill out the PR template

5. **Respond to review feedback** promptly

#### Create a PR from the command line

You can open a Pull Request entirely from the terminal. The recommended path uses the GitHub CLI. A plain Git-only flow is also shown.

Prereqs:
- Fork this repo on GitHub (your fork will be `origin`; this upstream repo is `upstream`).
- Install GitHub CLI: https://cli.github.com/ and run `gh auth login`.

1) Ensure remotes are set (fork clone):
```bash
git remote -v                 # shows origin (your fork)
git remote add upstream https://github.com/bakulev/JuliaTestRocket.git  # once
```

2) Create a branch, commit, and push to your fork:
```bash
git checkout -b feature/your-feature
git add -A
git commit -m "feat: add your feature"
git push -u origin feature/your-feature
```

3) Open the PR:
- Using GitHub CLI (recommended):
```bash
# Create a PR from your fork/branch into upstream main
gh pr create --fill --base bakulev:main --head <your-github-username>:feature/your-feature
```

- Without GitHub CLI (open compare URL):
```bash
# macOS (opens browser)
open "https://github.com/bakulev/JuliaTestRocket/compare/main...<your-github-username>:feature/your-feature?expand=1"
```

Notes:
- Run local checks before opening/marking ready: `make ci-local`.
- Use `--draft` with `gh pr create` to open as a draft.
- For updates, push new commits to the same branch; the PR updates automatically.

### Code Review

All contributions require code review. We look for:

- **Correctness**: Does the code work as intended?
- **Style**: Does it follow our coding standards?
- **Tests**: Are there adequate tests?
- **Documentation**: Is it properly documented?
- **Performance**: Are there any performance concerns?
- **Backend Compatibility**: Does it work with multiple Makie backends?

## Types of Contributions

### Bug Fixes
- Check existing issues first
- Create a minimal reproduction case
- Include tests that verify the fix
- Test with multiple backends if applicable

### New Features
- Discuss in an issue first for large features
- Follow existing code patterns
- Include comprehensive tests
- Update documentation
- Ensure backend-agnostic design

### Documentation
- Fix typos and improve clarity
- Add examples and use cases
- Update API documentation
- Improve installation instructions

### Performance Improvements
- Include benchmarks showing improvement
- Ensure no functionality is broken
- Document any API changes
- Test with multiple backends

## Development Tips

### Backend-Agnostic Development
```julia
# For development, you might want to use a visible backend
using GLMakie
GLMakie.activate!()

# For testing, use CairoMakie
using CairoMakie
CairoMakie.activate!()
```

### Debugging
```julia
# Enable debug logging
using Logging
global_logger(ConsoleLogger(stderr, Logging.Debug))
```

### Testing Graphics Code
```julia
# For headless testing (CI environments)
using CairoMakie
CairoMakie.activate!()

# For interactive testing
using GLMakie
GLMakie.activate!()
```

### Architecture Guidelines

When contributing, keep in mind the backend-agnostic architecture:

1. **Core Logic**: Keep core functionality independent of specific backends
2. **Backend Activation**: Tests/users are responsible for calling `CairoMakie.activate!()` or `GLMakie.activate!()` before using PointController; avoid internal backend detection logic
3. **Dynamic Access**: Access Makie types via `Main.` prefix when needed
4. **Conditional Dependencies**: Keep backend-specific code in `[extras]` section of Project.toml

## Getting Help

- **Questions**: Open a [Discussion](https://github.com/bakulev/JuliaTestRocket/discussions)
- **Bugs**: Create an [Issue](https://github.com/bakulev/JuliaTestRocket/issues)
- **Chat**: Join the Julia community on [Slack](https://julialang.org/slack/) or [Discord](https://discord.gg/julia)

## Recognition

Contributors are recognized in:
- The project's README
- Release notes for significant contributions
- The project's documentation

Thank you for contributing to JuliaTestRocket! 🚀