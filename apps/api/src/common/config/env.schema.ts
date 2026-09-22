import { z } from "zod";

const envSchema = z
  .object({
    DATABASE_URL: z.string().min(1),
    BETTER_AUTH_SECRET: z.string().min(1),
    BETTER_AUTH_URL: z.string().min(1),
    CLIENT_URL: z.string().min(1),
    COOKIE_DOMAIN: z.string().optional(),
  })
  .loose();

export function validateEnv(config: Record<string, unknown>): Record<string, unknown> {
  const result = envSchema.safeParse(config);

  if (!result.success) {
    const missing = result.error.issues.map((issue) => issue.path.join(".")).join(", ");
    throw new Error(`Missing or invalid required environment variables: ${missing}`);
  }

  return result.data;
}
