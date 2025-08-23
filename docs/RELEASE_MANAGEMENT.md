# Release Management Guide

This document outlines the release management process for PointController.jl, including version management, dependency updates, and release procedures.

## Semantic Versioning (SemVer)

PointController.jl follows [Semantic Versioning 2.0.0](https://semver.org/) with the format `MAJOR.MINOR.PATCH`:

- **MAJOR**: Incompatible API changes, breaking changes
- **MINOR**: New functionality in backwards compatible manner
- **PATCH**: Backwards compatible bug fixes

### Version Bumping Guidelines

#### Patch Version (0.0.X)
Increment for:
- Bug fixes that don't change API
- Documentation improvements
- Performance optimizations without API changes
- Compatible dependency updates
- Internal refactoring without external impact

#### Minor Version (0.X.0)
Increment for:
- New features or functionality
- New public API additions (backwards compatible)
- Significant performance improvements
- New configuration options
- Enhanced error handling or logging

#### Major Version (X.0.0)
Increment for:
- Breaking API changes
- Removal of deprecated features
- Significant architectural changes
- Changes requiring user migration
- Incompatible dependency updates

## Version Management Script

Use the provided version management script for all version operations:

```bash
# Show current version
julia scripts/version_management.jl current

# Validate version format and changelog
julia scripts/version_management.jl validate

# Bump version (automatically updates Project.toml)
julia scripts/version_management.jl bump patch
julia scripts/version_management.jl bump minor
julia scripts/version_management.jl bump major

# Prepare for release (validation and checklist)
julia scripts/version_management.jl prepare
```

## Dependency Management

### CompatHelper Integration

CompatHelper automatically monitors dependencies and creates pull requests for updates:

- **Patch updates**: Auto-merged if CI passes
- **Minor updates**: Require manual review
- **Major updates**: Require manual review and testing

Configuration is managed in `.compathelper.yml`:

```yaml
update_policies:
  GLMakie:
    auto_update: "patch"
    review_required: ["minor", "major"]
```

### Manual Dependency Updates

For manual dependency management:

```bash
# Check for outdated packages
julia --project=. -e "using Pkg; Pkg.status(outdated=true)"

# Update specific package
julia --project=. -e "using Pkg; Pkg.update(\"GLMakie\")"

# Update all packages (use with caution)
julia --project=. -e "using Pkg; Pkg.update()"
```

### Compatibility Constraints

Maintain conservative compatibility constraints in `Project.toml`:

```toml
[compat]
GLMakie = "0.10, 0.11"  # Allow patch updates within minor versions
julia = "1.10"          # Require specific LTS version
```

## Release Process

### 1. Pre-Release Preparation

1. **Update Dependencies**
   ```bash
   # Review and merge any pending CompatHelper PRs
   # Test with updated dependencies
   julia --project=. -e "using Pkg; Pkg.test()"
   ```

2. **Run Full Test Suite**
   ```bash
   # Ensure all tests pass
   julia run_tests.jl
   
   # Run integration tests
   julia --project=. test/test_integration_comprehensive.jl
   ```

3. **Update Documentation**
   - Review and update README.md
   - Update API documentation
   - Verify examples work with current version

### 2. Version and Changelog Update

1. **Update CHANGELOG.md**
   - Move items from `[Unreleased]` to new version section
   - Add release date
   - Ensure all changes are documented

2. **Bump Version**
   ```bash
   # Choose appropriate version bump
   julia scripts/version_management.jl bump patch  # or minor/major
   ```

3. **Validate Release**
   ```bash
   julia scripts/version_management.jl prepare
   ```

### 3. Create Release

1. **Commit Changes**
   ```bash
   git add -A
   git commit -m "chore: prepare release v$(julia scripts/version_management.jl current)"
   ```

2. **Create Git Tag**
   ```bash
   VERSION=$(julia scripts/version_management.jl current)
   git tag -a "v$VERSION" -m "Release version $VERSION"
   ```

3. **Push Changes**
   ```bash
   git push origin main
   git push origin --tags
   ```

### 4. Post-Release

1. **Verify Release**
   - Check that GitHub release is created
   - Verify package can be installed from registry
   - Test installation in clean environment

2. **Update Documentation**
   - Deploy updated documentation
   - Update any external references

3. **Announce Release**
   - Update project README if needed
   - Announce in relevant communities

## Hotfix Process

For critical bug fixes that need immediate release:

1. **Create Hotfix Branch**
   ```bash
   git checkout -b hotfix/v0.1.1 v0.1.0
   ```

2. **Apply Fix**
   - Make minimal changes to fix the issue
   - Add tests for the fix
   - Update CHANGELOG.md

3. **Release Hotfix**
   ```bash
   julia scripts/version_management.jl bump patch
   git commit -am "fix: critical bug fix for v0.1.1"
   git tag v0.1.1
   git push origin hotfix/v0.1.1 --tags
   ```

4. **Merge Back**
   ```bash
   git checkout main
   git merge hotfix/v0.1.1
   git push origin main
   ```

## Automated Workflows

### CompatHelper Workflow
- Runs daily to check for dependency updates
- Creates PRs for compatible updates
- Requires manual approval for major changes

### CI/CD Integration
- All releases must pass CI tests
- Automated testing on multiple Julia versions
- Code coverage reporting

### Release Automation
Future enhancements may include:
- Automated GitHub release creation
- Package registry submission
- Documentation deployment

## Best Practices

### Version Planning
- Plan major releases with breaking changes
- Communicate deprecations in advance
- Maintain backwards compatibility when possible

### Testing
- Comprehensive test coverage for all releases
- Test on multiple platforms and Julia versions
- Performance regression testing

### Documentation
- Keep CHANGELOG.md up to date
- Document breaking changes clearly
- Provide migration guides for major versions

### Communication
- Use conventional commit messages
- Clear release notes
- Timely security updates

## Troubleshooting

### Common Issues

**Version Script Errors**
```bash
# If version script fails, check Project.toml format
julia -e "using TOML; TOML.parsefile(\"Project.toml\")"
```

**CompatHelper Issues**
- Check GitHub Actions logs
- Verify GITHUB_TOKEN permissions
- Review .compathelper.yml configuration

**Release Failures**
- Ensure all tests pass locally
- Check git tag format (v1.2.3)
- Verify Project.toml version matches tag

### Recovery Procedures

**Incorrect Version Bump**
```bash
# Reset to previous version
git reset --hard HEAD~1
julia scripts/version_management.jl bump <correct_type>
```

**Failed Release**
```bash
# Delete incorrect tag
git tag -d v1.2.3
git push origin :refs/tags/v1.2.3
```

## References

- [Semantic Versioning](https://semver.org/)
- [Keep a Changelog](https://keepachangelog.com/)
- [CompatHelper.jl Documentation](https://github.com/JuliaRegistries/CompatHelper.jl)
- [Julia Package Development](https://pkgdocs.julialang.org/)