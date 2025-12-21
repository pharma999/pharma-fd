# =========================
# Stage 1: Build Flutter Web
# =========================
FROM ghcr.io/cirruslabs/flutter:stable AS builder

WORKDIR /app

# Copy source code
COPY . .

# Enable Flutter web explicitly
RUN flutter config --enable-web

# (Optional but very useful) Check Flutter environment
RUN flutter doctor -v

# Get dependencies
RUN flutter pub get

# Build Flutter Web (HTML renderer = most compatible)
RUN flutter build web --web-renderer html

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
