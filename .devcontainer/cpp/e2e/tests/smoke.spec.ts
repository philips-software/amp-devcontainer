import { test, expect } from '@playwright/test';
import { CodespacePage } from './codespace.pom';

test.beforeEach(async ({ page }) => {
  const codespace = new CodespacePage(page);

  await codespace.goto();
  await codespace.areExtensionsActive(['Testing', 'SonarLint', 'CMake', 'Live Share', 'GitHub Pull Requests']);
  await codespace.executeInTerminal('git clean -fdx');
});

test.describe('CMake', () => {
  test('should succesfully build default configuration', async ({ page }) => {
    const codespace = new CodespacePage(page);

    await page.getByRole('button', { name: 'Build the selected target' }).click();
    await page.getByLabel('host, Build for host').locator('a').click();
    await expect(codespace.outputPanel).toContainText('Build finished with exit code 0', { timeout: 5 * 60 * 1000 });
  });
});
