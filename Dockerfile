# =========================
# Stage 1: Build Flutter Web
# =========================
FROM ghcr.io/cirruslabs/flutter:3.38.5 AS build

WORKDIR /app

# Enable Flutter web
RUN flutter config --enable-web

# Copy pubspec first (better caching)
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Copy rest of the source
COPY . .

# Build Flutter Web
RUN flutter build web --release

# =========================
# Stage 2: Serve with Nginx
# =========================
FROM nginx:alpine

# Copy build output from previous stage
COPY --from=build /app/build/web /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
