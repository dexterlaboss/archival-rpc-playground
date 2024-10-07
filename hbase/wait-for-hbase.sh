#!/bin/bash

# Function to handle signals
function handle_signal {
    echo "Caught termination signal. Exiting wait-for-hbase script..."
    exit 1
}

# Trap SIGINT and SIGTERM signals
trap handle_signal SIGINT SIGTERM

# Function to check if HBase is ready
function check_hbase_ready {
    echo "Checking if HBase is ready..."
    for i in {1..30}; do
        echo "status" | /opt/hbase/bin/hbase shell -n 2>/dev/null | grep -q "active master" && return 0
        echo "HBase is not ready, waiting..."
        sleep 5
    done
    return 1
}

check_hbase_ready
