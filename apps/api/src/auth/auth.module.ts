import { Module } from "@nestjs/common";
import { AuthModule } from "@thallesp/nestjs-better-auth";

import { PrismaModule } from "@db/prisma.module.js";
import { PrismaService } from "@db/prisma.service.js";
import { SessionMethodRepository } from "@/auth/core/application/port/session-method.repository.js";
import { GetSessionUseCase } from "@/auth/core/application/use-cases/get-session.use-case.js";
import { SignInUseCase } from "@/auth/core/application/use-cases/sign-in.use-case.js";
import { SignOutUseCase } from "@/auth/core/application/use-cases/sign-out.use-case.js";
import { SignUpUseCase } from "@/auth/core/application/use-cases/sign-up.use-case.js";
import { createAuth } from "@/auth/infrastructure/better-auth/auth.js";
import { SessionRepository } from "@/auth/infrastructure/better-auth/session.repository.js";
import { AuthController } from "@/auth/presentation/auth.controller.js";

@Module({
  imports: [
    PrismaModule,
    AuthModule.forRootAsync({
      imports: [PrismaModule],
      inject: [PrismaService],
      useFactory: (prisma: PrismaService) => ({ auth: createAuth(prisma) }),
    }),
  ],
  controllers: [AuthController],
  providers: [
    { provide: SessionMethodRepository, useClass: SessionRepository },
    SignUpUseCase,
    SignInUseCase,
    SignOutUseCase,
    GetSessionUseCase,
  ],
})
export class AuthenticationModule {}
