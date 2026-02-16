# syntax=docker/dockerfile:1
FROM ruby:4.0-slim

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    curl \
    git \
    libpq-dev \
    libvips \
    node-gyp \
    pkg-config \
    postgresql-client && \
    rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*


WORKDIR /app

COPY Gemfile ./
COPY Gemfile.lock* ./

RUN bundle install

COPY package.json ./
COPY package-lock.json* ./

RUN npm install

COPY . .

RUN chmod +x bin/*

RUN bundle exec bootsnap precompile app/ lib/ || true

EXPOSE 3000 5173

ENTRYPOINT ["./bin/docker-entrypoint"]

CMD ["./bin/rails", "server", "-b", "0.0.0.0"]
