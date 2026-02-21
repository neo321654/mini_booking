import { Hotel } from '../types';

// Пропсы (props) - это параметры, которые передаются в компонент
interface HotelListProps {
  hotels: Hotel[];
  onRoomSelect: (roomId: string) => void;
  selectedRoomId: string | null;
}

// Компонент для отображения списка отелей и их номеров
function HotelList({ hotels, onRoomSelect, selectedRoomId }: HotelListProps) {
  return (
    <div className="hotel-list">
      <h2>Hotels & Rooms</h2>
      
      {hotels.map(hotel => (
        // key - уникальный идентификатор для React (для оптимизации)
        <div key={hotel.id} className="hotel-card">
          <h3>{hotel.name}</h3>
          
          <div className="rooms-list">
            {hotel.rooms.map(room => {
              // Считаем количество броней для каждого номера
              const bookingsCount = room.bookings.length;
              const isSelected = room.id === selectedRoomId;
              
              return (
                <button
                  key={room.id}
                  className={`room-item ${isSelected ? 'selected' : ''}`}
                  onClick={() => onRoomSelect(room.id)}
                >
                  <span className="room-name">{room.name}</span>
                  <span className="bookings-badge">
                    {bookingsCount} {bookingsCount === 1 ? 'booking' : 'bookings'}
                  </span>
                </button>
              );
            })}
          </div>
        </div>
      ))}
    </div>
  );
}

export default HotelList;
