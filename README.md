
# Kindle Scribe to Logseq Automation (Windows)

This repository contains PowerShell scripts to automate exporting notebooks from a Kindle Scribe, converting them to PDF, and integrating them into Logseq.

The script can be left running, when you want to sync the notebooks from your kindle scribe to your pc and logseq, simply plug it in through usb.  The script will watch for the connection, check for any new or changed notebooks, convert them to pdf, and add them to the LogSeq page "Scribe Notebooks.md".

## Overview

The main script, `scribe_watcher.ps1`, monitors for the connection of a Kindle Scribe device, exports the notebooks, converts them to PDF, and integrates them into Logseq.

## Video




https://github.com/user-attachments/assets/55797896-2540-46be-9f95-76dddee1c81a


## Prerequisites

Ensure the following are installed:

1. **Calibre**: An e-book manager. [Info Here](https://calibre-ebook.com/)
2. **KFX Input Plugin**: Required for handling Kindle formats. [Info Here](https://www.mobileread.com/forums/showthread.php?t=291290).
3. **LogSeq**: The main intent is to add the Notebooks converted to pdf to logseq.  It can also be used without logseq to just generate the pdfs from your notebooks. [Info here](https://logseq.com/)

## Scripts and Variables

### `setup.ps1`

Run this script first, it will create a settings/config.ps1 file containing your configuration.


### `scribe_watcher.ps1`

This script monitors for the Kindle Scribe device connection and triggers the export and conversion process.

### `export_from_scribe.ps1`

Handles the extraction of notebooks from the connected Kindle Scribe.

### `add_to_logseq.ps1`

Manages the process of adding the converted PDFs into Logseq.

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
2. Run `setup.ps1` script 
3. Run the `scribe_watcher.ps1` script. The script will detect the device, export notebooks, convert them to PDF, and integrate them into Logseq.
4. Connect your Kindle Scribe to the computer.

## Troubleshooting

- **Calibre Not Found**: Verify the `$calibrePath` and `$ebookConvertPath` variables are correctly set and point to the appropriate Calibre installation directories.
- **Kindle Not Detected**: Check that the `$deviceNamePattern` matches the connected device's name and ensure the device is properly connected.

## Contributions

Fork this repository and submit pull requests for improvements or additions.


## Recognition

This is just a script for convenience, all the actual heavy lifting is done by the [Calibre KFX plugin](https://www.mobileread.com/forums/showthread.php?t=291290), thank you jhowell, and everyone that contributed in [this thread ](https://www.mobileread.com/forums/showthread.php?t=353901).


## License

This project is licensed under the MIT License.
