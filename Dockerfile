FROM ruby:4.0.0-slim

ENV RAILS_ENV=production \
    RAILS_LOG_TO_STDOUT=1 \
    RAILS_LOG_LEVEL=info \
    BUNDLE_PATH=/usr/local/bundle \
    RAILS_SERVE_STATIC_FILES=true

RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    postgresql-client \
    imagemagick \
    libmagick++-dev \
    libyaml-dev \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

RUN curl -sL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get update && apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

RUN gem install bundler

WORKDIR /citadel

COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs 4 --retry 3 --without development test

COPY . .

RUN SECRET_KEY_BASE=dummy-key-for-precompilation \
    bundle exec rake assets:precompile

EXPOSE 3000

ENTRYPOINT ["/citadel/docker-entrypoint.sh"]
