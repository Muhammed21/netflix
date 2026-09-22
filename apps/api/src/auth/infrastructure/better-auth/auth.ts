import { prismaAdapter } from "@better-auth/prisma-adapter";
import { betterAuth, type BetterAuthOptions } from "better-auth";

import { PrismaService } from "@db/prisma.service.js";

const DEFAULT_PROFILES = [
  { name: "Profil 1", avatar: "BLUE", isKids: false, position: 0 },
  { name: "Profil 2", avatar: "YELLOW", isKids: false, position: 1 },
  { name: "Profil 3", avatar: "RED", isKids: false, position: 2 },
  { name: "Enfants", avatar: "KIDS", isKids: true, position: 3 },
] as const;

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
    databaseHooks: {
      user: {
        create: {
          // Un compte sans profil arriverait sur une grille vide : le jeu par
          // défaut est créé au même moment que l'utilisateur. Les comptes
          // antérieurs ont été rattrapés par la migration `profiles`.
          after: async (user) => {
            await prisma.profile.createMany({
              data: DEFAULT_PROFILES.map((profile) => ({ ...profile, userId: user.id })),
            });
          },
        },
      },
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
