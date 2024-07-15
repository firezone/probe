#!/bin/sh

set -e

test_interval=0.7
payload_interval=0.1

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

# Function to send payloads
send_payload() {
    payload=$1
    for i in 1 2 3; do
        echo "$payload" | base64 -d | nc -u -w 0 "$host" "$port"
        sleep $payload_interval
    done
}

# Fetch the port and payloads to test with
init_data=$(curl --fail -4 -fsSL -H 'Accept: text/plain' -XPOST "$1/start")

# Parse space-delimited input
set -- $init_data
port="$1"
host="$2"
hs_init="$3"
hs_response="$4"
cookie_reply="$5"
data_message="$6"
turn_hs_init="$7"
turn_hs_response="$8"
turn_cookie_reply="$9"
turn_data_message="${10}"

if [ -z "$port" ]; then
    echo "Failed to get a valid port from $run_url"
    exit 1
fi

echo "Running test against port $port..."

# Run the test, sending each payload 3 times. It's UDP, after all.
send_payload "$hs_init"
sleep $test_interval
echo "."
send_payload "$turn_hs_init"
sleep $test_interval
echo "."
send_payload "$hs_response"
sleep $test_interval
echo "."
send_payload "$turn_hs_response"
sleep $test_interval
echo "."
send_payload "$cookie_reply"
sleep $test_interval
echo "."
send_payload "$turn_cookie_reply"
sleep $test_interval
echo "."
send_payload "$data_message"
sleep $test_interval
echo "."
send_payload "$turn_data_message"
sleep $test_interval

curl -4 -fsSL -H 'Accept: text/plain' -XPOST "$run_url/complete"

echo "Done! Test completed. View your results at $run_url"
