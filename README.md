# experiences-stories-process
# Media Processing Script for "Follow The North Star" Exhibition

## Overview

This script was specifically developed to support the vzblyf and IAAM teams in their efforts to manage and process a large volume of video content for the "Follow The North Star" exhibition. It integrates a series of automated tasks within a Z shell environment, leveraging both external tools and Python scripts to efficiently handle media files. The end result is a well-organized repository of videos, transcriptions, and extracted location data stored in an Excel file, optimized for content creators, researchers, and data analysts involved in the exhibition.

## Workflow Description

### 1. **Environment Setup and Directory Structure**

Upon initiation, the script establishes the necessary directories within the current working directory, designated for storing original video files, audio conversions, Python scripts, and other models essential for the processing tasks. This systematic organization ensures that all resources are neatly arranged and readily accessible.

### 2. **Dependency Management**

To ensure all required tools are available, the script checks for and installs key software components such as Homebrew, wget, ffmpeg, and various Python libraries. This step is crucial to equip the environment with the capabilities needed for comprehensive media processing, including video downloading, audio conversion, and data manipulation.

### 3. **Media Downloading and Audio Conversion**

For each video URL provided in an Excel spreadsheet, the script automatically downloads the video to the designated directory and extracts the audio in a format suitable for transcription. This preparation is essential for the subsequent analysis and data extraction processes, facilitating a seamless workflow.

### 4. **Transcription and Data Extraction**

Using a custom Python script, the audio files are transcribed into text. These transcriptions are not only saved directly into an Excel file but also printed to the standard output for immediate verification and review. Following the transcription, another Python script extracts geographical locations mentioned within the text using the spaCy library, updating another column in the Excel file with this crucial location data.

### 5. **Iterative Processing and Error Handling**

The script processes each entry from the CSV file derived from the original Excel document, ensuring each video link is valid and that the corresponding audio file exists before proceeding with the transcription and data extraction. The script robustly handles errors and logs each step of the process, providing clear feedback on the progress and any issues encountered, thereby ensuring reliability and efficiency in preparing content for the "Follow The North Star" exhibition.

## Getting Started

### Prerequisites

1. **Excel Spreadsheet Preparation**:
   - Ensure you have an Excel spreadsheet named `Storyboard Audio for FNS.xlsx` containing the video URLs. This spreadsheet should be downloaded and stored in a folder on your desktop.

2. **Software Requirements**:
   - Make sure you have Python 3.9 installed on your system.
   - Ensure you have Homebrew installed if you are using a macOS. For Windows users, equivalent package managers like Chocolatey will suffice.

### Setup Instructions

1. **Open Terminal**:
   - On macOS, you can find the Terminal in Applications under Utilities or search for it using Spotlight.
   - On Windows, you can use PowerShell or install and open Git Bash.

2. **Navigate to the Script Directory**:
   - Use the `cd` command to change directories to where your script is located. If it’s on the desktop, the command might look something like:
     ```
     cd ~/Desktop/name_of_folder_containing_script
     ```

3. **Grant Execution Permissions**:
   - Before running the script, you might need to grant execution permissions to the shell script file (`process.zsh`). You can do this with the following command:
     ```
     chmod +x process.zsh
     ```

4. **Running the Script**:
   - Execute the script by typing the following command in your terminal:
     ```
     ./process.zsh
     ```
   - This command initiates the script, which will automatically handle downloading videos, extracting audio, transcribing content, and updating the Excel spreadsheet.

### Notes on Usage

- **Ensure File Accessibility**: Confirm that the `Storyboard Audio for FNS.xlsx` file is not open in any other application while the script is running, as this may prevent the script from updating the file.
- **Monitor Terminal Output**: Keep an eye on the terminal while the script runs. It will provide updates on the process stages and alert you to any errors or required interventions.
- **Check Outputs**: After the script finishes running, check the designated output directory and the Excel file to ensure that all data has been processed and recorded correctly.

## Conclusion

This automated media processing script is a tailored solution for converting video content into structured data, making it an invaluable asset for the vzblyf and IAAM teams as they prepare for the "Follow The North Star" exhibition. By automating the downloading, conversion, transcription, and data extraction processes, it significantly reduces manual effort and enhances the accuracy and consistency of the data crucial for the exhibition's success.
# experiences-stories-process
