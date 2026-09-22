import { describe, expect, it } from "vitest";

import { signInQuerySchema, signUpQuerySchema } from "../auth-queries.vo.js";

const validSignUp = { email: "viewer@netflix.test", password: "motdepasse8", name: "Viewer" };

describe("signUpQuerySchema", () => {
  it("accepts a well-formed sign-up", () => {
    expect(signUpQuerySchema.parse(validSignUp)).toEqual(validSignUp);
  });

  it("rejects a malformed email", () => {
    const result = signUpQuerySchema.safeParse({ ...validSignUp, email: "pas-un-email" });

    expect(result.success).toBe(false);
  });

  it("rejects a password shorter than 8 characters", () => {
    const result = signUpQuerySchema.safeParse({ ...validSignUp, password: "court7c" });

    expect(result.success).toBe(false);
  });

  it("accepts a password of exactly 8 characters", () => {
    const result = signUpQuerySchema.safeParse({ ...validSignUp, password: "12345678" });

    expect(result.success).toBe(true);
  });

  it("rejects an empty name", () => {
    const result = signUpQuerySchema.safeParse({ ...validSignUp, name: "" });

    expect(result.success).toBe(false);
  });

  it("strips unexpected fields so they never reach better-auth", () => {
    const parsed = signUpQuerySchema.parse({ ...validSignUp, role: "admin" });

    expect(parsed).not.toHaveProperty("role");
  });
});

describe("signInQuerySchema", () => {
  it("accepts an email and a password", () => {
    const parsed = signInQuerySchema.parse({
      email: "viewer@netflix.test",
      password: "peu importe",
    });

    expect(parsed.email).toBe("viewer@netflix.test");
  });

  it("rejects a malformed email", () => {
    expect(signInQuerySchema.safeParse({ email: "nope", password: "motdepasse8" }).success).toBe(
      false,
    );
  });

  it("does not impose a minimum length on sign-in, so existing accounts stay reachable", () => {
    expect(signInQuerySchema.safeParse({ email: "a@b.co", password: "x" }).success).toBe(true);
  });

  it("rejects a missing password", () => {
    expect(signInQuerySchema.safeParse({ email: "a@b.co" }).success).toBe(false);
  });
});
