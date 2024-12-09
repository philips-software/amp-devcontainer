import { AuthenticationPage } from '../pages/authentication.pom';
import { CodespacePage } from '../pages/codespace.pom';
import { test as base, createBdd } from 'playwright-bdd';

export const test = base.extend<{ codespacePage: CodespacePage }, { authenticationPage: AuthenticationPage }>({
    authenticationPage: [async ({ browser }, use) => {
        let authenticationPage = new AuthenticationPage(await browser.newPage());
        await authenticationPage.authenticate();

        await use(authenticationPage);
      }, { scope: 'worker', auto: true }
    ],
    codespacePage: async ({ page }, use) => {
        const codespacePage = new CodespacePage(page);
        await codespacePage.goto();
        await codespacePage.areExtensionsActive(['Testing', 'SonarQube', 'CMake', 'Live Share', 'GitHub Pull Requests']);

        await use(codespacePage);

        await codespacePage.executeInTerminal('git clean -fdx');
    },
});

export const { Given, When, Then } = createBdd(test);
