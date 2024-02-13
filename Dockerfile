# ---------------------------------------------------------#
# Build Release                                            #
# ---------------------------------------------------------#
ARG ELIXIR_VERSION=1.16.1
ARG OTP_VERSION=26.2.2
ARG DEBIAN_VERSION=bullseye-20240130-slim

ARG BUILDER_IMAGE="hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-debian-${DEBIAN_VERSION}"
ARG RUNNER_IMAGE="debian:${DEBIAN_VERSION}"

FROM ${BUILDER_IMAGE} as builder

ENV TZ=America/Sao_Paulo
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && apt-get install -y build-essential git wget ca-certificates && \
    apt-get clean && rm -f /var/lib/apt/lists/*_*

# install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# prepare build dir
WORKDIR /app

# set build ENV
ARG MIX_ENV="prod"
ENV MIX_ENV=${MIX_ENV}

# install mix dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV
RUN mkdir config

# copy compile-time config files before we compile dependencies
# to ensure any relevant config change will trigger the dependencies
# to be re-compiled.
COPY config config/

# Rename config/release.exs to config/runtime.exs to ensure
# that the application will load env vars on start-up
COPY config/release.exs config/runtime.exs

RUN mix deps.compile

COPY priv priv
COPY lib lib

# Compile the release
RUN mix compile

COPY rel rel

RUN mix release --path release

# ---------------------------------------------------------#
# Run Release                                              #
# ---------------------------------------------------------#
FROM ${RUNNER_IMAGE}

RUN apt-get update -y \
 && apt-get install -y libstdc++6 openssl libncurses5 locales tini curl netcat procps dnsutils ca-certificates tzdata \
 && ln -fs /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime \
 && dpkg-reconfigure -f noninteractive tzdata \
 && apt-get clean \
 && rm -f /var/lib/apt/lists/*_*

ENV TZ="America/Sao_Paulo"
ENV DEBIAN_FRONTEND=noninteractive

# Set the locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

WORKDIR "/app"
RUN chown nobody /app

# set runner ENV
ENV MIX_ENV="prod"

# Only copy the final release from the build stage
COPY --from=builder --chown=nobody:root /app/release /app/.

USER nobody

ENTRYPOINT ["/usr/bin/tini", "--"]

CMD ["sh", "-c", "./bin/rinha_backend start"]