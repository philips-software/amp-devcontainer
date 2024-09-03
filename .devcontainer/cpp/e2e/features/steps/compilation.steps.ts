import { expect } from "@playwright/test";
import { Given, When, Then } from "./codespace.fixture";

Given("I select the default build configuration", async () => {
  // No-op
});

When("I build configuration {string}", async ({ codespacePage }, configuration: string) => {
  await codespacePage.page.getByRole('button', { name: 'Build the selected target' }).click();
  await codespacePage.page.getByLabel(configuration).locator('a').click();
});

Then("the output should contain {string}", async ({ codespacePage }, expectedOutput: string) => {
  await expect(codespacePage.outputPanel).toContainText(expectedOutput, { timeout: 5 * 60 * 1000 });
});
