#!/bin/sh

set -e

payload_interval=0.2

# This script is intended to run from https://probe.sh and requires a valid
# token to start. NOTE: Unfortunately only IPv4 is supported at this time.
start_url=$1

# Cancel the test if a problem occurs. Avoids skewing results if the user cancels
# or some issue unrelated to the network occurs.
cancel() {
    if [ "$?" -ne 0 ]; then
        curl --silent --location --header 'Accept: text/plain' --request POST "$run_url/cancel"
    fi
}
trap cancel EXIT

# Function to send payloads
send_payload() {
    payload=$1
    for i in 1 2 3 4 5; do
        echo "$payload" | base64 -d | nc -u -w 0 "$host" "$port"
        sleep $payload_interval
    done
}

# Fetch the port and payloads to test with
init_data=$(curl --fail --silent --location --header 'Accept: text/plain' --request POST "$start_url/start")

# Parse space-delimited input
set -- $init_data
run_url="$1"
port="$2"
host="$3"
hs_init="$4"
hs_response="$5"
cookie_reply="$6"
data_message="$7"
turn_hs_init="$8"
turn_hs_response="$9"
turn_cookie_reply="${10}"
turn_data_message="${11}"

if [ -z "$port" ]; then
    echo "Failed to get a valid port from test data. Exiting."
    exit 1
fi

echo "Running test against port $port..."

# Run the test, sending each payload 5 times. It's UDP, after all.
send_payload "$hs_init"
echo "."
send_payload "$turn_hs_init"
echo "."
send_payload "$hs_response"
echo "."
send_payload "$turn_hs_response"
echo "."
send_payload "$cookie_reply"
echo "."
send_payload "$turn_cookie_reply"
echo "."
send_payload "$data_message"
echo "."
send_payload "$turn_data_message"

# Wait for test to complete
echo "Waiting for test to complete..."
counter=0
max_retries=10
while [ $counter -lt $max_retries ]; do
    status=$(curl --location --silent --header 'Accept: text/plain' --request GET "$run_url/status")

    echo $status

    if [ "$status" == "done" ]; then
        break
    fi

    sleep 1
    echo "."
    counter=$((counter + 1))
done

if [ $counter -eq $max_retries ]; then
    echo "Test did not complete in time. Exiting."
    exit 1
else
    echo "Results:"
    echo
    curl --fail --silent --location --header 'Accept: text/plain' "$run_url"
fi
