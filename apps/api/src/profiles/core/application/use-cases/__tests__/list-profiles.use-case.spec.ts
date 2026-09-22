import { describe, expect, it, vi } from "vitest";

import type { Profile } from "@/profiles/core/domain/profile.entity.js";
import { ProfileRepository } from "@/profiles/core/application/port/profile.repository.js";
import { ListProfilesUseCase } from "../list-profiles.use-case.js";

const profile = (overrides: Partial<Profile> = {}): Profile => ({
  id: "p1",
  name: "Profil 1",
  avatar: "BLUE",
  isKids: false,
  position: 0,
  ...overrides,
});

const stubRepository = (profiles: Profile[]) =>
  ({ findByUserId: vi.fn().mockResolvedValue(profiles) }) as unknown as ProfileRepository;

describe("ListProfilesUseCase", () => {
  it("asks the repository for the profiles of the signed-in user only", async () => {
    const repository = stubRepository([profile()]);

    await new ListProfilesUseCase(repository).execute("user-42");

    expect(repository.findByUserId).toHaveBeenCalledWith("user-42");
  });

  it("returns the profiles it was given", async () => {
    const profiles = [
      profile(),
      profile({ id: "p2", name: "Enfants", avatar: "KIDS", isKids: true, position: 1 }),
    ];

    const result = await new ListProfilesUseCase(stubRepository(profiles)).execute("user-42");

    expect(result).toEqual(profiles);
  });

  it("returns an empty list rather than throwing when the user has no profile", async () => {
    const result = await new ListProfilesUseCase(stubRepository([])).execute("user-42");

    expect(result).toEqual([]);
  });

  it("orders the profiles by position, so the grid never shuffles between calls", async () => {
    const unordered = [
      profile({ id: "c", position: 2 }),
      profile({ id: "a", position: 0 }),
      profile({ id: "b", position: 1 }),
    ];

    const result = await new ListProfilesUseCase(stubRepository(unordered)).execute("user-42");

    expect(result.map((p) => p.id)).toEqual(["a", "b", "c"]);
  });
});
