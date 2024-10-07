#!/bin/bash

WAIT_FOR_HBASE_SCRIPT="/usr/local/bin/wait-for-hbase.sh"

function handle_signal {
    echo "Caught termination signal. Stopping script..."
    exit 1
}

trap handle_signal SIGINT SIGTERM

echo "Waiting for HBase to be ready..."
if $WAIT_FOR_HBASE_SCRIPT; then
    echo "HBase is ready!"
else
    echo "HBase did not start within the expected time." >&2
    exit 1
fi

echo "Starting ingestor-rpc with arguments: $@"
RUST_LOG=info exec /usr/local/bin/ingestor-rpc "$@"
