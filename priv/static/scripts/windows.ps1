# This script is intended to run from https://probe.sh and requires a valid
# token to start. NOTE: Unfortunately only IPv4 is supported at this time.

$payload_interval = 200

# Function to send payloads
function Send-Payload {
    param (
        [string]$payload,
        [string]$probe_host,
        [int]$port
    )

    for ($i = 0; $i -lt 5; $i++) {
        $udpClient = New-Object System.Net.Sockets.UdpClient
        $bytes = [System.Convert]::FromBase64String($payload)
        try {
            $udpClient.Connect($probe_host, $port)
            $sentBytes = $udpClient.Send($bytes, $bytes.Length) > $null
        } catch {
            Write-Host "Error sending payload: $_"
        } finally {
            $udpClient.Close()
            Start-Sleep -Milliseconds $payload_interval
        }
    }
}

# Cancel the test if a problem occurs. Avoids skewing results if the user cancels
# or some issue unrelated to the network occurs.
try {
    # Fetch the port and payloads to test with
    $init_data = Invoke-RestMethod -Method Post -Uri "$start_url/start" -Headers @{Accept = 'text/plain'} -UseBasicParsing

    # Parse space-delimited input
    $data = $init_data -split "`n"

    $run_url = $data[0]
    $port = [int]$data[1]
    $probe_host = $data[2]
    $hs_init = $data[3]
    $hs_response = $data[4]
    $cookie_reply = $data[5]
    $data_message = $data[6]
    $turn_hs_init = $data[7]
    $turn_hs_response = $data[8]
    $turn_cookie_reply = $data[9]
    $turn_data_message = $data[10]

    if (-not $port) {
        Write-Host "Failed to get a valid port from $start_url"
        exit 1
    }

    Write-Host "Running test against host $probe_host port $port..."

    # Run the test, sending each payload 5 times. It's UDP, after all.
    Send-Payload -payload $hs_init -probe_host $probe_host -port $port
    Write-Host "."
    Send-Payload -payload $turn_hs_init -probe_host $probe_host -port $port
    Write-Host "."
    Send-Payload -payload $hs_response -probe_host $probe_host -port $port
    Write-Host "."
    Send-Payload -payload $turn_hs_response -probe_host $probe_host -port $port
    Write-Host "."
    Send-Payload -payload $cookie_reply -probe_host $probe_host -port $port
    Write-Host "."
    Send-Payload -payload $turn_cookie_reply -probe_host $probe_host -port $port
    Write-Host "."
    Send-Payload -payload $data_message -probe_host $probe_host -port $port
    Write-Host "."
    Send-Payload -payload $turn_data_message -probe_host $probe_host -port $port

# Wait for test to complete
    Write-Output "Waiting for test to complete..."
    $counter = 0
    $max_attempts = 10
    while ($counter -lt $max_attempts) {
        $status = Invoke-RestMethod -Method Get -Uri "$run_url/status" -Headers @{Accept = 'text/plain'} -UseBasicParsing

        if ($status -eq "done") {
            break
        }

        Start-Sleep -Seconds 1
        Write-Output "."
        $counter++
    }

    if ($counter -eq $max_attempts) {
        Write-Output "Test did not complete within time. Exiting."
        exit 1
    }

    $result = Invoke-RestMethod -Method Get -Uri "$run_url" -Headers @{Accept = 'text/plain'} -UseBasicParsing
    Write-Host "Done! Test completed. Results:"
    Write-Host $result
}
catch {
    Invoke-RestMethod -Method Post -Uri "$run_url/cancel" -Headers @{Accept = 'text/plain'} -UseBasicParsing
    throw $_
}
