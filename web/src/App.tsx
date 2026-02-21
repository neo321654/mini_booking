import { useState } from 'react';
import { useQuery } from '@apollo/client';
import { GET_HOTELS } from './graphql/queries';
import { Hotel } from './types';
import HotelList from './components/HotelList';
import RoomDetails from './components/RoomDetails';
import './App.css';

// Главный компонент приложения
function App() {
  // useState - это React hook для хранения состояния
  // selectedRoomId - текущее значение, setSelectedRoomId - функция для изменения
  const [selectedRoomId, setSelectedRoomId] = useState<string | null>(null);

  // useQuery - Apollo hook для выполнения GraphQL запроса
  // loading - идет ли загрузка, error - ошибка, data - полученные данные
  const { loading, error, data, refetch } = useQuery<{ hotels: Hotel[] }>(GET_HOTELS);

  // Показываем индикатор загрузки
  if (loading) return <div className="loading">Loading hotels...</div>;
  
  // Показываем ошибку, если что-то пошло не так
  if (error) return <div className="error">Error: {error.message}</div>;

  // Находим выбранный номер
  const selectedRoom = data?.hotels
    .flatMap(hotel => hotel.rooms)
    .find(room => room.id === selectedRoomId);

  return (
    <div className="app">
      <header className="app-header">
        <h1>🏨 Mini Booking System</h1>
        <button onClick={() => refetch()} className="refresh-btn">
          🔄 Refresh
        </button>
      </header>

      <div className="app-content">
        {/* Левая панель - список отелей */}
        <div className="hotels-panel">
          <HotelList 
            hotels={data?.hotels || []} 
            onRoomSelect={setSelectedRoomId}
            selectedRoomId={selectedRoomId}
          />
        </div>

        {/* Правая панель - детали номера */}
        <div className="details-panel">
          {selectedRoom ? (
            <RoomDetails 
              room={selectedRoom} 
              onBookingChange={() => refetch()}
              onClose={() => setSelectedRoomId(null)}
            />
          ) : (
            <div className="no-selection">
              <p>👈 Select a room to view details and manage bookings</p>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

export default App;
