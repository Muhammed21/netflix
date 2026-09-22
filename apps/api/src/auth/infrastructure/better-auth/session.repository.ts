import { Injectable } from "@nestjs/common";
import { AuthService } from "@thallesp/nestjs-better-auth";

import type {
  RawAuthResponse,
  SessionSnapshot,
} from "@/auth/core/application/port/session-method.repository.js";
import { SessionMethodRepository } from "@/auth/core/application/port/session-method.repository.js";
import type { SignInQuery, SignUpQuery } from "@/auth/core/domain/value-objects/auth-queries.vo.js";
import type { Auth } from "./auth.js";

const toRawAuthResponse = async (response: Response): Promise<RawAuthResponse> => ({
  status: response.status,
  headers: response.headers,
  body: await response.arrayBuffer(),
});

@Injectable()
export class SessionRepository extends SessionMethodRepository {
  constructor(private readonly authService: AuthService<Auth>) {
    super();
  }

  async signUp(query: SignUpQuery): Promise<RawAuthResponse> {
    const response = await this.authService.api.signUpEmail({
      body: query,
      asResponse: true,
    });

    return toRawAuthResponse(response);
  }

  async signIn(query: SignInQuery): Promise<RawAuthResponse> {
    const response = await this.authService.api.signInEmail({
      body: query,
      asResponse: true,
    });

    return toRawAuthResponse(response);
  }

  async signOut(headers: Headers): Promise<RawAuthResponse> {
    const response = await this.authService.api.signOut({
      headers,
      asResponse: true,
    });

    return toRawAuthResponse(response);
  }

  async getSession(headers: Headers): Promise<SessionSnapshot> {
    try {
      return (await this.authService.api.getSession({ headers })) as SessionSnapshot;
    } catch {
      return null;
    }
  }
}
