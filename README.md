# Multi-CODEOWNERS Test Project

This repository is designed to test the [multi-codeowners](../multi-codeowners/) GitHub Action, which enforces multi-owner mandatory approvals on Pull Requests.

## 🎯 Purpose

This test project validates that the **published** multi-codeowners action (`tmbtech/multi-codeowners@v1`) correctly:
- Parses CODEOWNERS files
- Maps changed files to required owner groups  
- Enforces approval requirements from ALL relevant code owner groups
- Creates appropriate GitHub status checks and PR comments
- Blocks merging when approvals are missing

> **Note**: The pipelines use the published GitHub Action from the marketplace rather than building from source, ensuring we test the actual released version that users would consume.

## 📁 Test File Structure

The repository contains sample files that match different CODEOWNERS rules:

- `src/index.js` - Owned by `@frontend-team`
- `src/utils.ts` - Owned by `@frontend-team` 
- `README.md` - Owned by `@docs-team`
- `package.json` - **Multi-owner**: `@frontend-team`, `@devops-team`, `@security-team`
- `.github/CODEOWNERS` - Owned by `@devops-team`, `@security-team`

## 🚀 Running Tests

### Automated Pipeline

The GitHub Actions pipeline runs automatically on pull requests and tests both scenarios using the published action:

```yaml
# Uses published action: tmbtech/multi-codeowners@v1
name: Multi-CODEOWNERS Integration Tests
```

### Test Scenarios

#### ✅ Positive Scenario
- Modify only `README.md` (requires `@docs-team` approval)
- Author approves their own PR
- **Expected**: Action should pass ✅

#### ❌ Negative Scenario  
- Modify both `src/index.js` AND `package.json`
- Requires: `@frontend-team`, `@devops-team`, `@security-team`
- No approvals provided
- **Expected**: Action should fail ❌

### Manual Testing

1. **Create test branches:**
   ```bash
   # Positive test
   git checkout -b test-docs-only
   echo "## Test Update" >> README.md
   git add README.md && git commit -m "Update docs"
   
   # Negative test  
   git checkout main
   git checkout -b test-multi-owner
   echo "console.log('test');" >> src/index.js
   echo '  "test": "added",' >> package.json  
   git add . && git commit -m "Update frontend and config"
   ```

2. **Open Pull Requests** from these branches to `main`

3. **Observe the action behavior:**
   - Check the "Checks" tab on each PR
   - Look for status checks named "code-owners-approval"
   - Review bot comments showing approval status

## 🔧 Local Development

### Prerequisites
- [act](https://github.com/nektos/act) for local GitHub Actions testing
- Docker for act execution

### Run Pipeline Locally
```bash
# Install act
brew install act

# Run the integration test
act pull_request -j integration-test

# Run specific scenario
act pull_request -j integration-test --matrix scenario:positive
```

## 📋 Branch Protection Setup

To fully test the enforcement capabilities:

1. Go to **Settings** → **Branches**
2. Add branch protection rule for `main`
3. Enable **"Require status checks to pass before merging"**
4. Select **"code-owners-approval"** from the list
5. Save the protection rule

Now PRs will be blocked until all required code owners approve!

## 🐛 Troubleshooting

### Action Not Running
- Ensure the workflow file is in `.github/workflows/`
- Check that the action has proper permissions in workflow
- Verify the multi-codeowners action builds successfully

### Status Check Not Appearing
- Confirm `checks: write` permission is granted
- Check GitHub Actions logs for errors
- Ensure CODEOWNERS file syntax is valid

### Approvals Not Recognized
- Bot only recognizes approving reviews, not just comments
- Team members must have proper GitHub team membership
- Individual users (like `@username`) don't require team membership

## 📊 Expected Results

### Successful Test Run
```
✅ Positive scenario: Action passes when approvals sufficient
❌ Negative scenario: Action fails when approvals missing  
✅ Unit tests: All underlying logic tests pass
✅ Build: Action compiles without errors
```

### PR Comment Example
```markdown
## 👥 Code Owners Approval Status

⏳ **1/3 required code owner groups have approved.**

### Required Approvals:
- [x] **@frontend-team** (approved by @user)
  - `src/index.js`
  - `package.json`
- [ ] **@devops-team** (pending)
  - `package.json`  
- [ ] **@security-team** (pending)
  - `package.json`
```

---

**Related:** [multi-codeowners action](../multi-codeowners/) | [Documentation](../multi-codeowners/README.md)
