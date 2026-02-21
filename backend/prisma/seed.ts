import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

async function main() {
  console.log("🌱 Starting seed...");

  // Создаем отели с номерами
  const h1 = await prisma.hotel.create({
    data: {
      name: "Grand Plaza Hotel",
      rooms: {
        create: [
          { name: "101 - Standard Room" },
          { name: "102 - Deluxe Room" },
          { name: "103 - Suite" }
        ]
      }
    },
    include: { rooms: true }
  });

  const h2 = await prisma.hotel.create({
    data: {
      name: "Ocean View Resort",
      rooms: {
        create: [
          { name: "201 - Beach View" },
          { name: "202 - Ocean Suite" },
          { name: "203 - Presidential Suite" }
        ]
      }
    },
    include: { rooms: true }
  });

  console.log(`✅ Created hotels: ${h1.name}, ${h2.name}`);

  // Создаем несколько броней для демонстрации конфликтов
  const bookings = [
    // Бронь в прошлом (для демонстрации истории)
    {
      roomId: h1.rooms[0].id,
      startDate: new Date("2026-02-01"),
      endDate: new Date("2026-02-05"),
      description: "Past booking"
    },
    // Текущая активная бронь
    {
      roomId: h1.rooms[0].id,
      startDate: new Date("2026-03-01"),
      endDate: new Date("2026-03-05"),
      description: "Active booking - Room 101"
    },
    // Бронь в будущем
    {
      roomId: h1.rooms[1].id,
      startDate: new Date("2026-03-10"),
      endDate: new Date("2026-03-15"),
      description: "Future booking - Room 102"
    },
    // Еще одна бронь для демонстрации конфликта
    {
      roomId: h2.rooms[0].id,
      startDate: new Date("2026-03-20"),
      endDate: new Date("2026-03-25"),
      description: "Booking - Room 201"
    },
    // Последовательные брони (не пересекаются)
    {
      roomId: h2.rooms[1].id,
      startDate: new Date("2026-04-01"),
      endDate: new Date("2026-04-05"),
      description: "First booking - Room 202"
    },
    {
      roomId: h2.rooms[1].id,
      startDate: new Date("2026-04-05"),
      endDate: new Date("2026-04-10"),
      description: "Second booking - Room 202 (starts when first ends)"
    }
  ];

  for (const booking of bookings) {
    await prisma.booking.create({
      data: {
        roomId: booking.roomId,
        startDate: booking.startDate,
        endDate: booking.endDate
      }
    });
    console.log(`✅ Created booking: ${booking.description}`);
  }

  console.log("🎉 Seed completed successfully!");
  console.log(`📊 Total: 2 hotels, ${h1.rooms.length + h2.rooms.length} rooms, ${bookings.length} bookings`);
}

main()
  .catch((e) => {
    console.error("❌ Seed failed:", e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());