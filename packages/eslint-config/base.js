import { createRequire } from "node:module";

import babelParser from "@babel/eslint-parser";
import js from "@eslint/js";
import eslintConfigPrettier from "eslint-config-prettier";
import turboPlugin from "eslint-plugin-turbo";
import onlyWarn from "eslint-plugin-only-warn";
import globals from "globals";

// Les presets Babel sont resolus depuis les `node_modules` du fichier linte,
// pas depuis ceux de ce package. Sous pnpm, `apps/api` n'a aucun acces a
// `@babel/preset-typescript` : on passe donc un chemin absolu.
export const typescriptPreset = createRequire(import.meta.url).resolve("@babel/preset-typescript");

/**
 * A shared ESLint configuration for the repository.
 *
 * @type {import("eslint").Linter.Config[]}
 * */
export const config = [
  js.configs.recommended,
  eslintConfigPrettier,
  {
    // Sans ce `files`, ESLint ne cible que .js/.mjs/.cjs : tout le TypeScript
    // du repo passerait sous le radar du lint.
    files: ["**/*.{js,mjs,cjs,jsx,ts,tsx,mts,cts}"],
    languageOptions: {
      parser: babelParser,
      parserOptions: {
        requireConfigFile: false,
        babelOptions: {
          presets: [typescriptPreset],
        },
      },
      globals: {
        ...globals.node,
      },
    },
    plugins: {
      turbo: turboPlugin,
    },
    rules: {
      "turbo/no-undeclared-env-vars": "warn",
    },
  },
  {
    // Le parser babel ne connaît pas le système de types : les annotations et les
    // `import type` lui apparaissent comme des identifiants inconnus ou inutilisés.
    // Ces deux vérifications appartiennent à tsc, qui les fait correctement
    // (`strict`, `noUnusedLocals`, `noUnusedParameters` dans @repo/typescript-config).
    files: ["**/*.{ts,tsx,mts,cts}"],
    rules: {
      "no-undef": "off",
      "no-unused-vars": "off",
    },
  },
  {
    rules: {
      "no-restricted-imports": ["error", { patterns: ["../../*", "node_modules/*"] }],
    },
  },
  {
    plugins: {
      onlyWarn,
    },
  },
  {
    ignores: ["dist/**", "build/**", "**/platforms/**"],
  },
];
