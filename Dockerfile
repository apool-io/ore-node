FROM rust:1.80.1-slim-bullseye
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

ENV PATH="/root/.cargo/bin:$PATH"

RUN apt-get update && apt-get install -y \
    curl \
    build-essential \
    libssl-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

RUN curl -sSfL https://release.solana.com/v1.18.4/solana-release-x86_64-unknown-linux-gnu.tar.bz2 | tar -xj \
    && mv solana-release/bin/solana /usr/local/bin/ \
    && mv solana-release/bin/solana-keygen /usr/local/bin/ \
    && rm -rf solana-release

RUN cargo install ore-cli

RUN mkdir -p /app/ore
RUN mkdir -p /var/log/ore-node
RUN mkdir -p /root/.config/solana

WORKDIR /app/ore

CMD ["tail", "-f", "/dev/null"]
