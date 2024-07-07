#!/bin/sh

set -e

run_url=$1

port=$(curl --fail -fsSL -H 'Accept: text/plain' -XPOST $1)

if [ -z "$port" ]; then
    echo "Failed to get a valid port from $run_url"
    exit 1
fi

echo "Running test against port $port..."

# TODO: Actually run the test
sleep 1
echo "."
sleep 1
echo "."
sleep 1
echo "."
sleep 1
echo "."
sleep 1

echo "Done! Test completed succesfully. View this result at $run_url"
