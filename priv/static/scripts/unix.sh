#!/bin/sh

set -e

# This script is intended to run from https://probe.sh and requires a valid
# token to start. NOTE: Unfortunately only IPv4 is supported at this time.
run_url=$1

# Cancel the test if a problem occurs. Avoids skewing results if the user cancels
# or some issue unrelated to the network occurs.
cancel() {
    if [ "$?" -ne 0 ]; then
        curl -4 -fsSL -H 'Accept: text/plain' -XPOST "$run_url/cancel"
    fi
}
trap cancel EXIT

# Fetch the port and payloads to test with
init_data=$(curl -4 -fsSL -H 'Accept: text/plain' -XPOST "$1/start")

# Parse space-delimited input
set -- $init_data
port=$1
host=$2
hs_init=$3
hs_response=$4
cookie_reply=$5
data_message=$6

if [ -z "$port" ]; then
    echo "Failed to get a valid port from $run_url"
    exit 1
fi

echo "Running test against port $port..."

# Run the test, sending each payload 3 times. It's UDP, after all.
for i in 1 2 3; do echo -n $hs_init | base64 -d | nc -u -w 0 $host $port; done
sleep 1
echo "."
for i in 1 2 3; do echo -n $hs_response | base64 -d | nc -u -w 0 $host $port; done
sleep 1
echo "."
for i in 1 2 3; do echo -n $cookie_reply | base64 -d | nc -u -w 0 $host $port; done
sleep 1
echo "."
for i in 1 2 3; do echo -n $data_message | base64 -d | nc -u -w 0 $host $port; done
sleep 1

curl -4 -fsSL -H 'Accept: text/plain' -XPOST "$run_url/complete"

echo "Done! Test completed succesfully. View this result at $run_url"
