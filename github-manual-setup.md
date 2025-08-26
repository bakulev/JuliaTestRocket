# GitHub Manual Setup Tasks

This document contains manual GitHub UI configuration steps that must be completed by the repository owner. These steps cannot be automated through code but are essential for a complete professional GitHub repository setup.

**Prerequisites:** Complete the automated tasks from `.kiro/specs/github-best-practices/tasks.md` first, as many of these manual steps depend on files created by those tasks.

---

## Phase 1: Repository Basic Configuration

### Task 1.1: Enable Repository Features
- [ ] Go to **Settings → General**
- [ ] Under "Features" section, enable:
  - [ ] ✅ **Issues**
  - [ ] ✅ **Discussions** 
  - [ ] ✅ **Projects**
- [ ] Under "Pull Requests" section, enable:
  - [ ] ✅ **Allow merge commits**
  - [ ] ✅ **Allow squash merging**
  - [ ] ✅ **Allow rebase merging**
  - [ ] ✅ **Always suggest updating pull request branches**
  - [ ] ✅ **Allow auto-merge**
  - [ ] ✅ **Automatically delete head branches**

### Task 1.2: Configure Repository About Section
- [ ] Go to repository main page
- [ ] Click the ⚙️ gear icon next to "About"
- [ ] Add description: "Interactive Julia application for controlling a point using WASD keys with Makie.jl visualization"
- [ ] Add website: `https://[username].github.io/JuliaTestRocket/` (replace [username] with your GitHub username)
- [ ] Add topics: `julia`, `visualization`, `interactive`, `makie`, `gui`, `graphics`, `real-time`, `keyboard-control`
- [ ] ✅ Check "Use your repository description"
- [ ] ✅ Check "Releases"
- [ ] ✅ Check "Packages"
- [ ] Click **Save changes**

---

## Phase 2: Security and Quality Configuration

### Task 2.1: Enable Security Features
- [ ] Go to **Settings → Security & Analysis**
- [ ] Enable all security features:
  - [ ] ✅ **Dependabot alerts** (should auto-enable for public repos)
  - [ ] ✅ **Dependabot security updates** (should auto-enable for public repos)
  - [ ] ✅ **Dependabot version updates** (will use .github/dependabot.yml from automated tasks)
  - [ ] ✅ **Code scanning alerts**
  - [ ] ✅ **Secret scanning alerts**

### Task 2.2: Configure Branch Protection Rules
**⚠️ Important:** Complete this AFTER the CI workflows are set up and working from the automated tasks.

- [ ] Go to **Settings → Branches**
- [ ] Click **Add rule**
- [ ] Branch name pattern: `main`
- [ ] Configure protection settings:
  - [ ] ✅ **Require a pull request before merging**
    - [ ] ✅ **Require approvals** (set to 1)
    - [ ] ✅ **Dismiss stale PR approvals when new commits are pushed**
    - [ ] ✅ **Require review from code owners**
  - [ ] ✅ **Require status checks to pass before merging**
    - [ ] ✅ **Require branches to be up to date before merging**
    - [ ] Add required status checks (after CI is working):
      - [ ] `CI` (Julia 1.10, ubuntu-latest)
      - [ ] `CI` (Julia 1.11, ubuntu-latest) 
      - [ ] `Format Check`
      - [ ] `Documentation`
  - [ ] ✅ **Require conversation resolution before merging**
  - [ ] ✅ **Include administrators**
- [ ] Click **Create**

---

## Phase 3: Documentation Deployment Setup

### Task 3.1: Configure GitHub Pages
- [ ] Go to **Settings → Pages**
- [ ] Under "Source", select **GitHub Actions**
- [ ] Save settings
- [ ] Wait for first documentation build to complete (after automated tasks create the workflow)

### Task 3.2: Generate SSH Key for Documentation Deployment
**⚠️ Run these commands in your local terminal:**

```bash
# Generate SSH key pair
ssh-keygen -t rsa -b 4096 -C "documenter-key" -f ~/.ssh/documenter_key -N ""

# Display public key (copy this output)
cat ~/.ssh/documenter_key.pub
```

- [ ] Copy the public key output from the command above
- [ ] Go to **Settings → Deploy keys**
- [ ] Click **Add deploy key**
- [ ] Title: `Documenter.jl`
- [ ] Paste the public key content
- [ ] ✅ Check **Allow write access**
- [ ] Click **Add key**

### Task 3.3: Add Documentation Secret
**⚠️ Run this command in your local terminal:**

```bash
# Display private key (copy this entire output including headers)
cat ~/.ssh/documenter_key
```

- [ ] Copy the entire private key output (including `-----BEGIN OPENSSH PRIVATE KEY-----` and `-----END OPENSSH PRIVATE KEY-----`)
- [ ] Go to **Settings → Secrets and variables → Actions**
- [ ] Click **New repository secret**
- [ ] Name: `DOCUMENTER_KEY`
- [ ] Value: Paste the complete private key content
- [ ] Click **Add secret**

---

## Phase 4: Code Coverage Setup

### Task 4.1: Set Up Codecov Integration
- [ ] Go to [codecov.io](https://codecov.io)
- [ ] Sign in with your GitHub account
- [ ] Click **Add repository**
- [ ] Find and add your `PointController` repository
- [ ] Copy the repository token from the Codecov dashboard
- [ ] Go to **Settings → Secrets and variables → Actions** in your GitHub repository
- [ ] Click **New repository secret**
- [ ] Name: `CODECOV_TOKEN`
- [ ] Value: Paste the Codecov token
- [ ] Click **Add secret**

---

## Phase 5: Community Setup

### Task 5.1: Configure Issue Labels
- [ ] Go to **Issues → Labels**
- [ ] Create additional labels (click **New label** for each):
  - [ ] `priority: high` (color: `#d73a4a` - red)
  - [ ] `priority: medium` (color: `#fbca04` - orange)
  - [ ] `priority: low` (color: `#0e8a16` - green)
  - [ ] `type: performance` (color: `#5319e7` - purple)
  - [ ] `type: documentation` (color: `#0052cc` - blue)
  - [ ] `good first issue` (color: `#7057ff` - purple)
  - [ ] `help wanted` (color: `#008672` - teal)

### Task 5.2: Set Up GitHub Discussions
- [ ] Go to **Settings → General**
- [ ] Scroll to "Features" section
- [ ] ✅ Enable **Discussions** (if not already enabled)
- [ ] Go to **Discussions** tab
- [ ] Configure categories:
  - [ ] **General** - General discussions about the project
  - [ ] **Ideas** - Share ideas for new features
  - [ ] **Q&A** - Ask questions and get help
  - [ ] **Show and tell** - Show off what you've built

---

## Phase 6: Advanced Configuration

### Task 6.1: Configure Notifications (Optional)
- [ ] Go to **Settings → Notifications**
- [ ] Configure email notifications for:
  - [ ] Issues and PRs
  - [ ] Security alerts
  - [ ] Actions workflow failures

### Task 6.2: Set Up Project Boards (Optional)
- [ ] Go to **Projects** tab
- [ ] Click **New project**
- [ ] Choose **Board** template
- [ ] Name: "JuliaTestRocket Development"
- [ ] Set up columns: Backlog, In Progress, Review, Done
- [ ] Link to repository issues and PRs

---

## Phase 7: Testing and Validation

### Task 7.1: Test CI/CD Pipeline
**⚠️ Do this AFTER completing the automated tasks that create the workflows:**

- [ ] Create a test branch: `git checkout -b test/ci-pipeline`
- [ ] Make a small change to README.md
- [ ] Commit and push: `git add . && git commit -m "test: verify CI pipeline" && git push -u origin test/ci-pipeline`
- [ ] Create a pull request from the test branch
- [ ] Verify all CI checks run and pass:
  - [ ] CI workflow runs on multiple platforms (Ubuntu, macOS, Windows)
  - [ ] Format check passes
  - [ ] Documentation builds successfully
  - [ ] Security scans complete
- [ ] Merge the PR
- [ ] Verify main branch workflows run successfully
- [ ] Delete the test branch

### Task 7.2: Test Documentation Deployment
**⚠️ Do this AFTER the documentation workflow is created and SSH keys are configured:**

- [ ] Wait for documentation workflow to complete (check Actions tab)
- [ ] Visit `https://[username].github.io/JuliaTestRocket/` (replace [username])
- [ ] Verify documentation site loads correctly
- [ ] Check all pages are accessible:
  - [ ] Home page
  - [ ] Getting Started
  - [ ] API Reference
  - [ ] Examples (if created)

### Task 7.3: Test Issue and PR Templates
**⚠️ Do this AFTER the automated tasks create the templates:**

- [ ] Create a test issue using the bug report template
- [ ] Verify all fields are present and working
- [ ] Create a test PR using the PR template
- [ ] Verify checklist and sections are correct
- [ ] Close the test issue and PR (or convert to real issues if useful)

---

## Phase 8: Final Validation

### Task 8.1: Repository Health Check
Verify all systems are working:

- [ ] All CI/CD workflows show green status ✅
- [ ] Documentation builds and deploys successfully ✅
- [ ] Security scanning is active (check Security tab) ✅
- [ ] Branch protection is enforced (try pushing to main directly - should fail) ✅
- [ ] Issue and PR templates work correctly ✅
- [ ] Code coverage reporting is active (check after running tests) ✅
- [ ] All badges in README are functional ✅

### Task 8.2: Community Readiness Check
- [ ] Contributing guidelines are clear and accessible ✅
- [ ] Issue templates guide users effectively ✅
- [ ] Documentation is comprehensive and loads properly ✅
- [ ] Repository is discoverable (topics, description set) ✅
- [ ] Code of conduct is in place ✅

---

## Troubleshooting

### Common Issues and Solutions

**CI workflows not running:**
- Check that workflows are in `.github/workflows/` directory
- Verify YAML syntax is correct
- Check repository permissions for Actions

**Documentation not deploying:**
- Verify SSH key is correctly configured
- Check that `DOCUMENTER_KEY` secret is set correctly
- Ensure GitHub Pages is set to "GitHub Actions" source

**Branch protection not working:**
- Ensure status checks are spelled exactly as they appear in Actions
- Wait for at least one successful CI run before adding status checks
- Verify you have admin permissions on the repository

**Codecov not reporting:**
- Verify `CODECOV_TOKEN` secret is set correctly
- Check that coverage is being generated in CI
- Ensure Codecov action is included in CI workflow

---

## Completion Timeline

**Estimated time for manual setup:**
- **Phase 1-2**: 15 minutes (basic configuration)
- **Phase 3**: 30 minutes (documentation setup with SSH keys)
- **Phase 4**: 10 minutes (Codecov setup)
- **Phase 5-6**: 20 minutes (community features)
- **Phase 7-8**: 30 minutes (testing and validation)

**Total estimated time: 1.5-2 hours**

---

## Next Steps After Completion

1. **Start using the repository** with the new professional setup
2. **Create your first real issue** using the templates
3. **Make your first PR** to test the review process
4. **Prepare for Julia registry registration** (if desired)
5. **Invite collaborators** and test the community features

**🎉 Congratulations!** Your repository will be following state-of-the-art GitHub best practices for open source projects!