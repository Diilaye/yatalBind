FROM cirrusci/flutter:latest AS flutter_builder

WORKDIR /app

COPY . .

RUN flutter pub get

RUN flutter build web --release --web-renderer=html

FROM node:20-alpine

WORKDIR /app

COPY package.json package-lock.json ./

RUN npm ci --only=production

COPY app.js ./

COPY --from=flutter_builder /app/build/web ./public

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost/ || exit 1

CMD ["node", "app.js"]
