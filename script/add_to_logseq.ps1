﻿# Import configuration variables
. "..\settings\config.ps1"


# Define paths and variables at the top of the script
#$SourceFolder = "C:\scribe\pdf\"    # Folder containing the PDFs
#$DestinationFolder = "D:\LogSeq\LogSeqPl\assets\pdf"  # Folder where PDFs will be moved
#$MarkdownFile = "D:\LogSeq\LogSeqPl\pages\Scribe Notebooks.md"   # Path to the markdown file
#$repoPath = "D:\LogSeq\LogSeqPl\"

git -C $repoPath pull

# Ensure destination folder exists
if (-Not (Test-Path $DestinationFolder)) {
    New-Item -ItemType Directory -Path $DestinationFolder
}

# Get a list of PDF files in the source folder
$PDFs = Get-ChildItem -Path $SourceFolder -Filter *.pdf

# Read the existing content of the markdown file
$MarkdownContent = Get-Content -Path $MarkdownFile

# Create a list to hold the new references to be added
$NewReferences = @()

foreach ($PDF in $PDFs) {
    # Define the destination path for the PDF
    $DestinationPath = Join-Path -Path $DestinationFolder -ChildPath $PDF.Name
	Write-Host $PDF.Name
    # Move the PDF to the destination folder (overwrite if exists)
    Copy-Item -Path $PDF.FullName -Destination $DestinationPath -Force
	git -C $repoPath add $DestinationPath

    # Define the relative link format
    $RelativeLink = "../assets/pdf/$($PDF.Name)"
    $LinkText = "- ![$($PDF.BaseName)]($RelativeLink)"

    # Check if the link already exists in the markdown content
    $LinkExists = $MarkdownContent -contains $LinkText

    # If the link does not exist, add it to the list of new references
    if (-not $LinkExists) {
        $NewReferences += $LinkText
    }
}

# If there are new references, add them to the top of the markdown file
if ($NewReferences.Count -gt 0) {
    # Read the existing content of the markdown file
    $CurrentContent = Get-Content -Path $MarkdownFile

    # Combine new references with the existing content
    $UpdatedContent = $NewReferences + $CurrentContent

    # Write the updated content back to the markdown file
    Set-Content -Path $MarkdownFile -Value $UpdatedContent
}
if ($gitLogSeq -eq "Yes") {
	git -C $repoPath add $MarkdownFile
	git -C $repoPath commit -m "Kindle Scribe Notebook Update"
	git -C $repoPath push -u origin master
}
Write-Output "PDF files have been moved to LogSeq assets and markdown file updated. ($MarkdownFile)"
