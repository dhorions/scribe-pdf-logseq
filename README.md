
# Kindle Scribe to Logseq Automation (Windows)

This repository contains PowerShell scripts to automate exporting notebooks from a Kindle Scribe, converting them to PDF, and integrating them into Logseq.

The script can be left running, when you want to sync the notebooks from your kindle scribe to your pc and logseq, simply plug it in through usb.  The script will watch for the connection, check for any new or changed notebooks, convert them to pdf, and add them to the LogSeq page "Scribe Notebooks.md".

## Overview

The main script, `scribe_watcher.ps1`, monitors for the connection of a Kindle Scribe device, exports the notebooks, converts them to PDF, and integrates them into Logseq.

## Prerequisites

Ensure the following are installed:

1. **Calibre**: An e-book manager. [Info Here](https://calibre-ebook.com/)
2. **KFX Input Plugin**: Required for handling Kindle formats. [Info Here](https://www.mobileread.com/forums/showthread.php?t=291290).
3. **LogSeq**: The main intent is to add the Notebooks converted to pdf to logseq.  It can also be used without logseq, simply delete the call to  add_to_logseq.ps1 from scribe_watcher.ps1. [Info here](https://logseq.com/)

## Scripts and Variables

### `scribe_watcher.ps1`

This script monitors for the Kindle Scribe device connection and triggers the export and conversion process.

#### Variables

- `$deviceNamePattern = "*Kindle*"`: Pattern used to identify the Kindle device when it is connected.
- `$scriptPath = "c:\scribe\script\"`: The path to the directory containing the other scripts (`export_from_scribe.ps1` and `add_to_logseq.ps1`).

### `export_from_scribe.ps1`

Handles the extraction of notebooks from the connected Kindle Scribe.

#### Variables

- `$deviceNamePattern = "*Kindle*"`: Pattern to identify the Kindle Scribe device.
- `$internalStorageFolderName = "Internal Storage"`: The name of the internal storage folder in the Kindle Scribe.
- `$notebooksFolderName = ".notebooks"`: The folder name where the notebooks are stored on the device.
- `$nbkFileName = "nbk"`: The file name pattern for the notebook files to be copied.
- `$destinationPath = "C:\scribe\exported_notebooks\"`: Destination path where the copied notebook files will be stored.
- `$guidPattern = '^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$'`: Regex pattern to match GUIDs, which are used as unique identifiers for notebooks.
- `$calibrePath = "C:\Program Files\Calibre2\calibre-debug.exe"`: Path to the Calibre `calibre-debug` executable, used for debugging or extraction purposes.
- `$outputEpubDirectory = "C:\scribe\epub\"`: Directory where the intermediate EPUB files are stored during conversion.
- `$pluginName = "KFX Input"`: Name of the Calibre plugin used to handle Kindle formats.
- `$ebookConvertPath = "C:\Program Files\Calibre2\ebook-convert.exe"`: Path to the Calibre `ebook-convert` executable used for converting files to PDF.
- `$outputPdfDirectory = "C:\scribe\pdf\"`: Directory where the final PDF files are saved.
- `$settingsDirectory = "C:\scribe\settings"`: Directory where settings and JSON files related to the process are stored.

### `add_to_logseq.ps1`

Manages the process of adding the converted PDFs into Logseq.

#### Variables

- `$SourceFolder = "C:\scribe\pdf\"`: The directory where the generated PDFs are initially stored after conversion.
- `$DestinationFolder = "C:\Logseq\assets\pdf"`: The assets directory within Logseq where the PDFs will be moved. This path should correspond to your Logseq setup.
- `$MarkdownFile = "C:\LogSeq\pages\Scribe Notebooks.md"`: Path to the Markdown file in Logseq where links to the PDFs are documented.  Each new detected notebook will be added at the top and can be opened with the integrated pdf reader.

## Customizing the PDF Label

### Modifying Labels via `notebook_labels.json`

You can manually modify the labels of specific notebooks in the `notebook_labels.json` file. This JSON file maps unique notebook identifiers to custom labels. The specified label will be used as the filename for the corresponding PDF when generated.

#### Example

```json
{
    "12345-abcde-67890": "Project Ideas",
    "67890-fghij-12345": "Meeting Notes"
}
```

In this example, the notebook with the ID `12345-abcde-67890` will generate a PDF named `Project Ideas.pdf`, and the notebook with the ID `67890-fghij-12345` will generate a PDF named `Meeting Notes.pdf`.

### Customizing the PDF Filename in Script

The script uses these labels when setting the PDF filename:

```powershell
$label = $jsonObject.Notebooks[$notebook.Id].Label
$pdfFilename = "${label}.pdf"
```

By updating the `notebook_labels.json` file, you control the naming of the output PDF files.

## Usage

1. Ensure all prerequisites are installed and paths are correctly set in the scripts.
2. Connect your Kindle Scribe to the computer.
3. Run the `scribe_watcher.ps1` script. The script will detect the device, export notebooks, convert them to PDF, and integrate them into Logseq.

## Troubleshooting

- **Calibre Not Found**: Verify the `$calibrePath` and `$ebookConvertPath` variables are correctly set and point to the appropriate Calibre installation directories.
- **Kindle Not Detected**: Check that the `$deviceNamePattern` matches the connected device's name and ensure the device is properly connected.

## Contributions

Fork this repository and submit pull requests for improvements or additions.


## Recognition

This is just a script for convenience, all the actual heavy lifting is done by the [Calibre KFX plugin](https://www.mobileread.com/forums/showthread.php?t=291290), thank you jhowell, and everyone that contributed in [this thread ](https://www.mobileread.com/forums/showthread.php?t=353901).


## License

This project is licensed under the MIT License.
