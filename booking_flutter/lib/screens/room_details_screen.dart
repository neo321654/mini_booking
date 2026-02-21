import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import '../models/hotel.dart';
import '../services/graphql_service.dart';

// Экран деталей номера с управлением бронями
class RoomDetailsScreen extends StatefulWidget {
  final Room room;

  const RoomDetailsScreen({super.key, required this.room});

  @override
  State<RoomDetailsScreen> createState() => _RoomDetailsScreenState();
}

class _RoomDetailsScreenState extends State<RoomDetailsScreen> {
  DateTime? startDate;
  DateTime? endDate;
  String? message;
  bool isSuccess = false;

  // Форматирование даты для отображения
  String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  // Форматирование даты для API (ISO 8601)
  String formatDateForApi(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // Выбор даты
  Future<void> selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart
          ? (startDate ?? DateTime.now())
          : (endDate ?? startDate ?? DateTime.now()),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
          // Если end date раньше start date, сбрасываем
          if (endDate != null && endDate!.isBefore(picked)) {
            endDate = null;
          }
        } else {
          endDate = picked;
        }
      });
    }
  }

  // Показать сообщение
  void showMessage(String text, bool success) {
    setState(() {
      message = text;
      isSuccess = success;
    });

    // Автоматически скрыть через 3 секунды
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          message = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.room.name),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Query(
        options: QueryOptions(
          document: gql(GraphQLService.getBookingsQuery),
          variables: {'roomId': widget.room.id},
          pollInterval: const Duration(seconds: 5),
        ),
        builder: (QueryResult result, {fetchMore, refetch}) {
          // Обновляем брони из запроса
          List<Booking> bookings = widget.room.bookings;
          if (!result.isLoading &&
              !result.hasException &&
              result.data != null) {
            final bookingsData = result.data?['bookings'] as List<dynamic>?;
            if (bookingsData != null) {
              bookings = bookingsData
                  .map((json) => Booking.fromJson(json as Map<String, dynamic>))
                  .toList();
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Форма создания брони
                _buildBookingForm(context, refetch),

                const SizedBox(height: 24),

                // Список существующих броней
                _buildBookingsList(bookings, refetch),
              ],
            ),
          );
        },
      ),
    );
  }

  // Форма создания брони
  Widget _buildBookingForm(BuildContext context, VoidCallback? refetch) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Create New Booking',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Выбор даты начала
            _buildDateSelector(
              context,
              'Start Date',
              startDate,
              () => selectDate(context, true),
            ),

            const SizedBox(height: 12),

            // Выбор даты окончания
            _buildDateSelector(
              context,
              'End Date',
              endDate,
              () => selectDate(context, false),
            ),

            const SizedBox(height: 16),

            // Кнопки действий
            Row(
              children: [
                Expanded(
                  child: Mutation(
                    options: MutationOptions(
                      document: gql(GraphQLService.checkAvailabilityMutation),
                      onCompleted: (dynamic resultData) {
                        final available =
                            resultData?['checkAvailability'] as bool?;
                        if (available == true) {
                          showMessage('✅ Room is available!', true);
                        } else {
                          showMessage('❌ Room is not available', false);
                        }
                      },
                      onError: (error) {
                        showMessage(
                          error?.graphqlErrors.first.message ?? 'Error',
                          false,
                        );
                      },
                    ),
                    builder: (runMutation, result) {
                      return OutlinedButton(
                        onPressed:
                            startDate != null &&
                                endDate != null &&
                                !result!.isLoading
                            ? () {
                                runMutation({
                                  'roomId': widget.room.id,
                                  'startDate': formatDateForApi(startDate!),
                                  'endDate': formatDateForApi(endDate!),
                                });
                              }
                            : null,
                        child: result!.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Check Availability'),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Mutation(
                    options: MutationOptions(
                      document: gql(GraphQLService.createBookingMutation),
                      onCompleted: (dynamic resultData) {
                        showMessage('✅ Booking created!', true);
                        setState(() {
                          startDate = null;
                          endDate = null;
                        });
                        Future.delayed(const Duration(milliseconds: 1500), () {
                          refetch?.call();
                        });
                      },
                      onError: (error) {
                        showMessage(
                          error?.graphqlErrors.first.message ?? 'Error',
                          false,
                        );
                      },
                    ),
                    builder: (runMutation, result) {
                      return ElevatedButton(
                        onPressed:
                            startDate != null &&
                                endDate != null &&
                                !result!.isLoading
                            ? () {
                                runMutation({
                                  'roomId': widget.room.id,
                                  'startDate': formatDateForApi(startDate!),
                                  'endDate': formatDateForApi(endDate!),
                                });
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                        ),
                        child: result!.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Create Booking'),
                      );
                    },
                  ),
                ),
              ],
            ),

            // Сообщение
            if (message != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSuccess ? Colors.green[100] : Colors.red[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  message!,
                  style: TextStyle(
                    color: isSuccess ? Colors.green[900] : Colors.red[900],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Селектор даты
  Widget _buildDateSelector(
    BuildContext context,
    String label,
    DateTime? date,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  date != null ? formatDate(date) : 'Select date',
                  style: TextStyle(
                    fontSize: 16,
                    color: date != null ? Colors.black : Colors.grey,
                  ),
                ),
              ],
            ),
            const Icon(Icons.calendar_today, color: Colors.deepPurple),
          ],
        ),
      ),
    );
  }

  // Список броней
  Widget _buildBookingsList(List<Booking> bookings, VoidCallback? refetch) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Existing Bookings (${bookings.length})',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            if (bookings.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'No bookings yet',
                    style: TextStyle(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              )
            else
              ...bookings.map((booking) => _buildBookingItem(booking, refetch)),
          ],
        ),
      ),
    );
  }

  // Элемент брони
  Widget _buildBookingItem(Booking booking, VoidCallback? refetch) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.deepPurple,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${formatDate(booking.startDate)} → ${formatDate(booking.endDate)}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: ${booking.id.substring(0, 8)}...',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Mutation(
            options: MutationOptions(
              document: gql(GraphQLService.cancelBookingMutation),
              onCompleted: (dynamic resultData) {
                showMessage('✅ Booking cancelled!', true);
                Future.delayed(const Duration(milliseconds: 1500), () {
                  refetch?.call();
                });
              },
              onError: (error) {
                showMessage(
                  error?.graphqlErrors.first.message ?? 'Error',
                  false,
                );
              },
            ),
            builder: (runMutation, result) {
              return IconButton(
                onPressed: result!.isLoading
                    ? null
                    : () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Cancel Booking'),
                            content: const Text(
                              'Are you sure you want to cancel this booking?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('No'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Yes'),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          runMutation({'bookingId': booking.id});
                        }
                      },
                icon: result.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.delete, color: Colors.red),
              );
            },
          ),
        ],
      ),
    );
  }
}
