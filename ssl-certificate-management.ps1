# Define the log file path
$logPath = "C:\logs\service-script.log"

# Define Thumbprint variable
$certThumbprint = (Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object { $_.Subject -like "*claims*" } | Select-Object -ExpandProperty Thumbprint)

# Replace YourGuidHere with your own GUID
$yourGuid = "{000f91b5-e23b-4003-92b9-48dec740909b}"

# Define netsh Add command
$netshAddCommand = "netsh http add sslcert ipport=0.0.0.0:9443 certhash=$certThumbprint appid='$yourGuid'"

# Defin the netsh Delete command
$netshDeleteCommand = "netsh http delete sslcert ipport=0.0.0.0:9443"

function Write-Log {
    param([string]$message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "$timestamp - $message"
    $logMessage | Out-File -Append -FilePath $logPath
}

function logBeforeDeleteBindings {
	# Specify the log file path
	$logFile = "C:\logs\service-script.log"

	# Run the netsh command and capture the output
	$netshOutput = netsh http show sslcert ipport=0.0.0.0:9443

	# Define a function to parse the netsh output into a custom object
	function Parse-NetshOutput {
		param (
			[string]$output
		)

		$properties = @{}
		$lines = $output -split "`r`n" | ForEach-Object { $_.Trim() }

		foreach ($line in $lines) {
			if ($line -match '^(\S+)(?:\s*:\s*|\s{2,})(.*)$') {
				$property = $matches[1].Trim()
				$value = $matches[2].Trim()
				$properties[$property] = $value
			}
		}

		return New-Object PSObject -Property $properties
	}

	# Parse the netsh output into a custom object
	$netshData = Parse-NetshOutput -output $netshOutput

	# Display the formatted data on the terminal (optional)
	Write-Host "Formatted Data:"
	$netshData | Format-List

	# Write the formatted data to the log file
	$netshData | Format-List | Out-File -FilePath $logFile -Append

}

function deleteSageBinding {
	Write-Log "Removing current Sage binding from port 9443"
	Write-Log "Execute the netsh delete command using Invoke-Expression"
    Invoke-Expression -Command $netshDeleteCommand
	Write-log "$netshDeleteCommand -- has successfully run."
}

function f.lastExitCode {
	if ($LASTEXITCODE -eq 0) {
            Write-Host "SSL certificate binding was successful."
            # Log success message to the log file
            Write-Log "SSL certificate binding was successful."
        } else {
            Write-Host "SSL certificate binding failed."
            # Log failure message to the log file
            Write-Log "SSL certificate binding failed."
        }
}

function restartSage {
	Restart-Service SagePeoplePublicAPIService.exe
}

function startScript {
	
}

function e.catch {
	# Handle exceptions and log them to the log file
    $errorMessage = "An error occurred: $_"
    Write-Host $errorMessage
    Write-Log $errorMessage
}

function serviceInfo {
	# Sleep for 5 seconds
	Start-Sleep -Seconds 10
	# Display additional information about the service
	Write-Log "Service information:"
	#$service | Format-List | ForEach-Object { Write-Log $_ }
	$serviceInfo = @"
###########################################################
###################   Name                : $($service.Name)
###################   DisplayName         : $($service.DisplayName)
###################   Status              : $($service.Status)
###################   DependentServices   : $($service.DependentServices)
###################   ServicesDependedOn  : $($service.ServicesDependedOn)
###################   CanPauseAndContinue : $($service.CanPauseAndContinue)
###################   CanShutdown         : $($service.CanShutdown)
###################   CanStop             : $($service.CanStop)
###################   ServiceType         : $($service.ServiceType)
#################################################################################
"@ 
	Write-Log $serviceInfo
}

Write-Log "###########################################################"
Write-Log "Starting script"
Write-log "View current binding on port 9443"
logBeforeDeleteBindings
Write-Log "# Get the certificate thumbprint and store it in a variable"
Write-Log "$certThumbprint"

Write-Log "Construct the delete netsh command as a string"
Write-Log "Running $netshDeleteCommand"
deleteSageBinding

Write-Log "Construct the add netsh command as a string"
Write-Log "$netshAddCommand"
	
try {
	logBeforeDeleteBindings
    Write-Log "Check if the certificate thumbprint was found"
    if ($certThumbprint -ne $null) {
        Write-Log "Execute the netsh command using Invoke-Expression"
        Invoke-Expression -Command $netshAddCommand

        Write-Log "Check the exit code to determine success or failure"
		f.lastExitCode
		Write-Log "Restarting the Sage300 ESS modules"
		restartSage
    } else {
        Write-Host "Certificate not found or the search pattern did not match any certificates."
        # Log message to the log file
        Write-Log "Certificate not found or the search pattern did not match any certificates."
    }
	serviceInfo
} catch {
	e.catch
}
