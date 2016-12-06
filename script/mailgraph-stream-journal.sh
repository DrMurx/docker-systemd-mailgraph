#! /bin/bash

# Filter the journal for this particular unit file
JOURNAL_FILTER_UNIT="${JOURNAL_UNIT:-docker.service}"

# Filter the journal for this container
JOURNAL_FILTER_CONTAINER="${JOURNAL_FILTER_CONTAINER:-mail}"

# Additional options to journalctl
JOURNAL_OPTS="${JOURNAL_OPTS:-}"

# Starting point in the journal, can be any absolute or relative timestamp `strtotime` is able to parse.
JOURNALD_START_AT="${JOURNALD_START_AT:-$(test -e /var/lib/mailgraph/mailgraph.rrd && date -r /var/lib/mailgraph/mailgraph.rrd)}"

# `jq` transformation string turning the journal into a syslog compatible format
JSON_PROCESSING="${JSON_PROCESSING:-((.__REALTIME_TIMESTAMP | tonumber) / 1000000 | gmtime | strftime(\"%b %d %H:%M:%S\") | tostring) + \" \" + (.MESSAGE | sub(\"^[0-9T:.+-]+ \"; \"\"))}"


chown -R www-data:www-data /var/lib/mailgraph/

# Trap to kill the background processes if this script is signalled to terminate
trap 'kill $(jobs -p);' SIGHUP SIGINT SIGTERM

LANG=C

/bin/journalctl -D /app/journal/ \
                --no-pager -q -f \
                ${JOURNALD_START_AT:+-S "$JOURNALD_START_AT"} \
                -o json \
                -u "${JOURNAL_FILTER_UNIT}" ${JOURNAL_OPTS} CONTAINER_NAME="${JOURNAL_FILTER_CONTAINER}" \
  | jq -r "${JSON_PROCESSING}" \
  | /usr/sbin/mailgraph --daemon-rrd=/var/lib/mailgraph --cat --logfile=- &

/etc/init.d/fcgiwrap start
/etc/init.d/nginx start

wait
