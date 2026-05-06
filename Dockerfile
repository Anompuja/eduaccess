# ── Stage 1: Build Flutter Web ──────────────────────────────────────────────
FROM ghcr.io/cirruslabs/flutter:stable AS builder


ENV FLUTTER_ALLOW_ROOT=true

WORKDIR /app

# Copy dependency files first for better layer caching
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Copy the rest of the source
COPY . .

# Build release web output
RUN flutter build web --release

# ── Stage 2: Serve with nginx ────────────────────────────────────────────────
FROM nginx:alpine

# Copy compiled web assets
COPY --from=builder /app/build/web /usr/share/nginx/html

# Copy custom nginx config (SPA fallback routing)
COPY docker/nginx/default.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
