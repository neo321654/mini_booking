import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import '../models/hotel.dart';
import '../services/graphql_service.dart';

// Windows Desktop виджет - легкое приложение для мониторинга
class WindowsWidgetScreen extends StatelessWidget {
  const WindowsWidgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // Компактная шапка
          _buildHeader(context),

          // Основной контент
          Expanded(
            child: Query(
              options: QueryOptions(
                document: gql(GraphQLService.getHotelsQuery),
                pollInterval: const Duration(seconds: 15),
              ),
              builder: (QueryResult result, {fetchMore, refetch}) {
                if (result.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (result.hasException) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Connection Error',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Cannot connect to backend',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => refetch?.call(),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final List<dynamic> hotelsData = result.data?['hotels'] ?? [];
                final hotels = hotelsData
                    .map((json) => Hotel.fromJson(json as Map<String, dynamic>))
                    .toList();

                return _buildHotelsList(hotels, refetch);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Шапка виджета
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.deepPurple,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.hotel, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          const Text(
            'Mini Booking Monitor',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Text(
            DateFormat('HH:mm').format(DateTime.now()),
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // Список отелей
  Widget _buildHotelsList(List<Hotel> hotels, VoidCallback? refetch) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: hotels.length + 1, // +1 для кнопки обновления
      itemBuilder: (context, index) {
        if (index == hotels.length) {
          // Кнопка обновления внизу
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: ElevatedButton.icon(
                onPressed: refetch,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh Data'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          );
        }

        final hotel = hotels[index];
        return _buildHotelCard(hotel);
      },
    );
  }

  // Карточка отеля
  Widget _buildHotelCard(Hotel hotel) {
    // Подсчет статистики
    int totalRooms = hotel.rooms.length;
    int occupiedRooms = hotel.rooms.where((r) => r.bookings.isNotEmpty).length;
    int freeRooms = totalRooms - occupiedRooms;
    int totalBookings = hotel.rooms.fold(
      0,
      (sum, r) => sum + r.bookings.length,
    );

    // Ближайшая бронь
    DateTime? nearestBooking;
    for (var room in hotel.rooms) {
      for (var booking in room.bookings) {
        if (nearestBooking == null ||
            booking.startDate.isBefore(nearestBooking)) {
          nearestBooking = booking.startDate;
        }
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Название отеля
            Row(
              children: [
                Icon(Icons.apartment, color: Colors.deepPurple[700], size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    hotel.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Статистика в строку
            Row(
              children: [
                _buildStatItem(
                  Icons.meeting_room,
                  'Total Rooms',
                  totalRooms.toString(),
                  Colors.blue,
                ),
                const SizedBox(width: 16),
                _buildStatItem(
                  Icons.check_circle,
                  'Free',
                  freeRooms.toString(),
                  Colors.green,
                ),
                const SizedBox(width: 16),
                _buildStatItem(
                  Icons.event_busy,
                  'Occupied',
                  occupiedRooms.toString(),
                  Colors.orange,
                ),
                const SizedBox(width: 16),
                _buildStatItem(
                  Icons.bookmark,
                  'Bookings',
                  totalBookings.toString(),
                  Colors.purple,
                ),
              ],
            ),

            // Ближайшая бронь
            if (nearestBooking != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.deepPurple[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color: Colors.deepPurple[700],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Next booking: ${DateFormat('MMM dd, HH:mm').format(nearestBooking)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.deepPurple[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Детали по номерам (компактно)
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: hotel.rooms.map((room) {
                final hasBookings = room.bookings.isNotEmpty;
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: hasBookings ? Colors.orange[100] : Colors.green[100],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: hasBookings
                          ? Colors.orange[300]!
                          : Colors.green[300]!,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        hasBookings ? Icons.event_busy : Icons.event_available,
                        size: 14,
                        color: hasBookings
                            ? Colors.orange[900]
                            : Colors.green[900],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        room.name,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: hasBookings
                              ? Colors.orange[900]
                              : Colors.green[900],
                        ),
                      ),
                      if (hasBookings) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${room.bookings.length}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[900],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // Элемент статистики
  Widget _buildStatItem(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
