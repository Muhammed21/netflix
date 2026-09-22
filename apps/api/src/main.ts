import { NestFactory } from "@nestjs/core";
import { NestExpressApplication } from "@nestjs/platform-express";
import helmet from "helmet";

import { AppModule } from "./app.module.js";

async function bootstrap() {
  // `bodyParser: false` est indispensable : @thallesp/nestjs-better-auth
  // réinstalle lui-même le parsing pour les routes non-auth, et le handler
  // better-auth a besoin d'un corps de requête encore intact.
  const app = await NestFactory.create<NestExpressApplication>(AppModule, {
    bodyParser: false,
  });

  app.enableShutdownHooks();
  app.use(helmet({ crossOriginResourcePolicy: { policy: "cross-origin" } }));

  app.enableCors({
    origin: [process.env.CLIENT_URL || "http://localhost:3000"],
    credentials: true,
    methods: ["GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"],
    allowedHeaders: ["Content-Type", "Authorization", "Cookie"],
    exposedHeaders: ["Set-Cookie"],
  });

  await app.listen(process.env.PORT ?? 3001);
}
await bootstrap();
