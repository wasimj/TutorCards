# syntax=docker/dockerfile:1
# Multi-stage build for Rails 8.1 + SQLite. Persisted state lives under /rails/storage.

ARG RUBY_VERSION=3.2.3
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

WORKDIR /rails

ENV RAILS_ENV=production \
    BUNDLE_DEPLOYMENT=1 \
    BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_WITHOUT=development:test

# Build stage — compiles native gem extensions and precompiles assets.
FROM base AS build

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git pkg-config libsqlite3-dev libyaml-dev && \
    rm -rf /var/lib/apt/lists/*

COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

COPY . .

# Precompile bootsnap and assets. SECRET_KEY_BASE_DUMMY satisfies Rails' production check at build time.
RUN bundle exec bootsnap precompile app/ lib/ || true
RUN SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile

# Runtime stage — slim image with just what's needed to boot Puma.
FROM base

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libsqlite3-0 && \
    rm -rf /var/lib/apt/lists/*

COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

# Non-root user; owns storage so the volume mount works on first boot.
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    mkdir -p /rails/storage /rails/storage/photos /rails/tmp /rails/log && \
    chown -R rails:rails /rails/db /rails/storage /rails/tmp /rails/log /rails/public

USER rails:rails

EXPOSE 3000
ENTRYPOINT ["/rails/bin/docker-entrypoint"]
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3000"]
