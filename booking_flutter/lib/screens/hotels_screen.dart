import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../models/hotel.dart';
import '../services/graphql_service.dart';
import 'room_details_screen.dart';

// Главный экран со списком отелей
class HotelsScreen extends StatelessWidget {
  const HotelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar - верхняя панель приложения
      appBar: AppBar(
        title: const Text('🏨 Mini Booking'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Query(
        options: QueryOptions(
          document: gql(GraphQLService.getHotelsQuery),
          // pollInterval - автообновление каждые 10 секунд
          pollInterval: const Duration(seconds: 10),
        ),
        builder: (QueryResult result, {fetchMore, refetch}) {
          // Показываем индикатор загрузки
          if (result.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Показываем ошибку
          if (result.hasException) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${result.exception.toString()}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => refetch?.call(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Парсим данные
          final List<dynamic> hotelsData = result.data?['hotels'] ?? [];
          final hotels = hotelsData
              .map((json) => Hotel.fromJson(json as Map<String, dynamic>))
              .toList();

          if (hotels.isEmpty) {
            return const Center(child: Text('No hotels found'));
          }

          // Отображаем список отелей
          return RefreshIndicator(
            onRefresh: () async {
              await refetch?.call();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: hotels.length,
              itemBuilder: (context, index) {
                final hotel = hotels[index];
                return HotelCard(hotel: hotel);
              },
            ),
          );
        },
      ),
    );
  }
}

// Виджет карточки отеля
class HotelCard extends StatelessWidget {
  final Hotel hotel;

  const HotelCard({super.key, required this.hotel});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              hotel.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Rooms:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            // Список номеров
            ...hotel.rooms.map((room) => RoomListItem(room: room)),
          ],
        ),
      ),
    );
  }
}

// Виджет элемента списка номеров
class RoomListItem extends StatelessWidget {
  final Room room;

  const RoomListItem({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    final bookingsCount = room.bookings.length;

    return InkWell(
      onTap: () {
        // Переход на экран деталей номера
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RoomDetailsScreen(room: room),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                room.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: bookingsCount > 0
                    ? Colors.orange[100]
                    : Colors.green[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$bookingsCount ${bookingsCount == 1 ? 'booking' : 'bookings'}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: bookingsCount > 0
                      ? Colors.orange[900]
                      : Colors.green[900],
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
