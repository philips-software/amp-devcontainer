import { test, expect } from '@playwright/test';
import { CodespacePage } from './codespace.pom';

test.beforeEach(async ({ page }) => {
  const codespace = new CodespacePage(page);
  await codespace.goto();
  await codespace.arePluginsActive(['Testing', 'SonarLint', 'CMake', 'Live Share', 'GitHub Pull Requests']);
  await codespace.executeInTerminal('git clean -fdx');
});

test('build project', async ({ page }) => {
  await page.getByRole('button', { name: 'Build the selected target' }).click();
  await page.getByLabel('host, Build for host').locator('a').click();
  await expect(page.getByText('[build] Build finished with')).toBeVisible();
});
