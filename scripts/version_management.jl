#!/usr/bin/env julia

"""
Version Management Script for PointController.jl

This script helps manage semantic versioning (SemVer) for the package.
It provides utilities for version bumping, validation, and release preparation.

Usage:
    julia scripts/version_management.jl bump patch|minor|major
    julia scripts/version_management.jl validate
    julia scripts/version_management.jl current
"""

using Pkg
using TOML

const PROJECT_FILE = "Project.toml"
const CHANGELOG_FILE = "CHANGELOG.md"

"""
Parse semantic version string into components.
Returns (major, minor, patch) tuple.
"""
function parse_semver(version_str::String)
    # Remove 'v' prefix if present
    version_str = startswith(version_str, "v") ? version_str[2:end] : version_str

    # Split version components
    parts = split(version_str, ".")
    if length(parts) != 3
        error(
            "Invalid semantic version format: $version_str. Expected format: MAJOR.MINOR.PATCH",
        )
    end

    try
        major = parse(Int, parts[1])
        minor = parse(Int, parts[2])
        patch = parse(Int, parts[3])
        return (major, minor, patch)
    catch
        error(
            "Invalid semantic version format: $version_str. All components must be integers.",
        )
    end
end

"""
Format version components into semantic version string.
"""
function format_semver(major::Int, minor::Int, patch::Int)
    return "$major.$minor.$patch"
end

"""
Get current version from Project.toml.
"""
function get_current_version()
    if !isfile(PROJECT_FILE)
        error("Project.toml not found in current directory")
    end

    project = TOML.parsefile(PROJECT_FILE)
    version = get(project, "version", nothing)

    if version === nothing
        error("No version field found in Project.toml")
    end

    return version
end

"""
Update version in Project.toml.
"""
function update_project_version(new_version::String)
    project = TOML.parsefile(PROJECT_FILE)
    project["version"] = new_version

    open(PROJECT_FILE, "w") do io
        return TOML.print(io, project)
    end

    return println("Updated Project.toml version to $new_version")
end

"""
Validate that current version follows semantic versioning.
"""
function validate_version()
    current = get_current_version()

    try
        parse_semver(current)
        println("✓ Current version ($current) is valid semantic version")
        return true
    catch e
        println("✗ Current version ($current) is invalid: $(e.msg)")
        return false
    end
end

"""
Bump version according to semantic versioning rules.
"""
function bump_version(bump_type::String)
    if !(bump_type in ["patch", "minor", "major"])
        error("Invalid bump type: $bump_type. Must be 'patch', 'minor', or 'major'")
    end

    current = get_current_version()
    (major, minor, patch) = parse_semver(current)

    # Apply version bump
    if bump_type == "patch"
        patch += 1
    elseif bump_type == "minor"
        minor += 1
        patch = 0  # Reset patch version
    elseif bump_type == "major"
        major += 1
        minor = 0  # Reset minor version
        patch = 0  # Reset patch version
    end

    new_version = format_semver(major, minor, patch)

    println("Bumping version from $current to $new_version ($bump_type)")
    update_project_version(new_version)

    return new_version
end

"""
Check if CHANGELOG.md exists and has proper structure.
"""
function validate_changelog()
    if !isfile(CHANGELOG_FILE)
        println("⚠ CHANGELOG.md not found - consider creating one for release management")
        return false
    end

    content = read(CHANGELOG_FILE, String)

    # Check for basic changelog structure
    if !occursin("## [Unreleased]", content)
        println("⚠ CHANGELOG.md missing [Unreleased] section")
        return false
    end

    println("✓ CHANGELOG.md exists and has proper structure")
    return true
end

"""
Prepare for release by validating version and changelog.
"""
function prepare_release()
    println("Preparing for release...")

    # Validate current version
    if !validate_version()
        error("Cannot prepare release with invalid version")
    end

    # Check changelog
    validate_changelog()

    current = get_current_version()
    println("✓ Ready for release of version $current")

    println("\nRelease checklist:")
    println("1. Ensure all tests pass: julia --project=. -e 'using Pkg; Pkg.test()'")
    println("2. Update CHANGELOG.md with release notes")
    println(
        "3. Commit changes: git add -A && git commit -m 'chore: prepare release v$current'",
    )
    println("4. Create git tag: git tag v$current")
    return println("5. Push changes: git push && git push --tags")
end

"""
Main entry point for script.
"""
function main()
    if length(ARGS) == 0
        println("Usage: julia version_management.jl <command>")
        println("Commands:")
        println("  current    - Show current version")
        println("  validate   - Validate current version format")
        println("  bump <type> - Bump version (patch|minor|major)")
        println("  prepare    - Prepare for release")
        return
    end

    command = ARGS[1]

    if command == "current"
        current = get_current_version()
        println("Current version: $current")

    elseif command == "validate"
        validate_version()
        validate_changelog()

    elseif command == "bump"
        if length(ARGS) < 2
            error("Bump command requires type: patch, minor, or major")
        end
        bump_type = ARGS[2]
        new_version = bump_version(bump_type)
        println("Version bumped to $new_version")

    elseif command == "prepare"
        prepare_release()

    else
        error("Unknown command: $command")
    end
end

# Run main function if script is executed directly
if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
