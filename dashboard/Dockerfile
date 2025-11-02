FROM flutter:latest AS builder

WORKDIR /app

COPY . .

RUN flutter pub get

RUN flutter build web --release --web-renderer=html

FROM nginx:alpine

COPY --from=builder /app/build/web /usr/share/nginx/html

COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 3001

CMD ["nginx", "-g", "daemon off;"]