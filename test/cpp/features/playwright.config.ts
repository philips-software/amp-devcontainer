import { defineConfig, devices } from '@playwright/test';
import { defineBddConfig } from "playwright-bdd";
import path from 'path';

require('dotenv').config({ path: path.join(__dirname, '..', '..', '..', '.env') });

export const STORAGE_STATE = path.join(__dirname, 'playwright/.auth/user.json');

const testDir = defineBddConfig({
  features: "*.feature",
  steps: ["steps/*.ts"],
});

export default defineConfig({
  testDir,
  fullyParallel: false,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: 1,
  reporter: 'list',
  use: {
    trace: 'on-first-retry'
  },
  projects: [
    {
      name: 'chromium',
      use: {
        ...devices['Desktop Chrome'],
        storageState: STORAGE_STATE
      }
    }
  ]
});
