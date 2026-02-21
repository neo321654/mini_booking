# GraphQL Test Queries

Используйте эти запросы для тестирования API через GraphQL Playground (http://localhost:4000/graphql)

## 1. Получить все отели с номерами

```graphql
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
```

## 2. Получить номера конкретного отеля

```graphql
query GetRooms($hotelId: String!) {
  rooms(hotelId: $hotelId) {
    id
    name
    bookings {
      id
      startDate
      endDate
    }
  }
}
```

Variables:
```json
{
  "hotelId": "your-hotel-id-here"
}
```

## 3. Проверить доступность номера

```graphql
mutation CheckAvailability($roomId: String!, $startDate: String!, $endDate: String!) {
  checkAvailability(
    roomId: $roomId
    startDate: $startDate
    endDate: $endDate
  )
}
```

Variables:
```json
{
  "roomId": "your-room-id-here",
  "startDate": "2026-05-01",
  "endDate": "2026-05-05"
}
```

## 4. Создать бронь

```graphql
mutation CreateBooking($roomId: String!, $startDate: String!, $endDate: String!) {
  createBooking(
    roomId: $roomId
    startDate: $startDate
    endDate: $endDate
  ) {
    id
    roomId
    startDate
    endDate
  }
}
```

Variables:
```json
{
  "roomId": "your-room-id-here",
  "startDate": "2026-05-01",
  "endDate": "2026-05-05"
}
```

## 5. Отменить бронь

```graphql
mutation CancelBooking($bookingId: String!) {
  cancelBooking(bookingId: $bookingId)
}
```

Variables:
```json
{
  "bookingId": "your-booking-id-here"
}
```

## Тестовые сценарии

### Сценарий 1: Успешное бронирование
1. Получите список отелей и выберите roomId
2. Проверьте доступность на свободные даты (например, 2026-06-01 до 2026-06-05)
3. Создайте бронь на эти даты
4. Проверьте, что бронь появилась в списке

### Сценарий 2: Конфликт броней
1. Получите roomId с существующей бронью (например, номер с бронью на 2026-03-01 до 2026-03-05)
2. Попробуйте создать бронь на пересекающиеся даты (2026-03-03 до 2026-03-07)
3. Должна вернуться ошибка "Room already booked for these dates"

### Сценарий 3: Валидация дат
1. Попробуйте создать бронь с датой начала позже даты окончания
2. Попробуйте создать бронь на прошлые даты
3. Должны вернуться соответствующие ошибки валидации

### Сценарий 4: Отмена брони
1. Создайте новую бронь
2. Скопируйте её ID
3. Отмените бронь используя этот ID
4. Проверьте, что бронь удалена из списка

## Примеры ошибок

### Конфликт броней
```json
{
  "errors": [
    {
      "message": "Room already booked for these dates"
    }
  ]
}
```

### Неверный диапазон дат
```json
{
  "errors": [
    {
      "message": "Invalid date range: start date must be before end date"
    }
  ]
}
```

### Бронирование в прошлом
```json
{
  "errors": [
    {
      "message": "Cannot book dates in the past"
    }
  ]
}
```
