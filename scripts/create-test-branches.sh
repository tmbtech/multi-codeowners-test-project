#!/bin/bash

# Create test branches for multi-codeowners action testing
# Usage: ./scripts/create-test-branches.sh

set -e

echo "🚀 Creating test branches for multi-codeowners action..."

# Ensure we're on main branch
git checkout main 2>/dev/null || git checkout master 2>/dev/null || {
  echo "❌ Could not checkout main/master branch"
  exit 1
}

echo "📁 Current branch: $(git branch --show-current)"

# Create positive test branch (README.md only - single owner)
echo "🟢 Creating positive test branch..."
git checkout -b test-positive-docs-only 2>/dev/null || {
  git checkout test-positive-docs-only
  echo "   Branch already exists, switching to it"
}

# Make changes to README only
echo "
## Test Update for Positive Scenario

This change only affects documentation files owned by @docs-team.
Since only one owner group is required, this should pass when the PR author approves.

**Expected outcome**: ✅ PASS (single owner group approval sufficient)
" >> README.md

git add README.md
git commit -m "docs: add test content for positive scenario

This change only modifies README.md which requires @docs-team approval.
The PR author's approval should be sufficient for this scenario." 2>/dev/null || {
  echo "   No changes to commit (branch may already be prepared)"
}

# Create negative test branch (multiple files - multiple owners)
echo "🔴 Creating negative test branch..."
git checkout main 2>/dev/null || git checkout master 2>/dev/null
git checkout -b test-negative-multi-owner 2>/dev/null || {
  git checkout test-negative-multi-owner
  echo "   Branch already exists, switching to it"
}

# Make changes to multiple files requiring different owners
echo "
// Adding test code to trigger @frontend-team ownership
console.log('Test change for negative scenario');

function triggerMultipleOwners() {
  return 'This change should require multiple owner approvals';
}

module.exports = { triggerMultipleOwners };
" >> src/index.js

# Add a field to package.json (requires @frontend-team, @devops-team, @security-team)
if command -v jq >/dev/null 2>&1; then
  # Use jq if available
  jq '.testScenario = "negative-multi-owner"' package.json > package.json.tmp && mv package.json.tmp package.json
else
  # Fallback: simple text append (less safe but works)
  sed -i.bak 's/"license": "MIT"/"license": "MIT",\n  "testScenario": "negative-multi-owner"/g' package.json && rm package.json.bak 2>/dev/null || true
fi

git add src/index.js package.json
git commit -m "feat: add test changes for negative scenario

This commit modifies:
- src/index.js (requires @frontend-team)  
- package.json (requires @frontend-team, @devops-team, @security-team)

Expected outcome: ❌ FAIL (insufficient approvals - multiple owner groups required)" 2>/dev/null || {
  echo "   No changes to commit (branch may already be prepared)"
}

# Create complex test branch (mixed file types)
echo "🟡 Creating complex test branch..."
git checkout main 2>/dev/null || git checkout master 2>/dev/null
git checkout -b test-complex-mixed-files 2>/dev/null || {
  git checkout test-complex-mixed-files
  echo "   Branch already exists, switching to it"
}

# Modify multiple different file types
echo "
## Complex Test Scenario

This scenario tests multiple file types with different ownership requirements.
" >> README.md

echo "
// Complex scenario - frontend changes
export function complexScenarioTest(): string {
  return 'Testing complex multi-owner scenario';
}
" >> src/utils.ts

# Update test-config.json (requires @frontend-team, @devops-team)
if command -v jq >/dev/null 2>&1; then
  jq '.testScenarios.complex.active = true' test-config.json > test-config.json.tmp && mv test-config.json.tmp test-config.json
fi

git add README.md src/utils.ts test-config.json
git commit -m "test: create complex multi-owner test scenario

Changes:
- README.md (requires @docs-team)
- src/utils.ts (requires @frontend-team) 
- test-config.json (requires @frontend-team, @devops-team)

Expected outcome: ❌ FAIL (requires @docs-team, @frontend-team, @devops-team)" 2>/dev/null || {
  echo "   No changes to commit (branch may already be prepared)"
}

# Switch back to main
git checkout main 2>/dev/null || git checkout master 2>/dev/null

echo "✅ Test branches created successfully!"
echo ""
echo "📋 Next steps:"
echo "1. Push branches to remote:"
echo "   git push origin test-positive-docs-only"
echo "   git push origin test-negative-multi-owner" 
echo "   git push origin test-complex-mixed-files"
echo ""
echo "2. Create Pull Requests from these branches to main"
echo ""
echo "3. Observe multi-codeowners action behavior:"
echo "   • Positive: Should pass with author approval"
echo "   • Negative: Should fail (multiple owners required)"
echo "   • Complex: Should fail (multiple different owners required)"
echo ""
echo "4. Test approvals by having different 'owners' approve the PRs"
echo ""
echo "🎯 Branches created:"
git branch --list | grep "test-"
