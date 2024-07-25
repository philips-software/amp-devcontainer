import { test, expect } from '@playwright/test';

test('has title', async ({ page }) => {
  await page.goto('https://github.com/');
  await expect(page).toHaveTitle(/GitHub/);
});
