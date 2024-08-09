# Import configuration variables
. "..\settings\config.ps1"

# Configuration variables
#$deviceNamePattern = "*Kindle*"      # Pattern to identify the Kindle Scribe device
#$internalStorageFolderName = "Internal Storage"  # Name of the internal storage folder
#$notebooksFolderName = ".notebooks"  # Name of the notebooks folder
#$nbkFileName = "nbk"                 # Name of the file to be copied
#$destinationPath = "C:\scribe\exported_notebooks\" # Destination path for copied files
#$guidPattern = '^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$' # Pattern to match GUIDs
#$calibrePath = "C:\Program Files\Calibre2\calibre-debug.exe" # Path to the calibre-debug executable
#$outputEpubDirectory = "C:\scribe\epub\" # Output directory for EPUB files
#$pluginName = "KFX Input" # Name of the Calibre plugin to use
#$ebookConvertPath = "C:\Program Files\Calibre2\ebook-convert.exe" # Path to the ebook-convert executable
# Directory for storing the output PDF files
#$outputPdfDirectory = "C:\scribe\pdf\" # Output directory for PDF files
# Configuration for settings and JSON file
#$settingsDirectory = "C:\scribe\settings"
$jsonFilePath = Join-Path -Path $settingsDirectory -ChildPath "notebook_labels.json"

# Ensure the settings directory exists
if (!(Test-Path -Path $settingsDirectory)) {
    New-Item -ItemType Directory -Path $settingsDirectory
}

# Load or initialize JSON file
if (Test-Path -Path $jsonFilePath) {
    $jsonContent = Get-Content -Path $jsonFilePath | ConvertFrom-Json
} else {
    $jsonContent = @{}
}

# Initialize Shell.Application COM object
$shell = New-Object -ComObject Shell.Application

# Find the Kindle Scribe device
$kindleDevice = $shell.NameSpace("shell:::{20D04FE0-3AEA-1069-A2D8-08002B30309D}").Items() |
    Where-Object { $_.Name -like $deviceNamePattern }

if ($kindleDevice -eq $null) {
    Write-Output "Kindle Scribe is not connected. Please connect your device and try again."
    exit
}

# Find the "Internal Storage" folder
$internalStorage = $kindleDevice.GetFolder.Items() | Where-Object { $_.Name -eq $internalStorageFolderName -and $_.IsFolder }

if ($internalStorage -eq $null) {
    Write-Output "'Internal Storage' folder not found on Kindle Scribe."
    exit
}

# Navigate to the .notebooks folder
$notebooksFolder = $internalStorage.GetFolder.Items() | Where-Object { $_.Name -eq $notebooksFolderName -and $_.IsFolder }

if ($notebooksFolder -eq $null) {
    Write-Output "'.notebooks' folder not found inside 'Internal Storage'."
    exit
}

# Create the destination directory if it doesn't exist
if (!(Test-Path -Path $destinationPath)) {
    New-Item -ItemType Directory -Path $destinationPath
}
if (!(Test-Path -Path $outputEpubDirectory)) {
    New-Item -ItemType Directory -Path $outputEpubDirectory
}
if (!(Test-Path -Path $outputPdfDirectory)) {
    New-Item -ItemType Directory -Path $outputPdfDirectory
}
if (!(Test-Path -Path $settingsDirectory)) {
    New-Item -ItemType Directory -Path $settingsDirectory
}
# Load or initialize JSON file
if (Test-Path -Path $jsonFilePath) {
    $jsonContent = Get-Content -Path $jsonFilePath | ConvertFrom-Json
} else {
    $jsonContent = @{}
}
# Convert the JSON content to a hashtable for easier manipulation
$jsonHashtable = @{}
foreach ($key in $jsonContent.PSObject.Properties.Name) {
    $jsonHashtable[$key] = $jsonContent.$key
}


# Function to compute SHA-256 hash
function Get-FileHashSHA256($filePath) {
    $hash = Get-FileHash -Path $filePath -Algorithm SHA256
    return $hash.Hash
}


# Loop through each folder in .notebooks, copy only those with a GUID-like name, and copy the nbk files
foreach ($folder in $notebooksFolder.GetFolder.Items() | Where-Object { $_.IsFolder }) {
    if ($folder.Name -match $guidPattern) {
        $nbkFile = $folder.GetFolder.Items() | Where-Object { $_.Name -eq $nbkFileName -and -not $_.IsFolder }
        if ($nbkFile -ne $null) {
            # Generate label if not already in JSON file
            if (-not $jsonHashtable.ContainsKey($folder.Name)) {
                $timestamp = Get-Date -Format "yyyy/MM/dd HH:mm:ss"
                $label = "Scribe Notebook $timestamp"
                $jsonHashtable[$folder.Name] = $label
            } else {
                $label = $jsonHashtable[$folder.Name]
            }
            # Create a folder in the destination path named after the GUID
            $guidFolderPath = Join-Path -Path $destinationPath -ChildPath $folder.Name
            if (!(Test-Path -Path $guidFolderPath)) {
                New-Item -ItemType Directory -Path $guidFolderPath
            }

            # Delete the existing nbk file if it exists
            # Define the destination file path for the nbk file
            $destinationFilePath = Join-Path -Path $guidFolderPath -ChildPath $nbkFile.Name
            $previousHash = "";
            if (Test-Path -Path $destinationFilePath) {
                $previousHash = Get-FileHashSHA256  $destinationFilePath
                Remove-Item -Path $destinationFilePath -Force
                #Write-Output "Deleted existing file: $destinationFilePath - $previousHash"
            }
           

            # Copy the nbk file to the corresponding GUID folder
            $shell.NameSpace($guidFolderPath).CopyHere($nbkFile)

            $currentHash = Get-FileHashSHA256  $destinationFilePath

            #Write-Output "Copied $($folder.Name)\$nbkFileName to $guidFolderPath - $currentHash"
            if($currentHash -eq $previousHash)
            {
                Write-Output "Notebook unchanged - $destinationFilePath"
            }
            else
            {
                Write-Output "Notebook change detected.  Processing :  $destinationFilePath"
                # Define the output EPUB path using the GUID name
                $outputEpubPath = Join-Path -Path $outputEpubDirectory -ChildPath ($folder.Name + ".epub")

                # Run calibre-debug.exe to convert the contents to an EPUB file
                $arguments = "-r `"$pluginName`" -- `"$guidFolderPath`" `"$outputEpubPath`""
                #Write-Output "Executing: $calibrePath $arguments"
                Start-Process -FilePath $calibrePath -ArgumentList $arguments -NoNewWindow -Wait
                # Define the output EPUB path using the GUID name
                $outputEpubPath = Join-Path -Path $outputEpubDirectory -ChildPath ($folder.Name + ".epub")
                # Define the output PDF path using the GUID name
                #$outputPdfPath = Join-Path -Path $outputPdfDirectory -ChildPath ($folder.Name + ".pdf")

                # Define the output PDF path using the label from the JSON file
                $safeLabel = $label -replace '[<>:"/\\|?*]', '' # Remove invalid characters for filenames
                $outputPdfPath = Join-Path -Path $outputPdfDirectory -ChildPath ($safeLabel + ".pdf")
                # Run ebook-convert.exe to convert the EPUB file to a PDF file
                $convertArguments = "`"$outputEpubPath`" `"$outputPdfPath`""
                #Write-Output "Executing: $ebookConvertPath $convertArguments"
                Start-Process -FilePath $ebookConvertPath -ArgumentList $convertArguments -NoNewWindow -Wait
            }


            



        }
    } else {
        #Write-Output "Skipped non-GUID folder: $($folder.Name)"
    }
}
# Convert the hashtable back to a PSCustomObject for JSON serialization
$jsonObject = [PSCustomObject]@{}
foreach ($key in $jsonHashtable.Keys) {
    $jsonObject | Add-Member -Type NoteProperty -Name $key -Value $jsonHashtable[$key]
}
# Save the updated JSON content back to the file
$jsonObject | ConvertTo-Json | Set-Content -Path $jsonFilePath

#Write-Output $jsonObject

Write-Output "Notebook conversion complete."