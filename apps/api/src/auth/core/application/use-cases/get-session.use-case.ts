import { Injectable } from "@nestjs/common";

import type { SessionSnapshot } from "@/auth/core/application/port/session-method.repository.js";
import { SessionMethodRepository } from "@/auth/core/application/port/session-method.repository.js";

@Injectable()
export class GetSessionUseCase {
  constructor(private readonly sessionMethodRepository: SessionMethodRepository) {}

  execute(headers: Headers): Promise<SessionSnapshot> {
    return this.sessionMethodRepository.getSession(headers);
  }
}
