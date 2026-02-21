import { ApolloServer, gql } from "apollo-server";
import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

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

    if (start >= end) throw new Error("Invalid date range");

    const conflict = await prisma.booking.findFirst({
      where: {
        roomId,
        AND: [
          { startDate: { lt: end } },
          { endDate: { gt: start } },
        ],
      },
    });

    return !conflict;
  },

  createBooking: async (_: any, { roomId, startDate, endDate }: any) => {
    const start = new Date(startDate);
    const end = new Date(endDate);

    if (start >= end) throw new Error("Invalid date range");

    return prisma.$transaction(async (tx) => {
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
  },

  cancelBooking: async (_: any, { bookingId }: any) => {
    await prisma.booking.delete({
      where: { id: bookingId },
    });
    return true;
  },
},
};

const server = new ApolloServer({ typeDefs, resolvers ,introspection: true,});

server.listen().then(({ url }) => {
  console.log(`🚀 Server ready at ${url}`);
});