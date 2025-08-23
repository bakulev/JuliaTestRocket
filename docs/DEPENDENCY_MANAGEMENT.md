# Dependency Management

This document describes the dependency management strategy for PointController.jl, including automated updates, compatibility policies, and manual management procedures.

## Overview

PointController.jl uses a modern dependency management approach with:

- **CompatHelper.jl** for automated dependency updates
- **Semantic versioning** for predictable compatibility
- **Conservative update policies** for stability
- **Comprehensive testing** before accepting updates

## Automated Dependency Updates

### CompatHelper Integration

CompatHelper automatically monitors our dependencies and creates pull requests for updates:

```yaml
# .compathelper.yml configuration
update_policies:
  GLMakie:
    auto_update: "patch"           # Auto-update patch versions
    review_required: ["minor", "major"]  # Manual review for larger changes
```

### Update Schedule

- **Patch updates**: Checked weekly, auto-merged if CI passes
- **Minor updates**: Checked monthly, require manual review
- **Major updates**: Checked quarterly, require thorough testing

### Workflow

1. CompatHelper runs daily via GitHub Actions
2. Creates PR for compatible updates
3. CI tests run automatically
4. Patch updates auto-merge if tests pass
5. Minor/major updates require manual review

## Compatibility Constraints

### Current Constraints

```toml
[compat]
GLMakie = "0.10, 0.11"  # Allow patch updates within these minor versions
julia = "1.10"          # Require Julia 1.10 LTS for stability
```

### Constraint Philosophy

- **Conservative approach**: Prefer stability over latest features
- **LTS versions**: Use Long Term Support versions when available
- **Patch flexibility**: Allow patch updates for bug fixes
- **Minor caution**: Require review for minor version updates
- **Major scrutiny**: Thorough testing for major version updates

## Manual Dependency Management

### Checking Dependency Status

```bash
# Show all dependencies
make deps-status

# Check for outdated packages
make deps-outdated

# Or use Julia directly
julia --project=. -e "using Pkg; Pkg.status(outdated=true)"
```

### Updating Dependencies

```bash
# Update specific package (recommended)
julia --project=. -e "using Pkg; Pkg.update(\"GLMakie\")"

# Update all packages (use with caution)
make deps-update
```

### Adding New Dependencies

1. **Add to Project.toml**:
   ```toml
   [deps]
   NewPackage = "uuid-here"
   
   [compat]
   NewPackage = "1.0"  # Start with conservative constraint
   ```

2. **Test thoroughly**:
   ```bash
   julia --project=. -e "using Pkg; Pkg.instantiate()"
   make test
   ```

3. **Update documentation** if the dependency affects public API

## Dependency Policies

### Core Dependencies

**GLMakie.jl** - Primary visualization backend
- **Policy**: Conservative updates, thorough testing required
- **Rationale**: Core functionality depends on GLMakie stability
- **Update process**: Test all visualization features before accepting

### Development Dependencies

**Test.jl** - Testing framework
- **Policy**: Follow Julia standard library updates
- **Rationale**: Maintained by Julia core team
- **Update process**: Automatic with Julia version updates

### Future Dependencies

When adding new dependencies, consider:

1. **Maintenance status**: Is the package actively maintained?
2. **Stability**: Does it follow semantic versioning?
3. **Community**: Is it widely used and trusted?
4. **Alternatives**: Are there lighter-weight alternatives?
5. **Necessity**: Is it truly needed or can we implement internally?

## Compatibility Testing

### Automated Testing

All dependency updates trigger:
- Full test suite execution
- Multiple Julia version testing (1.10, 1.11, nightly)
- Cross-platform testing (Linux, macOS, Windows)

### Manual Testing Checklist

For major dependency updates:

- [ ] All unit tests pass
- [ ] Integration tests pass
- [ ] Visual functionality works correctly
- [ ] Performance hasn't regressed
- [ ] Documentation examples still work
- [ ] Installation process unchanged

### Performance Impact

Monitor performance impact of dependency updates:

```bash
# Run performance tests (when implemented)
julia --project=. test/benchmarks.jl

# Profile memory usage
julia --project=. --track-allocation=user test/profile_memory.jl
```

## Troubleshooting

### Common Issues

**Dependency Resolution Conflicts**
```bash
# Clear Manifest.toml and reinstall
rm Manifest.toml
julia --project=. -e "using Pkg; Pkg.instantiate()"
```

**Incompatible Version Constraints**
```bash
# Check what versions are available
julia --project=. -e "using Pkg; Pkg.Registry.update(); println(Pkg.dependencies())"
```

**CompatHelper Not Working**
- Check GitHub Actions logs
- Verify GITHUB_TOKEN permissions
- Review .compathelper.yml syntax

### Recovery Procedures

**Rollback Dependency Update**
```bash
# Revert to previous Manifest.toml
git checkout HEAD~1 -- Manifest.toml
julia --project=. -e "using Pkg; Pkg.instantiate()"
```

**Force Dependency Version**
```toml
# In Project.toml, pin to specific version
[compat]
ProblematicPackage = "=1.2.3"  # Exact version pin
```

## Best Practices

### For Maintainers

1. **Review all dependency PRs** carefully
2. **Test thoroughly** before merging
3. **Document breaking changes** in CHANGELOG.md
4. **Communicate updates** to users
5. **Monitor for regressions** after updates

### For Contributors

1. **Minimal dependencies**: Only add what's necessary
2. **Conservative constraints**: Start with narrow version ranges
3. **Test compatibility**: Ensure your changes work with current deps
4. **Document requirements**: Update docs if adding dependencies

### For Users

1. **Pin versions** if you need stability
2. **Test updates** in development environment first
3. **Report issues** if updates cause problems
4. **Stay informed** about dependency changes

## Monitoring and Alerts

### GitHub Actions

Monitor dependency health via:
- CompatHelper workflow status
- CI test results with updated dependencies
- Security vulnerability alerts

### Manual Monitoring

Periodically check:
- Dependency maintenance status
- Security advisories
- Performance impact of updates
- Community feedback on new versions

## Security Considerations

### Vulnerability Management

1. **Automated scanning**: GitHub Dependabot alerts
2. **Rapid response**: Security updates get priority
3. **Version pinning**: Consider pinning for security-critical deployments
4. **Audit trail**: Document all security-related updates

### Supply Chain Security

- Verify package authenticity
- Monitor for suspicious updates
- Use official package registries only
- Review dependency trees for unexpected additions

## Future Enhancements

### Planned Improvements

1. **Automated benchmarking** for performance regression detection
2. **Dependency health scoring** based on maintenance metrics
3. **Custom update policies** per dependency type
4. **Integration with Julia registry** for better metadata

### Tooling Enhancements

1. **Dependency dashboard** for visual monitoring
2. **Automated rollback** on test failures
3. **Performance impact analysis** for updates
4. **Security scanning integration**

## References

- [CompatHelper.jl Documentation](https://github.com/JuliaRegistries/CompatHelper.jl)
- [Julia Package Manager](https://pkgdocs.julialang.org/)
- [Semantic Versioning](https://semver.org/)
- [Keep a Changelog](https://keepachangelog.com/)