# This script is intended to run from https://probe.sh and requires a valid
# token to start. NOTE: Unfortunately only IPv4 is supported at this time.

# Function to send payloads
function Send-Payload {
    param (
        [string]$payload,
        [string]$probe_host,
        [int]$port
    )

    for ($i = 0; $i -lt 3; $i++) {
        $udpClient = New-Object System.Net.Sockets.UdpClient
        $bytes = [System.Convert]::FromBase64String($payload)
        try {
            $udpClient.Connect($probe_host, $port)
            $sentBytes = $udpClient.Send($bytes, $bytes.Length) > $null
        } catch {
            Write-Host "Error sending payload: $_"
        } finally {
            $udpClient.Close()
        }
    }
}

# Cancel the test if a problem occurs. Avoids skewing results if the user cancels
# or some issue unrelated to the network occurs.
try {
    # Fetch the port and payloads to test with
    $init_data = Invoke-RestMethod -Method Post -Uri "$run_url/start" -Headers @{Accept = 'text/plain'} -UseBasicParsing

    # Parse space-delimited input
    $data = $init_data -split "`n"

    $port = [int]$data[0]
    $probe_host = $data[1]
    $hs_init = $data[2]
    $hs_response = $data[3]
    $cookie_reply = $data[4]
    $data_message = $data[5]
    $turn_hs_init = $data[6]
    $turn_hs_response = $data[7]
    $turn_cookie_reply = $data[8]
    $turn_data_message = $data[9]

    if (-not $port) {
        Write-Host "Failed to get a valid port from $run_url"
        exit 1
    }

    Write-Host "Running test against host $probe_host port $port..."

    # Run the test, sending each payload 3 times. It's UDP, after all.
    Send-Payload -payload $hs_init -probe_host $probe_host -port $port
    Start-Sleep -Seconds 1
    Write-Host "."
    Send-Payload -payload $turn_hs_init -probe_host $probe_host -port $port
    Start-Sleep -Seconds 1
    Write-Host "."
    Send-Payload -payload $hs_response -probe_host $probe_host -port $port
    Start-Sleep -Seconds 1
    Write-Host "."
    Send-Payload -payload $turn_hs_response -probe_host $probe_host -port $port
    Start-Sleep -Seconds 1
    Write-Host "."
    Send-Payload -payload $cookie_reply -probe_host $probe_host -port $port
    Start-Sleep -Seconds 1
    Write-Host "."
    Send-Payload -payload $turn_cookie_reply -probe_host $probe_host -port $port
    Start-Sleep -Seconds 1
    Write-Host "."
    Send-Payload -payload $data_message -probe_host $probe_host -port $port
    Start-Sleep -Seconds 1
    Write-Host "."
    Send-Payload -payload $turn_data_message -probe_host $probe_host -port $port
    Start-Sleep -Seconds 1

    Invoke-RestMethod -Method Post -Uri "$run_url/complete" -Headers @{Accept = 'text/plain'} -UseBasicParsing

    Write-Host "Done! Test completed. View this result at $run_url"
}
catch {
    Invoke-RestMethod -Method Post -Uri "$run_url/cancel" -Headers @{Accept = 'text/plain'} -UseBasicParsing
    throw $_
}
