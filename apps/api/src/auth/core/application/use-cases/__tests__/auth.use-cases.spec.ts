import { describe, expect, it, vi } from "vitest";

import type {
  RawAuthResponse,
  SessionSnapshot,
} from "@/auth/core/application/port/session-method.repository.js";
import { SessionMethodRepository } from "@/auth/core/application/port/session-method.repository.js";
import { GetSessionUseCase } from "../get-session.use-case.js";
import { SignInUseCase } from "../sign-in.use-case.js";
import { SignOutUseCase } from "../sign-out.use-case.js";
import { SignUpUseCase } from "../sign-up.use-case.js";

const rawResponse = (status = 200): RawAuthResponse => ({
  status,
  headers: new Headers(),
  body: new ArrayBuffer(0),
});

const session: SessionSnapshot = {
  user: { id: "u1", email: "viewer@netflix.test", name: "Viewer" },
  session: { id: "s1", expiresAt: new Date("2026-12-01T00:00:00Z") },
};

const stubRepository = (overrides: Partial<SessionMethodRepository> = {}) =>
  ({
    signUp: vi.fn().mockResolvedValue(rawResponse(201)),
    signIn: vi.fn().mockResolvedValue(rawResponse()),
    signOut: vi.fn().mockResolvedValue(rawResponse()),
    getSession: vi.fn().mockResolvedValue(session),
    ...overrides,
  }) as unknown as SessionMethodRepository;

describe("SignUpUseCase", () => {
  it("passes the query through to the repository", async () => {
    const repository = stubRepository();
    const query = { email: "viewer@netflix.test", password: "motdepasse8", name: "Viewer" };

    await new SignUpUseCase(repository).execute(query);

    expect(repository.signUp).toHaveBeenCalledWith(query);
  });

  it("returns the raw response so cookies survive", async () => {
    const repository = stubRepository();

    const result = await new SignUpUseCase(repository).execute({
      email: "viewer@netflix.test",
      password: "motdepasse8",
      name: "Viewer",
    });

    expect(result.status).toBe(201);
  });
});

describe("SignInUseCase", () => {
  it("passes the query through to the repository", async () => {
    const repository = stubRepository();
    const query = { email: "viewer@netflix.test", password: "motdepasse8" };

    await new SignInUseCase(repository).execute(query);

    expect(repository.signIn).toHaveBeenCalledWith(query);
  });
});

describe("SignOutUseCase", () => {
  it("forwards the request headers so the session can be identified", async () => {
    const repository = stubRepository();
    const headers = new Headers({ cookie: "better-auth.session_token=abc" });

    await new SignOutUseCase(repository).execute(headers);

    expect(repository.signOut).toHaveBeenCalledWith(headers);
  });
});

describe("GetSessionUseCase", () => {
  it("returns the session when one exists", async () => {
    const result = await new GetSessionUseCase(stubRepository()).execute(new Headers());

    expect(result).toEqual(session);
  });

  it("returns null rather than throwing when there is no session", async () => {
    const repository = stubRepository({
      getSession: vi.fn().mockResolvedValue(null),
    } as Partial<SessionMethodRepository>);

    const result = await new GetSessionUseCase(repository).execute(new Headers());

    expect(result).toBeNull();
  });
});
