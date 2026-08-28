#!/bin/bash
set -e

echo "Preparing database..."
bundle exec rails db:prepare

echo "Starting Puma server..."
exec bundle exec puma -b tcp://0.0.0.0:3000
