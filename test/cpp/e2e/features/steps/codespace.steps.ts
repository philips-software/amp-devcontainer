import { expect } from "@playwright/test";
import { Given, When, Then } from "./fixtures";
import * as path from 'path';

Given("the default build configuration is selected", async () => {
  // No-op
});

Given("the file {string} is opened in the editor", async ({ codespacePage }, file: string) => {
  const fileExtension = path.extname(file).slice(1);

  if (fileExtension === 'cpp') {
    await codespacePage.openCppFileInEditor(file);
  } else {
    await codespacePage.openFileInEditor(file);
  }
});

When("the configuration {string} is built", async ({ codespacePage }, configuration: string) => {
  await codespacePage.page.getByRole('button', { name: 'Build the selected target' }).click();
  await codespacePage.page.getByLabel(configuration).locator('a').click();
});

When("the active document is formatted", async ({ codespacePage }) => {
  await codespacePage.formatDocument();
});

When("the active document is saved", async ({ codespacePage }) => {
  await codespacePage.saveDocument();
});

Then("the output should contain {string}", async ({ codespacePage }, expectedOutput: string) => {
  await expect(codespacePage.outputPanel).toContainText(expectedOutput, { timeout: 5 * 60 * 1000 });
});

Then("the editor should contain {string}", async ({ codespacePage }, expectedContent: string) => {
  await codespacePage.expectEditorContent(new RegExp(expectedContent));
});

Then("the contents of {string} should match the contents of {string}", async ({ codespacePage }, actual: string, expected: string) => {
  await codespacePage.expectFileContentsToMatch(actual, expected);
});
