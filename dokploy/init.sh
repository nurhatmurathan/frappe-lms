#!/bin/bash

# Check if frappe-bench already exists
if [ -d "/home/frappe/frappe-bench/apps/frappe" ]; then
    echo "Bench already exists, skipping init"
    cd frappe-bench
    bench start
else
    echo "Creating new bench..."
fi

# Set PATH using environment variables
export PATH="${NVM_DIR}/versions/node/v${NODE_VERSION_DEVELOP}/bin/:${PATH}"

# Initialize bench
bench init --skip-redis-config-generation frappe-bench

cd frappe-bench

# Use environment variables for hosts and ports
bench set-mariadb-host "${MARIADB_HOST:-mariadb}"
bench set-redis-cache-host "${REDIS_CACHE_HOST:-redis:6379}"
bench set-redis-queue-host "${REDIS_QUEUE_HOST:-redis:6379}"
bench set-redis-socketio-host "${REDIS_SOCKETIO_HOST:-redis:6379}"

# Remove redis, watch from Procfile
sed -i '/redis/d' ./Procfile
sed -i '/watch/d' ./Procfile

# Install app and configure site
bench get-app https://github.com/nurhatmurathan/frappe-lms.git

bench new-site lms.localhost \
--mariadb-root-password "${MARIADB_ROOT_PASSWORD:-123}" \
--admin-password "${ADMIN_PASSWORD:-admin}" \
--no-mariadb-socket \
--db-name "${DB_NAME:-frappe-lms}" \
--db-user "${DB_USER:-user}" \
--db-password "${DB_PASS:-pass}" \
--db-host "${DB_HOST:-mariadb}" \
--db-port "${DB_PORT:-3306}"

bench --site lms.localhost install-app lms
bench --site lms.localhost set-config developer_mode 1
bench --site lms.localhost clear-cache
bench use lms.localhost

bench start
