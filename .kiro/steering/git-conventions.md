# Git Conventional Commits

This project follows conventional commit standards for clear, structured commit messages that enable automated tooling and improve project maintainability.

## Commit Message Format

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

## Commit Types

- **feat**: A new feature for the user
- **fix**: A bug fix for the user
- **docs**: Documentation only changes
- **style**: Changes that do not affect the meaning of the code (white-space, formatting, etc)
- **refactor**: A code change that neither fixes a bug nor adds a feature
- **perf**: A code change that improves performance
- **test**: Adding missing tests or correcting existing tests
- **build**: Changes that affect the build system or external dependencies
- **ci**: Changes to CI configuration files and scripts
- **chore**: Other changes that don't modify src or test files

## Breaking Changes

For breaking changes, add `!` after the type and include `BREAKING CHANGE:` in the footer:

```
refactor!: modernize GLMakie backend activation pattern

BREAKING CHANGE: Users must now explicitly activate GLMakie backend before using PointController
```

## Commit Message Best Practices

### Use commit_message.txt for Complex Commits

When creating commits with detailed descriptions, use a temporary file to avoid shell escaping issues:

```bash
# Create commit message file
cat > commit_message.txt << 'EOF'
refactor!: modernize GLMakie backend activation pattern

BREAKING CHANGE: Users must now explicitly activate GLMakie backend before using PointController

- Remove GLMakie.activate!() calls from library functions
- Add comprehensive backend activation documentation
- Export missing functions needed by tests
- Fix MovementState constructor calls in tests
- Update all example code to demonstrate proper activation

Migration: Replace 'using PointController; run_point_controller()' with:
'using GLMakie; GLMakie.activate!(); using PointController; run_point_controller()'

Follows modern Makie.jl patterns where users control backend activation.
All 357 tests passing.
EOF

# Commit using the file
git commit -F commit_message.txt

# Clean up
rm commit_message.txt
```

### Examples for PointController

```bash
# Feature addition
feat: add diagonal movement normalization for consistent speed

# Bug fix
fix: prevent stuck keys when window loses focus

# Documentation
docs: add comprehensive GLMakie backend activation guide

# Refactoring
refactor: extract movement calculation into separate module

# Breaking change
refactor!: change MovementState constructor to use keyword arguments

BREAKING CHANGE: MovementState(speed) is now MovementState(movement_speed = speed)
```

## Scope Guidelines

Use scopes to indicate which part of the codebase is affected:

- **movement**: Changes to movement state management
- **input**: Changes to keyboard input handling  
- **viz**: Changes to visualization/rendering
- **test**: Changes to test suite
- **docs**: Changes to documentation
- **build**: Changes to build/package configuration

Examples:
```bash
feat(movement): add support for variable movement speeds
fix(input): handle edge case with simultaneous key releases
docs(viz): add GLMakie backend activation examples
test(integration): add comprehensive keyboard event tests
```

## Commit Message Body Guidelines

- Use imperative mood ("add feature" not "added feature")
- Explain what and why, not how
- Reference issues and pull requests when relevant
- Include migration instructions for breaking changes
- List major changes as bullet points
- Include test status for significant changes

## Footer Guidelines

- **BREAKING CHANGE**: Describe the breaking change and migration path
- **Closes**: Reference issues that are closed by this commit
- **Refs**: Reference related issues or discussions

Example:
```
feat!: implement new keyboard event system

BREAKING CHANGE: Keyboard event handling now requires GLMakie backend activation

The new system provides better performance and follows modern Makie.jl patterns.
Users must now call GLMakie.activate!() before using PointController functions.

- Improved event processing performance by 40%
- Added support for custom key mappings
- Enhanced error handling for invalid key inputs

Closes #123
Refs #456
```

## Automation Benefits

Following conventional commits enables:
- Automatic changelog generation
- Semantic version bumping
- Release note generation
- Commit categorization in project history
- Integration with CI/CD pipelines