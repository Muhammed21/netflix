import type { Config, TransformedToken } from "style-dictionary/types";

const SWIFT_SOURCES = "platforms/swift/Sources/DesignTokens/";

const isSemantic = (token: TransformedToken): boolean => token.path[0] !== "core";

const category =
  (name: string) =>
  (token: TransformedToken): boolean =>
    isSemantic(token) && token.path[0] === name;

export const config: Config = {
  source: ["tokens/**/*.json"],
  preprocessors: ["tokens-studio-safe"],
  platforms: {
    swift: {
      transforms: ["attribute/cti", "name/camel"],
      buildPath: SWIFT_SOURCES,
      files: [
        {
          destination: "Color+Tokens.swift",
          format: "swift/colors",
          filter: category("color"),
        },
        {
          destination: "Spacing+Tokens.swift",
          format: "swift/dimensions",
          filter: category("spacing"),
          options: { namespace: "Spacing" },
        },
        {
          destination: "Radius+Tokens.swift",
          format: "swift/dimensions",
          filter: category("radius"),
          options: { namespace: "Radius" },
        },
        {
          destination: "Typography+Tokens.swift",
          format: "swift/text-styles",
          filter: category("typography"),
        },
      ],
    },
  },
};

export default config;
