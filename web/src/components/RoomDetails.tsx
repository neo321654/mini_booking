import { useState } from 'react';
import { useMutation } from '@apollo/client';
import { Room } from '../types';
import { CREATE_BOOKING, CANCEL_BOOKING, CHECK_AVAILABILITY } from '../graphql/mutations';

interface RoomDetailsProps {
  room: Room;
  onBookingChange: () => void;
  onClose: () => void;
}

// Компонент для отображения деталей номера и управления бронями
function RoomDetails({ room, onBookingChange, onClose }: RoomDetailsProps) {
  // Состояния для формы бронирования
  const [startDate, setStartDate] = useState('');
  const [endDate, setEndDate] = useState('');
  const [message, setMessage] = useState<{ type: 'success' | 'error', text: string } | null>(null);

  // useMutation - Apollo hook для выполнения мутаций (изменения данных)
  const [checkAvailability, { loading: checkingAvailability }] = useMutation(CHECK_AVAILABILITY);
  const [createBooking, { loading: creatingBooking }] = useMutation(CREATE_BOOKING);
  const [cancelBooking, { loading: cancellingBooking }] = useMutation(CANCEL_BOOKING);

  // Функция для проверки доступности
  const handleCheckAvailability = async () => {
    if (!startDate || !endDate) {
      setMessage({ type: 'error', text: 'Please select both dates' });
      return;
    }

    try {
      const { data } = await checkAvailability({
        variables: { roomId: room.id, startDate, endDate }
      });

      if (data.checkAvailability) {
        setMessage({ type: 'success', text: '✅ Room is available for these dates!' });
      } else {
        setMessage({ type: 'error', text: '❌ Room is not available for these dates' });
      }
    } catch (error: any) {
      setMessage({ type: 'error', text: error.message });
    }
  };

  // Функция для создания брони
  const handleCreateBooking = async () => {
    if (!startDate || !endDate) {
      setMessage({ type: 'error', text: 'Please select both dates' });
      return;
    }

    try {
      await createBooking({
        variables: { roomId: room.id, startDate, endDate }
      });

      setMessage({ type: 'success', text: '✅ Booking created successfully!' });
      setStartDate('');
      setEndDate('');
      
      // Обновляем список броней
      setTimeout(() => {
        onBookingChange();
        setMessage(null);
      }, 1500);
    } catch (error: any) {
      setMessage({ type: 'error', text: error.message });
    }
  };

  // Функция для отмены брони
  const handleCancelBooking = async (bookingId: string) => {
    if (!confirm('Are you sure you want to cancel this booking?')) {
      return;
    }

    try {
      await cancelBooking({
        variables: { bookingId }
      });

      setMessage({ type: 'success', text: '✅ Booking cancelled successfully!' });
      
      // Обновляем список броней
      setTimeout(() => {
        onBookingChange();
        setMessage(null);
      }, 1500);
    } catch (error: any) {
      setMessage({ type: 'error', text: error.message });
    }
  };

  // Форматируем дату для отображения
  const formatDate = (timestamp: string) => {
    const date = new Date(parseInt(timestamp));
    return date.toLocaleDateString('en-US', { 
      year: 'numeric', 
      month: 'short', 
      day: 'numeric' 
    });
  };

  return (
    <div className="room-details">
      <div className="details-header">
        <h2>{room.name}</h2>
        <button onClick={onClose} className="close-btn">✕</button>
      </div>

      {/* Форма для создания брони */}
      <div className="booking-form">
        <h3>Create New Booking</h3>
        
        <div className="form-group">
          <label>Start Date:</label>
          <input
            type="date"
            value={startDate}
            onChange={(e) => setStartDate(e.target.value)}
            min={new Date().toISOString().split('T')[0]}
          />
        </div>

        <div className="form-group">
          <label>End Date:</label>
          <input
            type="date"
            value={endDate}
            onChange={(e) => setEndDate(e.target.value)}
            min={startDate || new Date().toISOString().split('T')[0]}
          />
        </div>

        <div className="form-actions">
          <button 
            onClick={handleCheckAvailability}
            disabled={checkingAvailability || !startDate || !endDate}
            className="btn-secondary"
          >
            {checkingAvailability ? 'Checking...' : 'Check Availability'}
          </button>

          <button 
            onClick={handleCreateBooking}
            disabled={creatingBooking || !startDate || !endDate}
            className="btn-primary"
          >
            {creatingBooking ? 'Creating...' : 'Create Booking'}
          </button>
        </div>

        {/* Сообщения об успехе/ошибке */}
        {message && (
          <div className={`message ${message.type}`}>
            {message.text}
          </div>
        )}
      </div>

      {/* Список существующих броней */}
      <div className="bookings-section">
        <h3>Existing Bookings ({room.bookings.length})</h3>
        
        {room.bookings.length === 0 ? (
          <p className="no-bookings">No bookings yet</p>
        ) : (
          <div className="bookings-list">
            {room.bookings.map(booking => (
              <div key={booking.id} className="booking-card">
                <div className="booking-info">
                  <span className="booking-dates">
                    📅 {formatDate(booking.startDate)} → {formatDate(booking.endDate)}
                  </span>
                  <span className="booking-id">ID: {booking.id.slice(0, 8)}...</span>
                </div>
                <button
                  onClick={() => handleCancelBooking(booking.id)}
                  disabled={cancellingBooking}
                  className="btn-danger"
                >
                  Cancel
                </button>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}

export default RoomDetails;
