#!/bin/bash

LOG_DIR="$HOME/logs"

echo "🛑 Stopping Local OpenCHAMI Stack..."

if [ -f "$LOG_DIR/metadata.pid" ]; then
    PID=$(cat "$LOG_DIR/metadata.pid")
    if kill "$PID" 2>/dev/null; then
        echo "✅ Stopped Metadata Service (PID $PID)"
    else
        echo "⚠️  Metadata Service (PID $PID) not found or already stopped."
    fi
    rm "$LOG_DIR/metadata.pid"
fi

if [ -f "$LOG_DIR/boot.pid" ]; then
    PID=$(cat "$LOG_DIR/boot.pid")
    if kill "$PID" 2>/dev/null; then
        echo "✅ Stopped Boot Service (PID $PID)"
    else
        echo "⚠️  Boot Service (PID $PID) not found or already stopped."
    fi
    rm "$LOG_DIR/boot.pid"
fi

if [ -f "$LOG_DIR/node.pid" ]; then
    PID=$(cat "$LOG_DIR/node.pid")
    if kill "$PID" 2>/dev/null; then
        echo "✅ Stopped Node Service (PID $PID)"
    else
        echo "⚠️  Node Service (PID $PID) not found or already stopped."
    fi
    rm "$LOG_DIR/node.pid"
fi

echo "🧹 Done."
