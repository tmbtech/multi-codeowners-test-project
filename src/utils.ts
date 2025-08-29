// Test TypeScript file for multi-codeowners action
// This file should be owned by @frontend-team according to CODEOWNERS

interface TestInterface {
  name: string;
  value: number;
}

export function processData(data: TestInterface): string {
  return `Processing ${data.name} with value ${data.value}`;
}

export const testConfig: TestInterface = {
  name: 'test',
  value: 42
};
