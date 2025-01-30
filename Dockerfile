# Використовуємо повний образ Node.js
FROM node:23.3.0

# Включаємо corepack для роботи з pnpm
RUN corepack enable && corepack prepare pnpm@9.4.0 --activate

# Створюємо робочу директорію
WORKDIR /app

# Копіюємо всі файли проєкту
COPY . .

# Встановлюємо залежності з правильним режимом
RUN pnpm install --shamefully-hoist --no-frozen-lockfile

# Будуємо проєкт
RUN pnpm build

# Копіюємо змінні середовища (якщо їх немає в репозиторії, додайте їх вручну!)
COPY .env.example .env

# Відкриваємо необхідні порти (5173)
EXPOSE 3000 

ENV PORT=3000

# Запускаємо сервер та клієнт
CMD ["sh", "-c", "pnpm start --port=$PORT --character=characters/my-character.character.json & sleep 2 && pnpm start:client --port=$PORT"]
