import { execFileSync } from "node:child_process";

const status = execFileSync("git", ["status", "--porcelain", "--", "platforms/swift"]).toString();

if (status.trim() !== "") {
  process.stderr.write(
    [
      "Generated Swift tokens are out of date.",
      "Run `pnpm --filter @repo/design-tokens build` and commit the result.",
      "",
      status,
    ].join("\n"),
  );
  process.exit(1);
}
