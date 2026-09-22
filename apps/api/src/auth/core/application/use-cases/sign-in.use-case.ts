import { Injectable } from "@nestjs/common";

import type { RawAuthResponse } from "@/auth/core/application/port/session-method.repository.js";
import { SessionMethodRepository } from "@/auth/core/application/port/session-method.repository.js";
import type { SignInQuery } from "@/auth/core/domain/value-objects/auth-queries.vo.js";

@Injectable()
export class SignInUseCase {
  constructor(private readonly sessionMethodRepository: SessionMethodRepository) {}

  execute(query: SignInQuery): Promise<RawAuthResponse> {
    return this.sessionMethodRepository.signIn(query);
  }
}
