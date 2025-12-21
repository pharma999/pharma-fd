# =========================
# Stage 1: Build Flutter Web
# =========================
FROM ghcr.io/cirruslabs/flutter:stable AS builder

WORKDIR /app

# Copy source code
COPY . .

# Enable Flutter web
RUN flutter config --enable-web

# Show Flutter environment (for logs)
RUN flutter doctor -v

# Install dependencies
RUN flutter pub get

# Build Flutter Web (NO web-renderer flag)
RUN flutter build web

# =========================
# Stage 2: Serve with Nginx
# =========================
FROM nginx:alpine

# Remove default nginx content
RUN rm -rf /usr/share/nginx/html/*

# Copy Flutter web build output
COPY --from=builder /app/build/web /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
