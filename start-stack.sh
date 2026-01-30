#!/bin/bash

# ==========================================
# 🔧 CONFIGURATION - EDIT THESE PATHS
# ==========================================
METADATA_REPO="$HOME/metadata-service/cmd/server"
BOOT_REPO="$HOME/boot-service/cmd/server"
NODE_REPO="$HOME/node-service"
QUICKSTART_DIR="$HOME/deployment-recipes/quickstart"
LOG_DIR="$HOME/logs"

# Ports for your local services
METADATA_PORT=8080
BOOT_PORT=8081
NODE_PORT=8082

# ==========================================
# 1. ENVIRONMENT SETUP
# ==========================================
echo "Drafting environment from Quickstart..."

# Create Log Directory Explicitly
mkdir -p "$LOG_DIR"
echo "📂 Logs will be written to: $LOG_DIR"

if [ ! -f "$QUICKSTART_DIR/.env" ]; then
    echo "❌ Error: Could not find .env file in $QUICKSTART_DIR"
    exit 1
fi

# Load DB secrets from the Quickstart .env
# We use 'set -a' to automatically export variables from the file
set -a
source "$QUICKSTART_DIR/.env"
set +a

# Common Configs
export SMD_URL="http://localhost:27779"
export BSS_DB_HOST="localhost"
export BSS_DB_PORT="5432"
export BSS_DB_USER="$POSTGRES_USER"
export BSS_DB_PASSWORD="$POSTGRES_PASSWORD"
export BSS_DB_NAME="bss" # Default for quickstart

# Node Service Configs
export METADATA_URL="http://localhost:$METADATA_PORT"
export BOOT_URL="http://localhost:$BOOT_PORT"

# ==========================================
# 2. START METADATA SERVICE
# ==========================================
echo "🚀 Starting Metadata Service (Port $METADATA_PORT)..."
cd "$METADATA_REPO" || exit
# Note: Adjust flags if your specific version uses different ones
go run . serve --port $METADATA_PORT > "$HOME/logs/metadata.log" 2>&1 &
METADATA_PID=$!
echo $METADATA_PID > "$HOME/logs/metadata.pid"

# ==========================================
# 3. START BOOT SERVICE
# ==========================================
echo "🚀 Starting Boot Service (Port $BOOT_PORT)..."
cd "$BOOT_REPO" || exit
go run . serve --port $BOOT_PORT > "$HOME/logs/boot.log" 2>&1 &
BOOT_PID=$!
echo $BOOT_PID > "$HOME/logs/boot.pid"

# ==========================================
# 4. START NODE SERVICE
# ==========================================
echo "🚀 Starting Node Service (Port $NODE_PORT)..."
cd "$NODE_REPO" || exit
go run ./cmd/server serve --port $NODE_PORT > "$HOME/logs/node.log" 2>&1 &
NODE_PID=$!
echo $NODE_PID > "$HOME/logs/node.pid"

# ==========================================
# 5. VERIFICATION
# ==========================================
echo "⏳ Waiting 5 seconds for services to initialize..."
sleep 5

echo "--- Health Check ---"
if curl -s "http://localhost:$METADATA_PORT/health" > /dev/null; then
    echo "✅ Metadata Service: UP (PID $METADATA_PID)"
else
    echo "❌ Metadata Service: DOWN (Check logs/metadata.log)"
fi

if curl -s "http://localhost:$BOOT_PORT/health" > /dev/null; then
    echo "✅ Boot Service:     UP (PID $BOOT_PID)"
else
    echo "❌ Boot Service:     DOWN (Check logs/boot.log)"
fi

if curl -s "http://localhost:$NODE_PORT/health" > /dev/null; then
    echo "✅ Node Service:     UP (PID $NODE_PID)"
else
    echo "❌ Node Service:     DOWN (Check logs/node.log)"
fi

echo ""
echo "📝 Logs are streaming to $HOME/logs/"
echo "🛑 Run './stop-stack.sh' to stop all services."
