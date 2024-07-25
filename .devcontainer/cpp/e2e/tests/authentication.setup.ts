import { test as setup } from '@playwright/test';
import * as OTPAuth from 'otpauth';

const authFile = 'playwright/.auth/user.json';

setup('authenticate', async ({ page }) => {
  await page.goto('https://github.com/login');
  await page.getByLabel('Username or email address').fill(process.env.GITHUB_USER!);
  await page.getByLabel('Password').fill(process.env.GITHUB_PASSWORD!);
  await page.getByRole('button', { name: 'Sign in', exact: true }).click();

  let totp = new OTPAuth.TOTP({
    issuer: 'GitHub',
    label: 'GitHub',
    algorithm: 'SHA1',
    digits: 6,
    period: 30,
    secret: process.env.GITHUB_TOTP_SECRET!
  });

  let code = totp.generate();
  await page.getByPlaceholder('XXXXXX').fill(code);

  // Wait until the page receives the cookies.
  //
  // Sometimes login flow sets cookies in the process of several redirects.
  // Wait for the final URL to ensure that the cookies are actually set.
  await page.waitForURL('https://github.com/');
  await page.context().storageState({ path: authFile });
});
