# Отчет о тестировании Backend

**Дата:** 21 февраля 2026  
**Платформа:** macOS + Docker Desktop  
**Статус:** ✅ Все тесты пройдены успешно

## Запуск системы

```bash
docker compose up --build -d
```

**Результат:**
- ✅ PostgreSQL запущен и здоров (healthy)
- ✅ Backend запущен на порту 4000
- ✅ Миграции применены автоматически
- ✅ Seed данных загружен (2 отеля, 6 номеров, 6 броней)

## Тестовые сценарии

### 1. ✅ Получение списка отелей и номеров

**Запрос:**
```graphql
query {
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

**Результат:**
- Получены 2 отеля: "Grand Plaza Hotel" и "Ocean View Resort"
- Каждый отель содержит по 3 номера
- Видны существующие брони

### 2. ✅ Проверка доступности номера

**Запрос:**
```graphql
mutation {
  checkAvailability(
    roomId: "4f6eee58-1369-4630-a304-07c1ed601563"
    startDate: "2026-05-01"
    endDate: "2026-05-05"
  )
}
```

**Результат:**
```json
{
  "data": {
    "checkAvailability": true
  }
}
```

**Логи:**
```
[INFO] Checking availability
  roomId: "4f6eee58-1369-4630-a304-07c1ed601563"
  startDate: "2026-05-01"
  endDate: "2026-05-05"
[INFO] Availability check completed
  available: true
```

### 3. ✅ Создание брони

**Запрос:**
```graphql
mutation {
  createBooking(
    roomId: "4f6eee58-1369-4630-a304-07c1ed601563"
    startDate: "2026-05-01"
    endDate: "2026-05-05"
  ) {
    id
    roomId
    startDate
    endDate
  }
}
```

**Результат:**
```json
{
  "data": {
    "createBooking": {
      "id": "fe749672-322a-44a1-bf86-426e30393220",
      "roomId": "4f6eee58-1369-4630-a304-07c1ed601563",
      "startDate": "1777593600000",
      "endDate": "1777939200000"
    }
  }
}
```

**Логи:**
```
[INFO] Attempting to create booking
  roomId: "4f6eee58-1369-4630-a304-07c1ed601563"
  startDate: "2026-05-01"
  endDate: "2026-05-05"
[INFO] Booking created successfully
  bookingId: "fe749672-322a-44a1-bf86-426e30393220"
```

### 4. ✅ Обнаружение конфликта броней

**Запрос:** Попытка забронировать пересекающиеся даты (2026-05-03 до 2026-05-07)

**Результат:**
```json
{
  "errors": [
    {
      "message": "Room already booked for these dates"
    }
  ]
}
```

**Логи:**
```
[ERROR] Failed to create booking
  roomId: "4f6eee58-1369-4630-a304-07c1ed601563"
  startDate: "2026-05-03"
  endDate: "2026-05-07"
[ERROR] GraphQL Error
  error: "Room already booked for these dates"
```

### 5. ✅ Валидация дат в прошлом

**Запрос:** Попытка забронировать даты в прошлом (2026-01-01 до 2026-01-05)

**Результат:**
```json
{
  "errors": [
    {
      "message": "Cannot book dates in the past"
    }
  ]
}
```

### 6. ✅ Отмена брони

**Запрос:**
```graphql
mutation {
  cancelBooking(bookingId: "fe749672-322a-44a1-bf86-426e30393220")
}
```

**Результат:**
```json
{
  "data": {
    "cancelBooking": true
  }
}
```

**Логи:**
```
[INFO] Attempting to cancel booking
  bookingId: "fe749672-322a-44a1-bf86-426e30393220"
[INFO] Booking cancelled successfully
  bookingId: "fe749672-322a-44a1-bf86-426e30393220"
  roomId: "4f6eee58-1369-4630-a304-07c1ed601563"
```

## Проверка логирования

✅ Все ключевые операции логируются:
- Проверка доступности
- Создание броней
- Конфликты броней
- Отмена броней
- Ошибки валидации
- GraphQL ошибки

Логи структурированные (JSON) с полным контекстом (roomId, dates, bookingId).

## Проверка Docker

```bash
docker compose ps
```

**Результат:**
```
NAME              STATUS                        PORTS
booking_backend   Up About a minute             0.0.0.0:4000->4000/tcp
booking_db        Up About a minute (healthy)   0.0.0.0:5432->5432/tcp
```

## GraphQL Playground

✅ Доступен по адресу: http://localhost:4000/graphql  
✅ Интроспекция включена  
✅ Можно тестировать запросы через UI

## Выводы

### ✅ Все требования выполнены:

1. **GraphQL API** - работает корректно
2. **Валидация** - все проверки работают
3. **Конфликты броней** - обнаруживаются и блокируются
4. **Логирование** - все операции логируются с контекстом
5. **Docker** - запуск одной командой
6. **Seed данные** - загружаются автоматически
7. **Обработка ошибок** - понятные сообщения

### Готово к:
- ✅ Интеграции с Flutter приложением
- ✅ Интеграции с React веб-приложением
- ✅ Записи видео-демо
- ✅ Продакшн деплою (с минимальными доработками)

## Команды для остановки

```bash
# Остановить контейнеры
docker compose down

# Остановить и удалить данные
docker compose down -v
```
