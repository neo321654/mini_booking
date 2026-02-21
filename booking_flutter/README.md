# Flutter Mobile Application - Mini Booking System

Flutter приложение для iOS и Android для системы бронирования отелей.

## 🎯 Функциональность

### Mobile (iOS/Android):
- ✅ Просмотр списка отелей и номеров
- ✅ Навигация: Отели → Номера → Детали номера
- ✅ Выбор диапазона дат через календарь
- ✅ Проверка доступности номера
- ✅ Создание брони
- ✅ Просмотр существующих броней
- ✅ Отмена брони с подтверждением
- ✅ Автообновление данных (polling)
- ✅ Pull-to-refresh

## 🏗️ Архитектура

### Структура проекта:
```
lib/
├── models/                 # Модели данных
│   └── hotel.dart         # Hotel, Room, Booking классы
├── services/              # Сервисы
│   └── graphql_service.dart  # GraphQL клиент и запросы
├── screens/               # Экраны приложения
│   ├── hotels_screen.dart    # Список отелей
│   └── room_details_screen.dart  # Детали номера
└── main.dart              # Точка входа
```

## 🔧 Технологии

- **Flutter 3.38.9** - UI фреймворк
- **Dart 3.10.8** - язык программирования
- **graphql_flutter** - GraphQL клиент
- **intl** - форматирование дат
- **provider** - state management

## 🚀 Запуск

### Требования:
- Flutter SDK 3.38.9+
- Xcode (для iOS)
- Android Studio (для Android)
- Backend должен быть запущен на localhost:4000

### Установка зависимостей:
```bash
cd booking_flutter
flutter pub get
```

### Запуск на iOS симуляторе:
```bash
# Открыть iOS симулятор
open -a Simulator

# Запустить приложение
flutter run
```

### Запуск на Android эмуляторе:
```bash
# Запустить эмулятор через Android Studio
# или через командную строку:
flutter emulators --launch <emulator_id>

# Запустить приложение
flutter run
```

### Проверка устройств:
```bash
flutter devices
```

## 📱 Что такое Flutter?

**Flutter** - это фреймворк от Google для создания приложений на разных платформах из одного кода.

### Основные концепции:

#### 1. Widget (Виджет)
Всё в Flutter - это виджет. Виджет - это элемент UI:
- Кнопка - виджет
- Текст - виджет
- Экран - виджет
- Даже отступы - виджет!

```dart
Text('Hello')  // Виджет текста
ElevatedButton(...)  // Виджет кнопки
Container(...)  // Виджет контейнера
```

#### 2. StatelessWidget vs StatefulWidget

**StatelessWidget** - виджет без состояния (не меняется):
```dart
class MyText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text('Hello');
  }
}
```

**StatefulWidget** - виджет с состоянием (может меняться):
```dart
class Counter extends StatefulWidget {
  @override
  State<Counter> createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  int count = 0;
  
  @override
  Widget build(BuildContext context) {
    return Text('Count: $count');
  }
}
```

#### 3. setState()
Функция для обновления UI:
```dart
setState(() {
  count++;  // Изменяем данные
});  // Flutter автоматически перерисует виджет
```

#### 4. Navigation (Навигация)
Переход между экранами:
```dart
// Открыть новый экран
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => NewScreen()),
);

// Вернуться назад
Navigator.pop(context);
```

## 🔌 GraphQL интеграция

### Как это работает:

1. **GraphQLProvider** - оборачивает приложение и предоставляет клиент
2. **Query** - виджет для получения данных
3. **Mutation** - виджет для изменения данных

### Пример Query:
```dart
Query(
  options: QueryOptions(
    document: gql(query),  // GraphQL запрос
  ),
  builder: (result, {refetch, fetchMore}) {
    if (result.isLoading) return Loading();
    if (result.hasException) return Error();
    
    // Используем данные
    final data = result.data;
    return ListView(...);
  },
)
```

### Пример Mutation:
```dart
Mutation(
  options: MutationOptions(
    document: gql(mutation),
    onCompleted: (data) {
      // Успех!
    },
  ),
  builder: (runMutation, result) {
    return ElevatedButton(
      onPressed: () => runMutation(variables),
      child: Text('Create'),
    );
  },
)
```

## 📊 Структура экранов

### HotelsScreen (Список отелей)
```
AppBar (шапка)
  └─ "🏨 Mini Booking"

Body (тело)
  └─ Query (запрос данных)
      └─ ListView (список)
          └─ HotelCard (карточка отеля)
              └─ RoomListItem (элемент номера)
```

### RoomDetailsScreen (Детали номера)
```
AppBar
  └─ Название номера

Body
  ├─ BookingForm (форма брони)
  │   ├─ DateSelector (выбор дат)
  │   ├─ Check Availability (кнопка)
  │   └─ Create Booking (кнопка)
  │
  └─ BookingsList (список броней)
      └─ BookingItem (элемент брони)
          └─ Cancel button (кнопка отмены)
```

## 🎨 UI компоненты

### Material Design
Flutter использует Material Design от Google:
- **Scaffold** - базовая структура экрана
- **AppBar** - верхняя панель
- **Card** - карточка с тенью
- **ElevatedButton** - кнопка с подъемом
- **CircularProgressIndicator** - индикатор загрузки

### Пример структуры:
```dart
Scaffold(
  appBar: AppBar(title: Text('Title')),
  body: Column(
    children: [
      Card(...),
      ElevatedButton(...),
    ],
  ),
)
```

## 📅 Работа с датами

### DatePicker (выбор даты):
```dart
final date = await showDatePicker(
  context: context,
  initialDate: DateTime.now(),
  firstDate: DateTime.now(),
  lastDate: DateTime.now().add(Duration(days: 365)),
);
```

### Форматирование:
```dart
import 'package:intl/intl.dart';

// Для отображения
DateFormat('MMM dd, yyyy').format(date);  // "Jan 15, 2026"

// Для API
DateFormat('yyyy-MM-dd').format(date);  // "2026-01-15"
```

## 🔄 Жизненный цикл

### Как работает приложение:

1. **main()** - точка входа
   ```dart
   void main() {
     runApp(MyApp());
   }
   ```

2. **MyApp** - корневой виджет
   - Создает GraphQL клиент
   - Настраивает тему
   - Определяет начальный экран

3. **HotelsScreen** - первый экран
   - Выполняет Query для получения отелей
   - Отображает список
   - Обрабатывает клики

4. **RoomDetailsScreen** - второй экран
   - Получает Room через конструктор
   - Выполняет Query для броней
   - Обрабатывает создание/отмену

## 🌐 Сетевые запросы

### Платформо-зависимые URL:

- **iOS/macOS**: `http://localhost:4000/graphql`
- **Android**: `http://10.0.2.2:4000/graphql` (10.0.2.2 = localhost хоста)
- **Реальное устройство**: `http://<IP_КОМПЬЮТЕРА>:4000/graphql`

### Определение платформы:
```dart
import 'dart:io' show Platform;

if (Platform.isAndroid) {
  // Android код
} else if (Platform.isIOS) {
  // iOS код
}
```

## 🐛 Отладка

### Логи:
```dart
print('Debug message');
debugPrint('Debug message');
```

### Flutter DevTools:
```bash
flutter pub global activate devtools
flutter pub global run devtools
```

### Hot Reload:
- Сохраните файл или нажмите `r` в терминале
- Изменения применяются мгновенно без перезапуска

### Hot Restart:
- Нажмите `R` в терминале
- Полный перезапуск приложения

## 📦 Модели данных

### Hotel:
```dart
class Hotel {
  final String id;
  final String name;
  final List<Room> rooms;
}
```

### Room:
```dart
class Room {
  final String id;
  final String name;
  final String hotelId;
  final List<Booking> bookings;
}
```

### Booking:
```dart
class Booking {
  final String id;
  final String roomId;
  final DateTime startDate;
  final DateTime endDate;
}
```

### fromJson:
Метод для создания объекта из JSON:
```dart
factory Hotel.fromJson(Map<String, dynamic> json) {
  return Hotel(
    id: json['id'],
    name: json['name'],
    rooms: (json['rooms'] as List)
        .map((r) => Room.fromJson(r))
        .toList(),
  );
}
```

## 🎯 Соответствие требованиям

### Обязательные требования:
- ✅ Flutter приложение
- ✅ Навигация: Отели → Номера → Номер
- ✅ Выбор диапазона дат
- ✅ Проверка доступности
- ✅ Бронирование
- ✅ Отмена брони
- ✅ Интеграция с GraphQL

### Дополнительно:
- ✅ Автообновление данных (polling)
- ✅ Pull-to-refresh
- ✅ Подтверждение перед удалением
- ✅ Индикаторы загрузки
- ✅ Обработка ошибок
- ✅ Красивый UI

## 🔧 Troubleshooting

### Backend недоступен:
```
Error: Failed host lookup: 'localhost'
```
**Решение**: Убедитесь, что backend запущен на localhost:4000

### iOS не может подключиться:
**Решение**: Проверьте Info.plist - должен быть NSAppTransportSecurity

### Android не может подключиться:
**Решение**: Используйте 10.0.2.2 вместо localhost

### Ошибка при pub get:
```bash
flutter pub cache repair
flutter pub get
```

## 📱 Тестирование

### Запуск тестов:
```bash
flutter test
```

### Анализ кода:
```bash
flutter analyze
```

### Форматирование:
```bash
flutter format lib/
```

## 🚀 Сборка

### iOS:
```bash
flutter build ios
```

### Android:
```bash
flutter build apk  # Debug APK
flutter build appbundle  # Release bundle для Play Store
```

## 📚 Полезные ресурсы

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [GraphQL Flutter](https://pub.dev/packages/graphql_flutter)
- [Material Design](https://material.io/design)
