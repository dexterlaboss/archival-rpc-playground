#!/bin/bash

# Define the full path to your HBase installation directory
HBASE_HOME="/opt/hbase"

# Function to handle signals
function handle_signal {
    echo "Caught termination signal. Stopping HBase and script..."
    $HBASE_HOME/bin/hbase-daemon.sh stop master
    exit 1
}

# Trap SIGINT and SIGTERM signals to handle clean exit
trap handle_signal SIGINT SIGTERM

# Start HBase using the built-in daemon script
echo "Starting HBase..."
$HBASE_HOME/bin/hbase-daemon.sh start master

# Wait for HBase to be ready by calling the separate script
if /usr/local/bin/wait-for-hbase.sh; then
    echo "HBase is ready!"
    exit 0
else
    echo "HBase did not start within the expected time." >&2
    $HBASE_HOME/bin/hbase-daemon.sh stop master
    exit 1
fi
