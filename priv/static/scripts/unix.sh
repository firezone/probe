#!/usr/bin/env sh

set -e

payload_interval=0.2

# Check for required commands
for cmd in base64 sleep curl; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "Error: $cmd command not found"
        exit 1
    fi
done

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

# Determine the appropriate base64 option for decoding
base64_option="-d"
if base64 --help 2>&1 | grep -q "D"; then
    base64_option="-D"
fi

# Determine the appropriate nc options
nc_cmd="nc"
nc_options="-4 -u -w 0"

# Check for GNU netcat
if nc --help 2>&1 | grep -q "GNU"; then
    echo "GNU netcat detected"
    nc_options="-u -c"

# Check for OpenBSD netcat
elif nc -h 2>&1 | grep -q "OpenBSD"; then
    echo "OpenBSD netcat detected"
    # Keep the default options

# Check for ncat from Nmap
elif nc -h 2>&1 | grep -q "Ncat"; then
    echo "Nmap netcat (ncat) detected"
    nc_cmd="ncat"
    nc_options="--udp --send-only"

elif netcat --help 2>&1 | grep -q "GNU"; then
    echo "GNU netcat detected"
    nc_cmd="netcat"
    nc_options="-u -c"

# Check for OpenBSD netcat
elif netcat -h 2>&1 | grep -q "OpenBSD"; then
    echo "OpenBSD netcat detected"
    nc_cmd="netcat"
    # Keep the default options

# If none of the above, keep the default options
fi

if ! command -v "$nc_cmd" >/dev/null 2>&1; then
    echo "Error: $nc_cmd command not found"
    exit 1
fi

echo "Using $nc_cmd with options: $nc_options"

# Function to send payloads
send_payload() {
    printf '%s' "."

    payload="$1"

    # Loop to send the payload
    for i in 1 2 3; do
        echo "$payload" | base64 "$base64_option" | $nc_cmd $nc_options "$host" "$port"
        sleep $payload_interval
    done
}

# Fetch the port and payloads to test with
init_data=$(curl --silent --location --header 'Accept: text/plain' --request POST "$start_url/start")

if echo "$init_data" | grep -q "Error: "; then
    echo "$init_data"
    exit 1
fi

if [ -z "$init_data" ]; then
    echo "Failed to get valid test data from the server. Exiting."
    exit 1
fi

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

# Run the test, sending each payload 3 times. It's UDP, after all.
send_payload "$hs_init"
send_payload "$turn_hs_init"
send_payload "$hs_response"
send_payload "$turn_hs_response"
send_payload "$cookie_reply"
send_payload "$turn_cookie_reply"
send_payload "$data_message"
send_payload "$turn_data_message"

echo ""
echo ""

curl -sL -H 'Accept: text/plain' -XPOST "$run_url/complete"

echo "Done! Test completed. Results:"
echo
curl -sL -H 'Accept: text/plain' "$run_url"
