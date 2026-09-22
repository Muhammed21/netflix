-- CreateEnum
CREATE TYPE "AvatarStyle" AS ENUM ('BLUE', 'YELLOW', 'RED', 'KIDS');

-- CreateTable
CREATE TABLE "profile" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "avatar" "AvatarStyle" NOT NULL,
    "isKids" BOOLEAN NOT NULL DEFAULT false,
    "position" INTEGER NOT NULL,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "profile_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "profile_userId_idx" ON "profile"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "profile_userId_position_key" ON "profile"("userId", "position");

-- AddForeignKey
ALTER TABLE "profile" ADD CONSTRAINT "profile_userId_fkey" FOREIGN KEY ("userId") REFERENCES "user"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- Backfill : les comptes créés avant cette migration n'ont aucun profil et
-- resteraient bloqués sur un écran de sélection vide. On leur pose le même jeu
-- par défaut que celui créé à l'inscription.
INSERT INTO "profile" ("id", "userId", "name", "avatar", "isKids", "position", "createdAt")
SELECT
  gen_random_uuid()::text,
  u."id",
  d."name",
  d."avatar"::"AvatarStyle",
  d."isKids",
  d."position",
  NOW()
FROM "user" u
CROSS JOIN (
  VALUES
    ('Profil 1', 'BLUE',   false, 0),
    ('Profil 2', 'YELLOW', false, 1),
    ('Profil 3', 'RED',    false, 2),
    ('Enfants',  'KIDS',   true,  3)
) AS d("name", "avatar", "isKids", "position")
WHERE NOT EXISTS (SELECT 1 FROM "profile" p WHERE p."userId" = u."id");
