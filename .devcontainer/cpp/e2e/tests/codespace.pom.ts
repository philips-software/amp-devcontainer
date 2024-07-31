import { expect, type Locator, type Page } from '@playwright/test';

export class CodespacePage {
  readonly page: Page;

  constructor(page: Page) {
    this.page = page;
  }

  async goto() {
    await this.page.goto('https://' + process.env.CODESPACE_NAME + '.github.dev');
  }

  async arePluginsActive(plugins: string[]) {
    for (const plugin of plugins) {
      await expect(this.page.getByRole('tab', { name: plugin })).toBeVisible();
    }
  }

  async executeInTerminal(commands: string | string[]) {
    let commandsWithExit = Array.isArray(commands) ? [...commands + 'exit'] : [commands, 'exit'];

    await this.page.keyboard.press('Control+Shift+`');

    for (const command of commandsWithExit) {
      await this.page.keyboard.type(command);
      await this.page.keyboard.press('Enter');
    }
  }
}
