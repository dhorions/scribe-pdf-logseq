# Define the device name pattern to identify the Kindle
$deviceNamePattern = "*Kindle*"
$scriptPath = "c:\scribe\script\"

# Initialize Shell.Application COM object
$shell = New-Object -ComObject Shell.Application
$connected = $false;
while($true)
{
    # Find the Kindle Scribe device
    $kindleDevice = $shell.NameSpace("shell:::{20D04FE0-3AEA-1069-A2D8-08002B30309D}").Items() |
        Where-Object { $_.Name -like $deviceNamePattern }

    if ($kindleDevice -eq $null) {
        if($connected)
        {
             $connected = $false;
             Write-Output "Kindle Scribe disconnection detected"
        }
       
        
    }
    else
    {
        if( $connected -eq $false)
        {
            Write-Output "Kindle Scribe connection detected"
            #Scribe plugged in, start sync process
            $scriptToRun = "${scriptPath}export_from_scribe.ps1"
            & $scriptToRun
            $scriptToRun = "${scriptPath}add_to_logseq.ps1"
            & $scriptToRun
            $connected = $true;
        }

    }

    # Wait for a while before checking again
    Start-Sleep -Seconds 5
}