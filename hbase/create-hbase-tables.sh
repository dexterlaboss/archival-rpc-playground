#!/bin/bash

# Function to check if an HBase table exists
function create_table_if_not_exists {
    local table_name=$1
    local column_family=$2

    # Check if the table exists
    echo "Checking if table '$table_name' exists..."
    echo "exists '$table_name'" | /opt/hbase/bin/hbase shell -n 2>/dev/null | grep -q "Table $table_name does exist"

    if [ $? -eq 0 ]; then
        echo "Table '$table_name' already exists. Skipping creation."
    else
        echo "Table '$table_name' does not exist. Creating..."
        # Suppress output during table creation
        echo "create '$table_name', '$column_family'" | /opt/hbase/bin/hbase shell -n > /dev/null 2>&1
        echo "Table '$table_name' created."
    fi
}

# Create HBase tables if they don't exist
create_table_if_not_exists "blocks" "x"
create_table_if_not_exists "tx" "x"
create_table_if_not_exists "tx-by-addr" "x"
create_table_if_not_exists "tx_full" "x"

echo "HBase table creation process completed."

exit 0
