# Multi-CODEOWNERS Action Bundling Issue

## 🐛 Issue Summary

The published `tmbtech/multi-codeowners@v1` GitHub Action fails at runtime with a module resolution error, preventing code owner enforcement workflows from functioning.

## 💥 Symptoms

### Error Message
```
Error: Cannot find module '@actions/core'
Require stack:
- /home/runner/work/_actions/tmbtech/multi-codeowners/v1/dist/index.js
```

### Full Stack Trace
```
node:internal/modules/cjs/loader:1215
  throw err;
  ^

Error: Cannot find module '@actions/core'
Require stack:
- /home/runner/work/_actions/tmbtech/multi-codeowners/v1/dist/index.js
    at Module._resolveFilename (node:internal/modules/cjs/loader:1212:15)
    at Module._load (node:internal/modules/cjs/loader:1043:27)
    at Module.require (node:internal/modules/cjs/loader:1298:19)
    at require (node:internal/modules/helpers:182:18)
    at Object.<anonymous> (/home/runner/work/_actions/tmbtech/multi-codeowners/v1/dist/index.js:38:27)
    at Module._compile (node:internal/modules/cjs/loader:1529:14)
    at Module._extensions..js (node:internal/modules/cjs/loader:1613:10)
    at Module.load (node:internal/modules/cjs/loader:1275:32)
    at Module._load (node:internal/modules/cjs/loader:1096:12)
    at Function.executeUserEntryPoint [as runMain] (node:internal/modules/run_main:164:12) {
  code: 'MODULE_NOT_FOUND',
  requireStack: [
    '/home/runner/work/_actions/tmbtech/multi-codeowners/v1/dist/index.js'
  ]
}

Node.js v20.19.4
```

### Failing Workflows
- **Run ID**: 17333418602 - Code Owners Approval Enforcement
- **Run ID**: 17333418573 - Multi-CODEOWNERS Action Integration Tests

## 🔍 Root Cause Analysis

### Primary Issue
The published `v1` tag contains a `dist/index.js` file that attempts to require `@actions/core` at runtime, but this dependency was not properly bundled into the distribution.

### Technical Explanation
1. **Missing Bundling Step**: The action's build process should bundle all npm dependencies into the `dist/` directory using a tool like `@vercel/ncc` or webpack
2. **Runtime Dependency**: In GitHub Actions environment, only the contents of the action's repository are available - npm packages are not installed automatically
3. **Distribution Mismatch**: The published v1 tag contains unbundled JavaScript that expects `node_modules` to be present

### Evidence
- ✅ **Unit tests pass** - indicating the source code is functional
- ✅ **Action builds successfully** - confirming TypeScript compilation works
- ❌ **Runtime failure** - only occurs when action executes in GitHub Actions environment
- ❌ **Missing bundled dependencies** - `@actions/core` and other npm packages not in distribution

## 🛠️ Suggested Solution

### Immediate Fix
1. **Rebuild distribution**: Run the proper build pipeline with bundling
   ```bash
   npm run build
   npm run package  # or equivalent bundling step using ncc/webpack
   ```

2. **Publish fixed version**: Release as `v1.0.1` or `v1.1.0`
   ```bash
   git add dist/
   git commit -m "fix: bundle dependencies in distribution"
   git tag v1.0.1
   git push origin v1.0.1
   ```

### Long-term Prevention
1. **Add bundling check** to CI pipeline
2. **Test distribution** in isolated environment before publishing
3. **Automate releases** with proper build/bundle/test workflow

## 📋 Reproduction Steps

1. Create any workflow using `tmbtech/multi-codeowners@v1`
2. Trigger the workflow on a pull request
3. Observe runtime module resolution failure

## 🔗 Related Links
- [GitHub Actions: Creating a JavaScript action](https://docs.github.com/en/actions/creating-actions/creating-a-javascript-action)
- [@vercel/ncc bundling tool](https://github.com/vercel/ncc)
- [Failing workflow run example](https://github.com/tmbtech/multi-codeowners-test-project/actions/runs/17333418602)

## ✅ Testing Verification

Once the fix is published, verify with:
1. Update workflow to use fixed version (e.g., `@v1.0.1`)
2. Trigger test workflow
3. Confirm action executes without module resolution errors
4. Validate code owner enforcement functionality

---

**Report Generated**: 2025-08-29  
**Issue Status**: 🔴 Blocking all workflows using v1 tag  
**Severity**: High - Action completely non-functional
