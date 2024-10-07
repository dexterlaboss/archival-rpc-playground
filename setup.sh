#!/bin/bash

/usr/local/bin/start-hbase.sh && \
/usr/local/bin/create-hbase-tables.sh && \
/usr/local/bin/stop-hbase.sh
