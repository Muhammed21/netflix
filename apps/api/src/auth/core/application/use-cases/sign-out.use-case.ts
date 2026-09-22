import { Injectable } from "@nestjs/common";

import type { RawAuthResponse } from "@/auth/core/application/port/session-method.repository.js";
import { SessionMethodRepository } from "@/auth/core/application/port/session-method.repository.js";

@Injectable()
export class SignOutUseCase {
  constructor(private readonly sessionMethodRepository: SessionMethodRepository) {}

  execute(headers: Headers): Promise<RawAuthResponse> {
    return this.sessionMethodRepository.signOut(headers);
  }
}
