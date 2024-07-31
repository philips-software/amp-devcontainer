import { test, expect, type Page } from '@playwright/test';

export class CodespacePage {
  readonly page: Page;

  constructor(page: Page) {
    this.page = page;
  }

  async goto() {
    await this.page.goto('https://' + process.env.CODESPACE_NAME + '.github.dev');
  }

  /**
   * Wait for the extensions to be active in the Codespace.
   *
   * This method is used to verify that the extensions in `extensions` are active in the Codespace.
   * Used when waiting for the Codespace to be ready for testing. As the
   * extensions are typically activated last, before the Codespace is ready for use.
   *
   * ** USAGE **
   *
   * ```ts
   * const codespace = new CodespacePage(page);
   * await codespace.areExtensionsActive(['SonarLint', 'CMake', 'Live Share', 'GitHub Pull Requests']);
   * ```
   *
   * @param extensions List of extensions to wait for.
   */
  async areExtensionsActive(extensions: string[]) {
    test.setTimeout(3 * 60 * 1000);

    for (const plugin of extensions) {
      await expect(this.page.getByRole('tab', { name: plugin }).locator('a')).toBeVisible({ timeout: 5 * 60 * 1000 });
    }
  }

  async executeInTerminal(commands: string | string[]) {
    let commandsWithExit = Array.isArray(commands) ? [...commands + 'exit'] : [commands, 'exit'];

    await this.page.keyboard.press('Control+Shift+`');
    expect(this.page.locator('.terminal-widget-container').first()).toBeVisible();

    for (const command of commandsWithExit) {
      await this.page.keyboard.type(command);
      await this.page.keyboard.press('Enter');
    }
  }

  async openTabByName(name: string) {
    await this.page.getByRole('tab', { name: name }).locator('a').click();
  }
}
