import type { Format, TransformedToken } from "style-dictionary/types";

import { formatColors, formatDimensions, formatTextStyles, type DesignToken } from "./swift.ts";

const toDesignToken = (token: TransformedToken): DesignToken => ({
  path: token.path,
  $type: (token.$type ?? token.type ?? "unknown") as string,
  value: token.$value ?? token.value,
  comment: (token.$description ?? token.comment) as string | undefined,
});

export const swiftColorFormat: Format = {
  name: "swift/colors",
  format: ({ dictionary }) => formatColors(dictionary.allTokens.map(toDesignToken)),
};

export const swiftDimensionFormat: Format = {
  name: "swift/dimensions",
  format: ({ dictionary, options }) =>
    formatDimensions(dictionary.allTokens.map(toDesignToken), {
      namespace: String(options["namespace"]),
    }),
};

export const swiftTextStyleFormat: Format = {
  name: "swift/text-styles",
  format: ({ dictionary }) => formatTextStyles(dictionary.allTokens.map(toDesignToken)),
};

export const swiftFormats = [swiftColorFormat, swiftDimensionFormat, swiftTextStyleFormat];
