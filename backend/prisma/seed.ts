import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

async function main() {
  const h1 = await prisma.hotel.create({
    data: {
      name: "Hotel One",
      rooms: {
        create: [
          { name: "101" },
          { name: "102" }
        ]
      }
    }
  });

  const h2 = await prisma.hotel.create({
    data: {
      name: "Hotel Two",
      rooms: {
        create: [
          { name: "201" },
          { name: "202" }
        ]
      }
    }
  });

  const room = await prisma.room.findFirst();

  if (room) {
    await prisma.booking.create({
      data: {
        roomId: room.id,
        startDate: new Date("2026-03-01"),
        endDate: new Date("2026-03-05")
      }
    });
  }

  console.log("Seed done");
}

main().finally(() => prisma.$disconnect());