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

# Відкриваємо необхідні порти
EXPOSE 3000 5173

# Запускаємо сервер та клієнт
CMD ["sh", "-c", "pnpm start --character=characters/my-character.character.json & pnpm start:client"]
