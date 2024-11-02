import { type Page } from '@playwright/test';
import * as OTPAuth from 'otpauth';
import { STORAGE_STATE } from '../playwright.config';

export class AuthenticationPage {
  readonly page: Page;

  constructor(page: Page) {
    this.page = page;
  }

  async authenticate() {
    await this.page.goto('https://github.com/login');
    await this.page.getByLabel('Username or email address').fill(process.env.GITHUB_USER!);
    await this.page.getByLabel('Password').fill(process.env.GITHUB_PASSWORD!);
    await this.page.getByRole('button', { name: 'Sign in', exact: true }).click();

    let totp = new OTPAuth.TOTP({
      issuer: 'GitHub',
      label: 'GitHub',
      algorithm: 'SHA1',
      digits: 6,
      period: 30,
      secret: process.env.GITHUB_TOTP_SECRET!
    });

    let code = totp.generate();
    await this.page.getByPlaceholder('XXXXXX').fill(code);

    // Wait until the page receives the cookies.
    //
    // Sometimes login flow sets cookies in the process of several redirects.
    // Wait for the final URL to ensure that the cookies are actually set.
    await this.page.waitForURL('https://github.com/');
    await this.page.context().storageState({ path: STORAGE_STATE });
  }
}
