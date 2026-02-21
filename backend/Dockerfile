FROM node:20-alpine

WORKDIR /app

# Копируем package files
COPY package*.json ./
COPY prisma ./prisma/

# Устанавливаем зависимости
RUN npm ci

# Копируем исходники
COPY . .

# Генерируем Prisma Client (используем placeholder для DATABASE_URL)
RUN DATABASE_URL="postgresql://placeholder:placeholder@localhost:5432/placeholder" npx prisma generate

# Expose порт
EXPOSE 4000

# Запускаем миграции и seed, затем стартуем сервер
CMD npx prisma migrate deploy && npx prisma db seed && npm run dev
