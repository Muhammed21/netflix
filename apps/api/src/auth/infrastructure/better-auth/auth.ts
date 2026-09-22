import { prismaAdapter } from "@better-auth/prisma-adapter";
import { betterAuth, type BetterAuthOptions } from "better-auth";

import { PrismaService } from "@db/prisma.service.js";

const buildAuthOptions = (prisma: PrismaService): BetterAuthOptions =>
  ({
    baseURL: process.env.BETTER_AUTH_URL,
    secret: process.env.BETTER_AUTH_SECRET,
    database: prismaAdapter(prisma, {
      provider: "postgresql",
    }),
    emailAndPassword: {
      enabled: true,
    },
    session: {
      cookieCache: {
        enabled: true,
        maxAge: 3 * 30 * 24 * 60 * 60,
      },
      expiresIn: 60 * 60 * 24 * 30,
      updateAge: 60 * 60 * 24,
    },
    advanced: {
      cookiePrefix: "better-auth",
      useSecureCookies: process.env.NODE_ENV === "production",
      crossSubDomainCookies: {
        enabled: process.env.NODE_ENV === "production",
        domain: process.env.COOKIE_DOMAIN,
      },
      defaultCookieAttributes: {
        sameSite: "lax",
        httpOnly: true,
        secure: process.env.NODE_ENV === "production",
        path: "/",
      },
    },
    rateLimit: {
      window: 15 * 60,
      max: 100,
      customRules: {
        "/sign-in/email": { window: 60, max: 5 },
        "/sign-up/email": { window: 60, max: 3 },
      },
    },
    trustedOrigins: [process.env.CLIENT_URL || "http://localhost:3000"],
  }) satisfies BetterAuthOptions;

export const createAuth = (prisma: PrismaService): ReturnType<typeof betterAuth> =>
  betterAuth(buildAuthOptions(prisma));

export type Auth = ReturnType<typeof createAuth>;
