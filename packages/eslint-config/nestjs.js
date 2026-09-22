import { config as baseConfig, typescriptPreset } from "./base.js";

/**
 * Configuration ESLint pour les applications NestJS.
 *
 * Le parser babel du config de base ne sait pas lire les décorateurs ; sans ce
 * plugin, chaque `@Injectable()` ou `@Controller()` devient une erreur de parsing.
 * NestJS s'appuie sur les décorateurs historiques (`experimentalDecorators`),
 * d'où `decorators-legacy` plutôt que la proposition en cours de normalisation.
 *
 * @type {import("eslint").Linter.Config[]}
 * */
export const config = [
  ...baseConfig,
  {
    files: ["**/*.{ts,tsx,mts,cts}"],
    languageOptions: {
      parserOptions: {
        babelOptions: {
          presets: [typescriptPreset],
          parserOpts: {
            plugins: ["decorators-legacy"],
          },
        },
      },
    },
  },
];
