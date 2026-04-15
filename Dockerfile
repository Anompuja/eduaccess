# ── Stage 1: Build Flutter Web ──────────────────────────────────────────────
FROM ghcr.io/cirruslabs/flutter:stable AS builder

WORKDIR /app

# Copy dependency files first for better layer caching
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Copy the rest of the source
COPY . .

# Build release web output
RUN flutter build web --release --web-renderer canvaskit --no-wasm-dry-run

# ── Stage 2: Serve with nginx ────────────────────────────────────────────────
FROM nginx:alpine

# Copy compiled web assets
COPY --from=builder /app/build/web /usr/share/nginx/html

# Copy custom nginx config (SPA fallback routing)
COPY docker/nginx/default.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
