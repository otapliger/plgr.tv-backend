# Build stage
FROM rust:slim AS builder

# Install build dependencies
RUN apt-get update && \
    apt-get install -y pkg-config libssl-dev && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Cargo.toml ./

# Create a dummy main.rs to cache dependencies
RUN mkdir src && \
    echo "fn main() {}" > src/main.rs && \
    cargo build --release && \
    rm -rf src

COPY src ./src
COPY sh ./sh

# Build the actual application
RUN touch src/main.rs && \
    cargo build --release

# Runtime stage
FROM debian:bookworm-slim

RUN apt-get update && \
    apt-get install -y ca-certificates libssl3 && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=builder /app/target/release/plgr_tv-backend /app/plgr_tv-backend
COPY --from=builder /app/sh /app/sh

RUN useradd -m -u 1000 appuser

RUN chown -R appuser:appuser /app

USER appuser

EXPOSE 3000

CMD ["/app/plgr_tv-backend"]
