import { Given, When, Then } from "./fixtures";

Given("build configuration {string} is selected", async ({ codespacePage }, configuration: string) => {
  await codespacePage.selectBuildConfiguration(configuration);
});

Given("build preset {string} is selected", async ({ codespacePage }, preset: string) => {
  await codespacePage.selectBuildPreset(preset);
});

Given("the file {string} is opened in the editor", async ({ codespacePage }, file: string) => {
  await codespacePage.openDocument(file);
});

When("the selected target is built", async ({ codespacePage }) => {
  await codespacePage.buildSelectedTarget();
});

When("the active document is formatted", async ({ codespacePage }) => {
  await codespacePage.formatDocument();
});

When("the active document is saved", async ({ codespacePage }) => {
  await codespacePage.saveDocument();
});

Then("the output should contain {string}", async ({ codespacePage }, expectedOutput: string) => {
  await codespacePage.expectOutputToContain(expectedOutput);
});

Then("the editor should contain {string}", async ({ codespacePage }, expectedContent: string) => {
  await codespacePage.expectEditorContent(new RegExp(expectedContent));
});

Then("the contents of {string} should match the contents of {string}", async ({ codespacePage }, actual: string, expected: string) => {
  await codespacePage.expectFileContentsToMatch(actual, expected);
});
