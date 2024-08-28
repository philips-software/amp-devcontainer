import { test, expect } from '@playwright/test';
import { CodespacePage } from './codespace.pom';

test.beforeEach(async ({ page }) => {
  const codespace = new CodespacePage(page);

  await codespace.goto();
  await codespace.areExtensionsActive(['Testing', 'SonarLint', 'CMake', 'Live Share', 'GitHub Pull Requests']);
  await codespace.executeInTerminal('git clean -fdx');
});

test.describe('CMake', () => {
  test('should succesfully build without selecting configuration', async ({ page }) => {
    const codespace = new CodespacePage(page);

    await page.getByRole('button', { name: 'Build the selected target' }).click();
    await page.getByLabel('host, Build for host').locator('a').click();
    await expect(codespace.outputPanel).toContainText('Build finished with exit code 0', { timeout: 5 * 60 * 1000 });
  });

  test('should succesfully build after selecting configuration', async ({ page }) => {
    const codespace = new CodespacePage(page);

    await codespace.openTabByName('CMake');
    await expect(page.getByRole('treeitem', { name: 'Change Configure Preset' })).toContainText('[No Configure Preset Selected]');
    await expect(page.getByRole('treeitem', { name: 'Change Build Preset' })).toContainText('[No Build Preset Selected]');

    await codespace.executeFromCommandPalette([{ command: 'CMake: Select Configure Preset' },
                                               { command: 'host', prompt: 'Select a configure preset' }]);
    await expect(page.getByRole('treeitem', { name: 'Change Configure Preset' })).toContainText('host');

    await codespace.executeFromCommandPalette([{ command: 'CMake: Select Build Preset' },
                                               { command: 'host-Release', prompt: 'Select a build preset' }]);
    await expect(page.getByRole('treeitem', { name: 'Change Build Preset' })).toContainText('host-Release');

    await page.getByRole('button', { name: 'Build the selected target' }).click();
    await expect(codespace.outputPanel).toContainText('Build finished with exit code 0', { timeout: 5 * 60 * 1000 });
  });
});
