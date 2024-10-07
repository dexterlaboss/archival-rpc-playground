#!/bin/bash

/usr/local/bin/setup.sh

exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
