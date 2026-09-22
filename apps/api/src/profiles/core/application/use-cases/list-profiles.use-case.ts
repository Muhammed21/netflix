import { Injectable } from "@nestjs/common";

import { ProfileRepository } from "@/profiles/core/application/port/profile.repository.js";
import type { Profile } from "@/profiles/core/domain/profile.entity.js";

@Injectable()
export class ListProfilesUseCase {
  constructor(private readonly profileRepository: ProfileRepository) {}

  async execute(userId: string): Promise<Profile[]> {
    const profiles = await this.profileRepository.findByUserId(userId);

    // Le tri appartient au domaine, pas à la couche de stockage : c'est lui qui
    // garantit que la grille de profils ne change pas d'ordre d'un appel à
    // l'autre, quelle que soit l'implémentation du dépôt.
    return [...profiles].sort((a, b) => a.position - b.position);
  }
}
