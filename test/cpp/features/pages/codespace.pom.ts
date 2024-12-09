import { test, expect, type Page, type Locator } from '@playwright/test';
import path from 'path';

type CommandAndPrompt = {
  command: string,
  prompt?: string
};

export class CodespacePage {
  readonly page: Page;
  readonly outputPanel: Locator;
  readonly terminal: Locator;

  constructor(page: Page) {
    this.page = page;
    this.outputPanel = page.locator('[id="workbench.panel.output"]');
    this.terminal = page.locator('.terminal-widget-container').first();
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
   * **Usage**
   *
   * ```ts
   * const codespace = new CodespacePage(page);
   * await codespace.areExtensionsActive(['SonarLint', 'CMake', 'Live Share', 'GitHub Pull Requests']);
   * ```
   *
   * @param extensions - The list of extensions to wait for.
   */
  async areExtensionsActive(extensions: string[]) {
    for (const plugin of extensions) {
      await expect(this.page.getByRole('tab', { name: plugin, exact: true }).locator('a')).toBeVisible({ timeout: 30 * 1000 });
    }

    await expect(this.page.getByRole('button', { name: 'Activating Extensions...' })).toBeHidden();
  }

  /**
   * Executes the given commands in the command palette.
   *
   * This method waits for `prompt` to appear and then types `command` and presses Enter.
   * When no prompt is given the default prompt is used.
   *
   * @param commands - The commands to execute in the command palette. It can be a single command or an array of commands.
   */
  async executeFromCommandPalette(commands: CommandAndPrompt | CommandAndPrompt[]) {
    await this.page.keyboard.press('Control+Shift+P');
    let commandPrompt = '> ';

    for (const command of Array.isArray(commands) ? commands : [commands]) {
      let prompt = this.page.getByPlaceholder(command.prompt || 'Type the name of a command to run');

      await expect(prompt).toBeVisible();
      await prompt.fill(`${commandPrompt}${command.command}`);
      await prompt.press('Enter');
      await expect(prompt).toBeHidden();

      commandPrompt = '';
    }

    // While waiting is an anti-pattern, it is necessary to wait for the command to be executed.
    await this.page.waitForTimeout(500);
  }

  /**
   * Executes the given commands in the terminal.
   *
   * **Usage**
   *
   * ```ts
   * const codespace = new CodespacePage(page);
   * await codespace.executeInTerminal('git clean -fdx');
   * ```
   *
   * @param commands - The commands to execute in the terminal. It can be a single command or an array of commands.
   */
  async executeInTerminal(commands: string | string[]) {
    await this.executeFromCommandPalette({ command: 'Terminal: Focus on Terminal View' });
    await expect(this.page.locator('.terminal-widget-container')).toBeVisible();

    for (const command of Array.isArray(commands) ? commands : [commands]) {
      await this.terminal.pressSequentially(command);
      await this.terminal.press('Enter');

      // While waiting is an anti-pattern, it is necessary to wait for the command to be executed
      // especially when running multiple commands in sequence.
      await this.page.waitForTimeout(250);
    }
  }

  async clearAllNotifications() {
    await this.executeFromCommandPalette({ command: 'Notifications: Clear All Notifications' });
  }

  async killAllTerminals() {
    await this.executeFromCommandPalette({ command: 'Terminal: Kill All Terminals' });
  }

  /**
   * Opens the tab with the given name.
   *
   * @param name - The name of the tab to open.
   */
  async openTabByName(name: string) {
    await this.page.getByRole('tab', { name: name }).locator('a').click();
  }

  async openFileInEditor(name: string) {
    await this.executeInTerminal(`code -r ${name}`);
    await expect(this.page.locator('[id="workbench.parts.editor"]')).toContainText(path.basename(name));
  }

  async openCppFileInEditor(name: string) {
    await this.openFileInEditor(name);
    await expect(this.page.locator('[id="llvm-vs-code-extensions.vscode-clangd"]')).toContainText('clangd: idle', { timeout: 1 * 60 * 1000 });
  }

  async openDocument(name: string) {
    const fileExtension = path.extname(name).slice(1);

    if (fileExtension === 'cpp') {
      await this.openCppFileInEditor(name);
    } else {
      await this.openFileInEditor(name);
    }
  }

  async saveDocument() {
    await this.page.keyboard.press('Control+S');
  }

  async formatDocument() {
    await this.executeFromCommandPalette({ command: 'Format Document' });
  }

  async selectBuildConfiguration(configuration: string) {
    await this.executeFromCommandPalette([
      { command: 'CMake: Select Configure Preset' },
      { command: configuration, prompt: 'Select a configure preset' }
    ]);
  }

  async selectBuildPreset(preset: string) {
    await this.executeFromCommandPalette([
      { command: 'CMake: Select Build Preset' },
      { command: preset, prompt: 'Select a build preset' }
    ]);
  }

  async buildSelectedTarget() {
    await this.page.getByRole('button', { name: 'Build the selected target' }).click();
  }

  async expectEditorContent(expected: RegExp) {
    await expect(this.page.getByRole('code')).toContainText(expected);
  }

  async expectOutputToContain(expectedOutput: string) {
    await expect(this.outputPanel).toContainText(expectedOutput, { timeout: 5 * 60 * 1000 });
  }

  async expectFileContentsToMatch(actual: string, expected: string) {
    await this.executeInTerminal(`diff -s ${actual} ${expected}`);
    await expect(this.page.locator('#terminal')).toContainText(`Files ${actual} and ${expected} are identical`);
  }
}
