import type { SignInQuery, SignUpQuery } from "@/auth/core/domain/value-objects/auth-queries.vo.js";

export type RawAuthResponse = {
  status: number;
  headers: Headers;
  body: ArrayBuffer;
};

export type SessionSnapshot = {
  user: { id: string; email: string; name: string };
  session: { id: string; expiresAt: Date };
} | null;

export abstract class SessionMethodRepository {
  abstract signUp(query: SignUpQuery): Promise<RawAuthResponse>;
  abstract signIn(query: SignInQuery): Promise<RawAuthResponse>;
  abstract signOut(headers: Headers): Promise<RawAuthResponse>;
  abstract getSession(headers: Headers): Promise<SessionSnapshot>;
}
