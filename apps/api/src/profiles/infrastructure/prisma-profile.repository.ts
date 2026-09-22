import { Injectable } from "@nestjs/common";

import { PrismaService } from "@db/prisma.service.js";
import { ProfileRepository } from "@/profiles/core/application/port/profile.repository.js";
import type { Profile } from "@/profiles/core/domain/profile.entity.js";

@Injectable()
export class PrismaProfileRepository extends ProfileRepository {
  constructor(private readonly prisma: PrismaService) {
    super();
  }

  async findByUserId(userId: string): Promise<Profile[]> {
    const rows = await this.prisma.profile.findMany({
      where: { userId },
      orderBy: { position: "asc" },
    });

    return rows.map((row) => ({
      id: row.id,
      name: row.name,
      avatar: row.avatar,
      isKids: row.isKids,
      position: row.position,
    }));
  }
}
