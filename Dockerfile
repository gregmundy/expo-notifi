# Use the official Elixir image with the desired version
FROM hexpm/elixir:1.17.3-erlang-27.0.1-debian-bullseye-20241111-slim

# Set the working directory in the container
WORKDIR /app

# Add CA Certificates
RUN apt update
RUN apt install -y ca-certificates

# Copy mix files and install dependencies
COPY mix.exs mix.lock ./
COPY config config
RUN mix local.hex --force && mix local.rebar --force
RUN mix deps.get --only prod
RUN mix deps.compile

# Copy the application code
COPY lib lib

# Compile the Elixir app and build a release
RUN MIX_ENV=prod mix compile
RUN MIX_ENV=prod mix release

# Set environment variables
ENV LANG=C.UTF-8 \
    REPLACE_OS_VARS=true \
    MIX_ENV=prod \
    PORT=4000

# Expose the port the app will run on
EXPOSE 4000

# Set the entry point to start the Phoenix server
CMD ["/app/_build/prod/rel/notifi/bin/notifi", "start"]
