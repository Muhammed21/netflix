import { Injectable } from "@nestjs/common";

import type { RawAuthResponse } from "@/auth/core/application/port/session-method.repository.js";
import { SessionMethodRepository } from "@/auth/core/application/port/session-method.repository.js";
import type { SignUpQuery } from "@/auth/core/domain/value-objects/auth-queries.vo.js";

@Injectable()
export class SignUpUseCase {
  constructor(private readonly sessionMethodRepository: SessionMethodRepository) {}

  execute(query: SignUpQuery): Promise<RawAuthResponse> {
    return this.sessionMethodRepository.signUp(query);
  }
}
