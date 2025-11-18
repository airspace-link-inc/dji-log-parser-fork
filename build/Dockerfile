##########################################################
# Stage 1: build binary
##########################################################
FROM rust:1.86-slim-bullseye AS builder

# Install openssl and other dependencies if needed (e.g., for networking)
RUN apt-get update && apt-get install -y \
    pkg-config \
    libssl-dev \
    make \
    && rm -rf /var/lib/apt/lists/*

# Create working dir to house the source code.
WORKDIR /src

# Add the remaining contents to working dir.
# The .dockerignore file will handle blocking 
# non-essentials.
COPY . .

# Now, build the final release executable
# Use --locked if you want to ensure the Cargo.lock file is up-to-date
RUN cargo build --release

# ##########################################################
# # Stage 2: Move the binary executable to secure container
# ##########################################################
FROM gcr.io/distroless/cc-debian12:nonroot

WORKDIR /

COPY --from=builder --chown=nonroot:nonroot /src/target/release/dji-log /bin
COPY --from=builder --chown=nonroot:nonroot /src/target/release/libdji_log_parser_c.a /bin
COPY --from=builder --chown=nonroot:nonroot /src/dji-log-parser-c/include/dji-log-parser-c.h /bin

ENTRYPOINT ["bin/dji-log"]
