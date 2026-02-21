# Объяснение React Web приложения

## Что такое React и как это работает?

### React - это библиотека для создания UI
Представьте, что вы строите дом из LEGO блоков. React работает похожим образом:
- Каждый блок (компонент) - это переиспользуемая часть интерфейса
- Блоки можно комбинировать для создания сложных интерфейсов
- Когда данные меняются, React автоматически обновляет нужные части UI

## Основные концепции

### 1. Компоненты (Components)
Это функции, которые возвращают HTML-подобный код (JSX):

```typescript
function HotelCard() {
  return (
    <div className="hotel-card">
      <h3>Grand Plaza Hotel</h3>
    </div>
  );
}
```

### 2. State (Состояние)
Данные, которые могут меняться:

```typescript
const [selectedRoom, setSelectedRoom] = useState(null);
// selectedRoom - текущее значение
// setSelectedRoom - функция для изменения
```

Когда вы вызываете `setSelectedRoom(newRoom)`, React автоматически перерисовывает компонент.

### 3. Props (Свойства)
Параметры, которые передаются в компонент:

```typescript
<HotelList hotels={data} onSelect={handleSelect} />
// hotels и onSelect - это props
```

### 4. Hooks (Хуки)
Специальные функции React для работы с состоянием и эффектами:
- `useState` - для хранения данных
- `useQuery` - для получения данных из API (Apollo)
- `useMutation` - для изменения данных через API (Apollo)

## Как работает наше приложение?

### Поток данных:

```
1. Пользователь открывает страницу
   ↓
2. App.tsx выполняет запрос GET_HOTELS к GraphQL API
   ↓
3. Backend возвращает данные (отели, номера, брони)
   ↓
4. React рендерит компоненты с этими данными
   ↓
5. Пользователь кликает на номер
   ↓
6. Вызывается setSelectedRoomId(roomId)
   ↓
7. React перерисовывает компоненты с новым состоянием
   ↓
8. Показывается RoomDetails с формой бронирования
```

### Создание брони:

```
1. Пользователь выбирает даты и нажимает "Create Booking"
   ↓
2. Вызывается функция handleCreateBooking
   ↓
3. Выполняется мутация CREATE_BOOKING через Apollo
   ↓
4. Запрос отправляется на backend GraphQL API
   ↓
5. Backend создает бронь в базе данных
   ↓
6. Backend возвращает результат
   ↓
7. React показывает сообщение об успехе
   ↓
8. Автоматически обновляются данные (refetch)
   ↓
9. Пользователь видит новую бронь в списке
```

## Структура файлов

### main.tsx - Точка входа
```typescript
// Здесь мы:
// 1. Создаем Apollo Client (для связи с GraphQL)
// 2. Оборачиваем приложение в ApolloProvider
// 3. Рендерим App компонент в DOM
```

### App.tsx - Главный компонент
```typescript
// Здесь мы:
// 1. Получаем данные отелей через useQuery
// 2. Храним выбранный номер в state
// 3. Рендерим HotelList и RoomDetails
```

### HotelList.tsx - Список отелей
```typescript
// Здесь мы:
// 1. Получаем hotels через props
// 2. Отображаем каждый отель и его номера
// 3. При клике вызываем onRoomSelect
```

### RoomDetails.tsx - Детали номера
```typescript
// Здесь мы:
// 1. Получаем room через props
// 2. Храним даты в state (startDate, endDate)
// 3. Используем мутации для создания/отмены броней
// 4. Показываем форму и список броней
```

## Apollo Client - как это работает?

### 1. Создание клиента:
```typescript
const client = new ApolloClient({
  uri: 'http://localhost:4000/graphql',  // Адрес API
  cache: new InMemoryCache(),             // Кеш для оптимизации
});
```

### 2. Запрос данных (Query):
```typescript
const { data, loading, error } = useQuery(GET_HOTELS);
// Apollo автоматически:
// - Отправляет запрос на сервер
// - Кеширует результат
// - Обновляет компонент при получении данных
```

### 3. Изменение данных (Mutation):
```typescript
const [createBooking] = useMutation(CREATE_BOOKING);

// Вызываем мутацию:
await createBooking({
  variables: { roomId, startDate, endDate }
});
```

## TypeScript - зачем нужен?

TypeScript добавляет типы к JavaScript:

```typescript
// Без TypeScript (JavaScript):
function createBooking(room, date) {
  // Что такое room? Что такое date? Неизвестно!
}

// С TypeScript:
function createBooking(room: Room, date: string) {
  // Теперь понятно: room - это объект Room, date - строка
  // IDE подскажет доступные поля и методы
  // Ошибки будут найдены до запуска
}
```

### Интерфейсы:
```typescript
interface Hotel {
  id: string;
  name: string;
  rooms: Room[];
}
```

Это как чертеж - описывает структуру объекта.

## CSS - стилизация

Мы используем обычный CSS (без фреймворков):

```css
.hotel-card {
  background: white;
  padding: 1rem;
  border-radius: 8px;
}
```

Классы применяются через `className`:
```typescript
<div className="hotel-card">
```

## Vite - что это?

Vite - это инструмент для разработки:
- Быстро запускает dev сервер
- Автоматически обновляет страницу при изменении кода (Hot Module Replacement)
- Собирает проект для production

## Docker - зачем?

Docker упаковывает приложение в контейнер:
- Одинаково работает на любом компьютере
- Не нужно устанавливать Node.js локально
- Легко деплоить на сервер

## Что происходит при запуске?

```bash
docker compose up web --build
```

1. Docker читает Dockerfile
2. Создает контейнер с Node.js
3. Копирует код приложения
4. Устанавливает зависимости (npm ci)
5. Запускает dev сервер (npm run dev)
6. Vite запускается на порту 3000
7. Приложение доступно на http://localhost:3000

## Взаимодействие с Backend

```
Browser (React App)
    ↓ HTTP POST
    ↓ GraphQL Query/Mutation
Backend (Apollo Server)
    ↓ SQL Query
Database (PostgreSQL)
    ↓ Data
Backend
    ↓ GraphQL Response
Browser
    ↓ React Update
User sees result
```

## Ключевые файлы и их роль

1. **package.json** - список зависимостей и скриптов
2. **tsconfig.json** - настройки TypeScript
3. **vite.config.ts** - настройки Vite
4. **index.html** - HTML шаблон (точка входа)
5. **main.tsx** - JavaScript точка входа (создание Apollo Client)
6. **App.tsx** - главный компонент (логика приложения)
7. **App.css** - стили
8. **components/** - переиспользуемые компоненты
9. **graphql/** - GraphQL запросы и мутации
10. **types/** - TypeScript типы

## Резюме

React приложение - это:
- Набор компонентов (функций, возвращающих JSX)
- Состояние (данные, которые могут меняться)
- Взаимодействие с API через Apollo Client
- Автоматическое обновление UI при изменении данных
- TypeScript для безопасности типов
- Vite для быстрой разработки
- Docker для упаковки и деплоя

Все это работает вместе, чтобы создать интерактивное веб-приложение!
