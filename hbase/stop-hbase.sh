#!/bin/bash

# Define the full path to your HBase installation directory
HBASE_HOME="/opt/hbase"

# Function to handle signals
function handle_signal {
    echo "Caught termination signal. Stopping script..."
    exit 1
}

# Trap SIGINT and SIGTERM signals to handle clean exit
trap handle_signal SIGINT SIGTERM

# Stop HBase
echo "Stopping HBase..."
$HBASE_HOME/bin/stop-hbase.sh

# Function to check if HBase is still running
is_hbase_running() {
    jps | grep -q 'HMaster\|HRegionServer'
}

# Wait until HBase is fully stopped
while is_hbase_running; do
    echo "Waiting for HBase to stop..."
    sleep 5  # Wait for 5 seconds before checking again
done

echo "HBase has stopped successfully."
