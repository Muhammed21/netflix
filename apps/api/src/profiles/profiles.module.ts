import { Module } from "@nestjs/common";

import { PrismaModule } from "@db/prisma.module.js";
import { ProfileRepository } from "@/profiles/core/application/port/profile.repository.js";
import { ListProfilesUseCase } from "@/profiles/core/application/use-cases/list-profiles.use-case.js";
import { PrismaProfileRepository } from "@/profiles/infrastructure/prisma-profile.repository.js";
import { ProfilesController } from "@/profiles/presentation/profiles.controller.js";

@Module({
  imports: [PrismaModule],
  controllers: [ProfilesController],
  providers: [
    { provide: ProfileRepository, useClass: PrismaProfileRepository },
    ListProfilesUseCase,
  ],
})
export class ProfilesModule {}
