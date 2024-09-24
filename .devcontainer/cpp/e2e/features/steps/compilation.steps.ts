import { expect } from "@playwright/test";
import { Given, When, Then } from "./fixtures";

Given("the default build configuration is selected", async () => {
  // No-op
});

When("the configuration {string} is built", async ({ codespacePage }, configuration: string) => {
  await codespacePage.page.getByRole('button', { name: 'Build the selected target' }).click();
  await codespacePage.page.getByLabel(configuration).locator('a').click();
});

Then("the output should contain {string}", async ({ codespacePage }, expectedOutput: string) => {
  await expect(codespacePage.outputPanel).toContainText(expectedOutput, { timeout: 5 * 60 * 1000 });
});
