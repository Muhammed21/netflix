import StyleDictionary from "style-dictionary";

import config from "../style-dictionary.config.ts";
import { swiftFormats } from "../src/formats/style-dictionary.ts";

for (const format of swiftFormats) {
  StyleDictionary.registerFormat(format);
}

const dictionary = new StyleDictionary(config);

await dictionary.buildAllPlatforms();
