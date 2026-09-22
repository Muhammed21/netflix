import { existsSync } from "node:fs";
import path from "node:path";
import { defineConfig, env } from "prisma/config";

const envPath = path.join(import.meta.dirname, ".env");
if (existsSync(envPath)) {
  process.loadEnvFile(envPath);
}

export default defineConfig({
  schema: "prisma/schema.prisma",
  datasource: {
    url: env("DATABASE_URL"),
  },
});
