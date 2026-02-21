import { ApolloServer, gql } from "apollo-server";
import { PrismaClient } from "@prisma/client";
import pino from "pino";

const prisma = new PrismaClient();
const logger = pino({
  level: process.env.LOG_LEVEL || "info",
  transport: {
    target: "pino-pretty",
    options: {
      colorize: true,
      translateTime: "SYS:standard",
      ignore: "pid,hostname",
    },
  },
});

const typeDefs = gql`
  type Hotel {
    id: ID!
    name: String!
    rooms: [Room!]!
  }

  type Room {
    id: ID!
    name: String!
    hotelId: String!
    bookings: [Booking!]!
  }

  type Booking {
    id: ID!
    roomId: String!
    startDate: String!
    endDate: String!
  }

  type Query {
    hotels: [Hotel!]!
    rooms(hotelId: String!): [Room!]!
    bookings(roomId: String!): [Booking!]!
  }

    type Mutation {
      createBooking(roomId: String!, startDate: String!, endDate: String!): Booking!
      cancelBooking(bookingId: String!): Boolean!
      checkAvailability(roomId: String!, startDate: String!, endDate: String!): Boolean!
    }
`;

const resolvers = {
  Query: {
    hotels: () => prisma.hotel.findMany(),
    rooms: (_: any, { hotelId }: any) =>
      prisma.room.findMany({ where: { hotelId } }),
    bookings: (_: any, { roomId }: any) =>
      prisma.booking.findMany({ where: { roomId } }),
  },
  Hotel: {
    rooms: (parent: any) =>
      prisma.room.findMany({ where: { hotelId: parent.id } }),
  },
  Room: {
    bookings: (parent: any) =>
      prisma.booking.findMany({ where: { roomId: parent.id } }),
  },


Mutation: {
  checkAvailability: async (_: any, { roomId, startDate, endDate }: any) => {
    const start = new Date(startDate);
    const end = new Date(endDate);
    const now = new Date();

    logger.info({ roomId, startDate, endDate }, "Checking availability");

    if (start >= end) {
      logger.error({ startDate, endDate }, "Invalid date range: start >= end");
      throw new Error("Invalid date range: start date must be before end date");
    }

    if (start < now) {
      logger.error({ startDate }, "Invalid date: booking in the past");
      throw new Error("Cannot book dates in the past");
    }

    const conflict = await prisma.booking.findFirst({
      where: {
        roomId,
        AND: [
          { startDate: { lt: end } },
          { endDate: { gt: start } },
        ],
      },
    });

    const available = !conflict;
    logger.info(
      { roomId, startDate, endDate, available, conflictId: conflict?.id },
      "Availability check completed"
    );

    return available;
  },

  createBooking: async (_: any, { roomId, startDate, endDate }: any) => {
    const start = new Date(startDate);
    const end = new Date(endDate);
    const now = new Date();

    logger.info({ roomId, startDate, endDate }, "Attempting to create booking");

    if (start >= end) {
      logger.error({ startDate, endDate }, "Invalid date range: start >= end");
      throw new Error("Invalid date range: start date must be before end date");
    }

    if (start < now) {
      logger.error({ startDate }, "Invalid date: booking in the past");
      throw new Error("Cannot book dates in the past");
    }

    try {
      const booking = await prisma.$transaction(async (tx) => {
        // Проверяем существование комнаты
        const room = await tx.room.findUnique({
          where: { id: roomId },
        });

        if (!room) {
          logger.error({ roomId }, "Room not found");
          throw new Error("Room not found");
        }

        // проверяем пересечение ВНУТРИ транзакции
        const conflict = await tx.booking.findFirst({
          where: {
            roomId,
            AND: [
              { startDate: { lt: end } },
              { endDate: { gt: start } },
            ],
          },
        });

        if (conflict) {
          logger.warn(
            { roomId, startDate, endDate, conflictId: conflict.id },
            "Booking conflict detected"
          );
          throw new Error("Room already booked for these dates");
        }

        // создаём бронь
        return tx.booking.create({
          data: {
            roomId,
            startDate: start,
            endDate: end,
          },
        });
      });

      logger.info(
        { bookingId: booking.id, roomId, startDate, endDate },
        "Booking created successfully"
      );

      return booking;
    } catch (error) {
      logger.error({ error, roomId, startDate, endDate }, "Failed to create booking");
      throw error;
    }
  },

  cancelBooking: async (_: any, { bookingId }: any) => {
    logger.info({ bookingId }, "Attempting to cancel booking");

    try {
      const booking = await prisma.booking.findUnique({
        where: { id: bookingId },
      });

      if (!booking) {
        logger.error({ bookingId }, "Booking not found");
        throw new Error("Booking not found");
      }

      await prisma.booking.delete({
        where: { id: bookingId },
      });

      logger.info(
        { bookingId, roomId: booking.roomId },
        "Booking cancelled successfully"
      );

      return true;
    } catch (error) {
      logger.error({ error, bookingId }, "Failed to cancel booking");
      throw error;
    }
  },
},
};

const server = new ApolloServer({ 
  typeDefs, 
  resolvers,
  introspection: true,
  formatError: (error) => {
    logger.error({ error: error.message, path: error.path }, "GraphQL Error");
    return error;
  },
});

server.listen().then(({ url }) => {
  logger.info({ url }, "🚀 Server ready");
});