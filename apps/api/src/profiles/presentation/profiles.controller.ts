import { Controller, Get } from "@nestjs/common";
import { Session, type UserSession } from "@thallesp/nestjs-better-auth";

import { ListProfilesUseCase } from "@/profiles/core/application/use-cases/list-profiles.use-case.js";
import type { Profile } from "@/profiles/core/domain/profile.entity.js";

/// Aucun décorateur @OptionalAuth ici, volontairement : le garde global de
/// @thallesp/nestjs-better-auth protège la route par défaut, et un appel sans
/// session doit être refusé.
@Controller("profiles")
export class ProfilesController {
  constructor(private readonly listProfilesUseCase: ListProfilesUseCase) {}

  @Get()
  list(@Session() session: UserSession): Promise<Profile[]> {
    return this.listProfilesUseCase.execute(session.user.id);
  }
}
