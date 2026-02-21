// Модель данных для отеля
// В Dart классы используются вместо интерфейсов

class Hotel {
  final String id;
  final String name;
  final List<Room> rooms;

  Hotel({required this.id, required this.name, required this.rooms});

  // Создание объекта из JSON (от GraphQL API)
  factory Hotel.fromJson(Map<String, dynamic> json) {
    return Hotel(
      id: json['id'] as String,
      name: json['name'] as String,
      rooms: (json['rooms'] as List<dynamic>)
          .map((room) => Room.fromJson(room as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Room {
  final String id;
  final String name;
  final String hotelId;
  final List<Booking> bookings;

  Room({
    required this.id,
    required this.name,
    required this.hotelId,
    required this.bookings,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'] as String,
      name: json['name'] as String,
      hotelId: json['hotelId'] as String,
      bookings: (json['bookings'] as List<dynamic>)
          .map((booking) => Booking.fromJson(booking as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Booking {
  final String id;
  final String roomId;
  final DateTime startDate;
  final DateTime endDate;

  Booking({
    required this.id,
    required this.roomId,
    required this.startDate,
    required this.endDate,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String,
      roomId: json['roomId'] as String,
      // Конвертируем timestamp в DateTime
      startDate: DateTime.fromMillisecondsSinceEpoch(
        int.parse(json['startDate'] as String),
      ),
      endDate: DateTime.fromMillisecondsSinceEpoch(
        int.parse(json['endDate'] as String),
      ),
    );
  }
}
