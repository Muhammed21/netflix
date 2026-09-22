import type { Profile } from "@/profiles/core/domain/profile.entity.js";

export abstract class ProfileRepository {
  abstract findByUserId(userId: string): Promise<Profile[]>;
}
