
# Import configuration variables
. "..\settings\config.ps1"
# Define the device name pattern to identify the Kindle
#$deviceNamePattern = "*Kindle*"
#$scriptPath = "c:\scribe\script\"

# Initialize Shell.Application COM object
$shell = New-Object -ComObject Shell.Application
$connected = $false;
Write-Host "Watching for Kindle Scribe..." -ForegroundColor Yellow
Write-Host "Connect your device with a USB cable to sync your notebooks." -ForegroundColor Blue
while($true)
{
    # Find the Kindle Scribe device
    $kindleDevice = $shell.NameSpace("shell:::{20D04FE0-3AEA-1069-A2D8-08002B30309D}").Items() |
        Where-Object { $_.Name -like $deviceNamePattern }

    if ($kindleDevice -eq $null) {
        if($connected)
        {
             $connected = $false;
             Write-Host "Kindle Scribe disconnection detected" -ForegroundColor Red
        }
       
        
    }
    else
    {
        if( $connected -eq $false)
        {
            Write-Host "Kindle Scribe connection detected" -ForegroundColor Green	
            #Scribe plugged in, start sync process
            $scriptToRun = "${scriptPath}export_from_scribe.ps1"
            & $scriptToRun
			if ($updateLogSeq -eq "Yes") {
				$scriptToRun = "${scriptPath}add_to_logseq.ps1"
				& $scriptToRun
			}
            $connected = $true;
        }

    }

    # Wait for a while before checking again
    Start-Sleep -Seconds 5
}