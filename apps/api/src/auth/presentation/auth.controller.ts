import { Body, Controller, Get, Post, Req, Res } from "@nestjs/common";
import { OptionalAuth } from "@thallesp/nestjs-better-auth";
import type { Request as ExpressRequest, Response as ExpressResponse } from "express";

import { GetSessionUseCase } from "@/auth/core/application/use-cases/get-session.use-case.js";
import { SignInUseCase } from "@/auth/core/application/use-cases/sign-in.use-case.js";
import { SignOutUseCase } from "@/auth/core/application/use-cases/sign-out.use-case.js";
import { SignUpUseCase } from "@/auth/core/application/use-cases/sign-up.use-case.js";
import {
  signInQuerySchema,
  signUpQuerySchema,
  type SignInQuery,
  type SignUpQuery,
} from "@/auth/core/domain/value-objects/auth-queries.vo.js";
import { forwardRawResponse } from "@/common/http/forward-raw-response.js";
import { toFetchHeaders } from "@/common/http/to-fetch-headers.js";
import { ZodValidationPipe } from "@/common/http/zod-validation.pipe.js";

@OptionalAuth()
@Controller("auth")
export class AuthController {
  constructor(
    private readonly signUpUseCase: SignUpUseCase,
    private readonly signInUseCase: SignInUseCase,
    private readonly signOutUseCase: SignOutUseCase,
    private readonly getSessionUseCase: GetSessionUseCase,
  ) {}

  @Post("sign-up")
  async signUp(
    @Body(new ZodValidationPipe(signUpQuerySchema)) query: SignUpQuery,
    @Res() res: ExpressResponse,
  ): Promise<void> {
    forwardRawResponse(res, await this.signUpUseCase.execute(query));
  }

  @Post("sign-in/email")
  async signIn(
    @Body(new ZodValidationPipe(signInQuerySchema)) query: SignInQuery,
    @Res() res: ExpressResponse,
  ): Promise<void> {
    forwardRawResponse(res, await this.signInUseCase.execute(query));
  }

  @Post("sign-out")
  async signOut(@Req() req: ExpressRequest, @Res() res: ExpressResponse): Promise<void> {
    forwardRawResponse(res, await this.signOutUseCase.execute(toFetchHeaders(req)));
  }

  @Get("session")
  async session(@Req() req: ExpressRequest) {
    return this.getSessionUseCase.execute(toFetchHeaders(req));
  }
}
