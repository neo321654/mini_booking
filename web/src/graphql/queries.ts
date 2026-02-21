import { gql } from '@apollo/client';

// GraphQL запрос для получения всех отелей с номерами и бронями
// gql - это специальный тег для GraphQL запросов
export const GET_HOTELS = gql`
  query GetHotels {
    hotels {
      id
      name
      rooms {
        id
        name
        bookings {
          id
          startDate
          endDate
        }
      }
    }
  }
`;

// Запрос для получения броней конкретного номера
export const GET_BOOKINGS = gql`
  query GetBookings($roomId: String!) {
    bookings(roomId: $roomId) {
      id
      roomId
      startDate
      endDate
    }
  }
`;
