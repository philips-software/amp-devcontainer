import { test, expect } from '@playwright/test';

test('build project', async ({ page }) => {
  await page.goto('/');
  await expect(page.getByLabel('host, Build for host')).toBeVisible();
  await page.getByRole('button', { name: 'Build the selected target' }).click();
  await page.getByLabel('host, Build for host').locator('a').click();
  await expect(page.getByText('[build] Build finished with')).toBeVisible();
});
