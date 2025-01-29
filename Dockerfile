# Використання повного Node.js образу
FROM node:23.3.0 AS builder

# Включення Corepack для підтримки pnpm
RUN corepack enable && corepack prepare pnpm@latest --activate

# Встановлення pnpm глобально
RUN npm install -g pnpm@9.4.0

# Оновлення apt та встановлення необхідних пакетів
RUN apt-get update && apt-get install -y \
    git \
    python3 \
    ffmpeg \
    gnupg2 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Встановлення Python 3 як основного
RUN ln -sf /usr/bin/python3 /usr/bin/python

# Створення робочої папки
WORKDIR /app

# Копіюємо код додатку
COPY . .

# Встановлення залежностей
RUN pnpm install --shamefully-hoist --no-frozen-lockfile

# Збірка проєкту
RUN pnpm run build && pnpm prune --prod

# Фінальний образ (легший)
FROM node:23.3.0

# Включення Corepack для підтримки pnpm
RUN corepack enable && corepack prepare pnpm@latest --activate

# Встановлення pnpm глобально
RUN npm install -g pnpm@9.4.0

# Встановлення тільки необхідних пакетів для рантайму
RUN apt-get update && apt-get install -y \
    git \
    python3 \
    ffmpeg && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Встановлення робочої директорії
WORKDIR /app

# Копіюємо зібраний код і залежності
COPY --from=builder /app/package.json ./
COPY --from=builder /app/pnpm-workspace.yaml ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/agent ./agent
COPY --from=builder /app/client ./client
COPY --from=builder /app/lerna.json ./
COPY --from=builder /app/packages ./packages
COPY --from=builder /app/scripts ./scripts
COPY --from=builder /app/characters ./characters

# Відкриття портів
EXPOSE 3000 5173

# Запуск додатку
CMD ["sh", "-c", "pnpm start --character=characters/my-character.character.json & pnpm start:client"]
