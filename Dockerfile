# Etapa 1: Instalación de dependencias
FROM node:lts as dependencies
WORKDIR /twitter-util-service
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

# Etapa 2: Reconstrucción del código fuente
FROM node:lts as builder
WORKDIR /twitter-util-service
COPY . .
COPY --from=dependencies /twitter-util-service/node_modules ./node_modules
RUN yarn build

# Generación de Prisma
RUN npx prisma generate

# Etapa 3: Imagen de Producción
FROM node:lts as runner
WORKDIR /twitter-util-service
ENV NODE_ENV production

# Copia del archivo next.config.js (personalizado)
COPY --from=builder /twitter-util-service/next.config.js ./

# Copia de otros archivos necesarios
COPY --from=builder /twitter-util-service/public ./public
COPY --from=builder /twitter-util-service/.next ./.next
COPY --from=builder /twitter-util-service/node_modules ./node_modules
COPY --from=builder /twitter-util-service/package.json ./package.json

EXPOSE 3000
CMD ["yarn", "start"]
