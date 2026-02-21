// Типы данных для нашего приложения
// Это помогает TypeScript понимать структуру данных и ловить ошибки

export interface Hotel {
  id: string;
  name: string;
  rooms: Room[];
}

export interface Room {
  id: string;
  name: string;
  hotelId: string;
  bookings: Booking[];
}

export interface Booking {
  id: string;
  roomId: string;
  startDate: string;
  endDate: string;
}
