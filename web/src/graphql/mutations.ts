import { gql } from '@apollo/client';

// Мутация для проверки доступности номера
export const CHECK_AVAILABILITY = gql`
  mutation CheckAvailability($roomId: String!, $startDate: String!, $endDate: String!) {
    checkAvailability(roomId: $roomId, startDate: $startDate, endDate: $endDate)
  }
`;

// Мутация для создания брони
export const CREATE_BOOKING = gql`
  mutation CreateBooking($roomId: String!, $startDate: String!, $endDate: String!) {
    createBooking(roomId: $roomId, startDate: $startDate, endDate: $endDate) {
      id
      roomId
      startDate
      endDate
    }
  }
`;

// Мутация для отмены брони
export const CANCEL_BOOKING = gql`
  mutation CancelBooking($bookingId: String!) {
    cancelBooking(bookingId: $bookingId)
  }
`;
