// Test file for multi-codeowners action
// This file should be owned by @frontend-team according to CODEOWNERS

console.log('Hello from the test project!');

function testFunction() {
  return 'This is just a test file to trigger CODEOWNERS rules';
}

module.exports = { testFunction };
