import React from 'react';
import ReactDOM from 'react-dom/client';
import { ApolloClient, InMemoryCache, ApolloProvider } from '@apollo/client';
import App from './App';

// Создаем Apollo Client для связи с GraphQL API
// uri - адрес нашего backend API
const client = new ApolloClient({
  uri: 'http://localhost:4000/graphql',
  cache: new InMemoryCache(), // Кеш для оптимизации запросов
});

// Рендерим приложение в DOM
// ApolloProvider - оборачивает приложение и предоставляет доступ к Apollo Client
ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <ApolloProvider client={client}>
      <App />
    </ApolloProvider>
  </React.StrictMode>,
);
