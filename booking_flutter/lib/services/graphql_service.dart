import 'package:graphql_flutter/graphql_flutter.dart';
import 'dart:io' show Platform;

// Сервис для работы с GraphQL API
class GraphQLService {
  // URL нашего backend API
  // Для iOS симулятора и macOS используем localhost
  // Для Android эмулятора используем 10.0.2.2
  // Для реальных устройств нужно использовать IP адрес компьютера
  static String get apiUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:4000/graphql';
    }
    // iOS, macOS, Windows
    return 'http://localhost:4000/graphql';
  }

  // Создание GraphQL клиента
  static GraphQLClient getClient() {
    final HttpLink httpLink = HttpLink(apiUrl);

    return GraphQLClient(
      link: httpLink,
      cache: GraphQLCache(store: InMemoryStore()),
    );
  }

  // GraphQL запросы
  static const String getHotelsQuery = r'''
    query GetHotels {
      hotels {
        id
        name
        rooms {
          id
          name
          hotelId
          bookings {
            id
            roomId
            startDate
            endDate
          }
        }
      }
    }
  ''';

  static const String getBookingsQuery = r'''
    query GetBookings($roomId: String!) {
      bookings(roomId: $roomId) {
        id
        roomId
        startDate
        endDate
      }
    }
  ''';

  // GraphQL мутации
  static const String checkAvailabilityMutation = r'''
    mutation CheckAvailability($roomId: String!, $startDate: String!, $endDate: String!) {
      checkAvailability(roomId: $roomId, startDate: $startDate, endDate: $endDate)
    }
  ''';

  static const String createBookingMutation = r'''
    mutation CreateBooking($roomId: String!, $startDate: String!, $endDate: String!) {
      createBooking(roomId: $roomId, startDate: $startDate, endDate: $endDate) {
        id
        roomId
        startDate
        endDate
      }
    }
  ''';

  static const String cancelBookingMutation = r'''
    mutation CancelBooking($bookingId: String!) {
      cancelBooking(bookingId: $bookingId)
    }
  ''';
}
