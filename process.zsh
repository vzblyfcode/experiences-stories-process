#!/bin/zsh
# chmod +x process.zsh
# ./process.zsh

# Set up directories and files relative to the current directory
BASE_DIRECTORY="$(pwd)/stories"
MODEL_DIRECTORY="${BASE_DIRECTORY}/models"
OUTPUT_FOLDER="${BASE_DIRECTORY}/S3videos"
PYTHON_SCRIPT_TRANSCRIBE="${BASE_DIRECTORY}/transcribe_audio.py"
PYTHON_SCRIPT_UPDATE_EXCEL="${BASE_DIRECTORY}/update_excel.py"

# Remove existing directories and files
rm -rf "$BASE_DIRECTORY" "$PYTHON_SCRIPT_TRANSCRIBE" "$PYTHON_SCRIPT_UPDATE_EXCEL"

# Create directories
mkdir -p "$BASE_DIRECTORY"
mkdir -p "$MODEL_DIRECTORY"
mkdir -p "$OUTPUT_FOLDER"

# Ensure the local Python bin and Homebrew are in PATH
export PATH="$HOME/Library/Python/3.9/bin:/opt/homebrew/bin:$PATH"

# Retrieve the path to the correct Python interpreter
PYTHON_PATH=$(which python3)

# Check and install necessary tools
ensure_tool_installed() {
    local tool=$1
    local installer_command=$2
    local post_install_command=$3

    if ! command -v $tool &> /dev/null; then
        echo "$tool could not be found, installing..."
        eval $installer_command || {
            echo "Failed to install $tool. Please install it manually and retry."
            exit 1
        }
        if [ -n "$post_install_command" ]; then
            eval $post_install_command
        fi
    fi
}

# Install Homebrew, wget, xlsx2csv, ffmpeg, vosk, spacy, and openpyxl
ensure_tool_installed "brew" "/bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)\""
ensure_tool_installed "wget" "brew install wget"
ensure_tool_installed "xlsx2csv" "pip install xlsx2csv --user"
ensure_tool_installed "ffmpeg" "brew install ffmpeg"
ensure_tool_installed "pip" "easy_install pip"
ensure_tool_installed "vosk" "pip install vosk"
ensure_tool_installed "spacy" "pip install spacy && python3.9 -m spacy download en_core_web_sm"
ensure_tool_installed "speech_recognition" "pip install SpeechRecognition --user"
ensure_tool_installed "openpyxl" "pip install openpyxl --user"

# Function to extract locations using SpaCy
extract_locations() {
    local input_file="$1"
    local output_file="$2"
    local locations=()  # List to store extracted locations

    # Load SpaCy's pre-trained English model
    python3.9 - <<EOF > "$output_file"
import spacy

# Load SpaCy's pre-trained English model
nlp = spacy.load("en_core_web_sm")

# Function to extract location mentions from text
def extract_locations_from_text(text):
    doc = nlp(text)
    locations = []
    for ent in doc.ents:
        if ent.label_ == "GPE":  # GPE: Geo-Political Entity
            locations.append(ent.text)
    return locations

# Define the locations list
locations = []

# Read transcript from input file and extract locations from each line
with open("$input_file", "r") as f:
    for line in f:
        print("Processing line:", line.strip())  # Debugging statement
        extracted_locations = extract_locations_from_text(line.strip())
        print("Extracted locations:", extracted_locations)  # Debugging statement
        locations += extracted_locations

# Write extracted locations to output file
for location in locations:
    print(location)
EOF
}

# Create transcribe_audio.py script
cat > "$PYTHON_SCRIPT_TRANSCRIBE" <<EOF
#!/usr/bin/env python3.9
import sys
import speech_recognition as sr
from openpyxl import load_workbook

def transcribe_audio(audio_file_path, excel_file, row_idx):
    recognizer = sr.Recognizer()
    with sr.AudioFile(audio_file_path) as source:
        audio_data = recognizer.record(source)
    try:
        transcription = recognizer.recognize_google(audio_data)
        # Load the workbook and update transcription directly
        wb = load_workbook(excel_file)
        sheet = wb.active
        # Assuming column 16 is now for "Transcription"
        sheet.cell(row=int(row_idx), column=16).value = transcription
        wb.save(excel_file)
        print("Transcription written to Excel at row:", row_idx)
        # Print transcription to stdout for capture in shell script
        print(transcription)
    except sr.UnknownValueError:
        print("Speech recognition could not understand audio")
    except sr.RequestError as e:
        print(f"Could not request results from Google Speech Recognition service; {e}")
    except Exception as e:
        print(f"Error occurred: {e}")

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: python3.9 transcribe_audio.py <audiofile> <excel_file> <row_idx>")
        sys.exit(1)
    
    audio_file_path = sys.argv[1]
    excel_file = sys.argv[2]
    row_idx = sys.argv[3]
    transcribe_audio(audio_file_path, excel_file, row_idx)
EOF

echo "Updating Excel at row $row_index with data from $locations_file"

#Create update_excel.py script
cat > "$PYTHON_SCRIPT_UPDATE_EXCEL" <<EOF
#!/usr/bin/env python3.9
import sys
from openpyxl import load_workbook
import spacy

# Load the spaCy English model for NLP operations
nlp = spacy.load("en_core_web_sm")

def extract_locations(text):
    """Extracts location mentions using spaCy from the provided text."""
    doc = nlp(text)
    locations = [ent.text for ent in doc.ents if ent.label_ == "GPE"]
    return locations

def update_excel(excel_file, row_idx, transcription_text):
    wb = load_workbook(excel_file)
    sheet = wb.active

    # Update Transcription if the corresponding column is empty
    transcription_cell = sheet.cell(row=int(row_idx), column=16)  # Assuming column 16 is "Transcription"
    if not transcription_cell.value:
        transcription_cell.value = transcription_text

    # Extract locations
    locations = extract_locations(transcription_text)

    # Assign locations to variables based on the logic
    place_a = locations[0] if len(locations) > 0 else None
    place_b = locations[1] if len(locations) > 1 else None
    place_c = locations[-2] if len(locations) > 3 else None
    place_d = locations[-1] if len(locations) > 1 else None

    # Update Excel cells if the location exists
    if place_a:
        sheet.cell(row=row_idx, column=18).value = place_a  # Column R is 18
    if place_b:
        sheet.cell(row=row_idx, column=19).value = place_b  # Column S is 19
    if place_c:
        sheet.cell(row=row_idx, column=20).value = place_c  # Column T is 20
    if place_d:
        sheet.cell(row=row_idx, column=21).value = place_d  # Column U is 21

    wb.save(excel_file)

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: python3.9 update_excel.py <excel_file> <row_idx> <transcription_text>")
        sys.exit(1)
    
    excel_file = sys.argv[1]
    row_idx = sys.argv[2]
    transcription_text = sys.argv[3]
    update_excel(excel_file, row_idx, transcription_text)
EOF

# Check for the Excel file
FILE="Storyboard Audio for FNS.xlsx"
if [ ! -f "$FILE" ]; then
    echo "Error: $FILE is not found in the current directory. Please place the file in the directory and rerun the script."
    exit 1
fi

# Convert the Excel file to CSV
xlsx2csv "$FILE" > "${BASE_DIRECTORY}/video_links.csv"

# Initialize row_index for the first data row (assuming headers are in the first row)
row_index=2

# Read and process each line from the CSV file
while IFS=, read -r date category first last email research promo url theme notes file file_name usable title transcription places_extracted place_a place_b place_c place_d; do

    if [[ "$url" == http* ]]; then
        ((row_index++))  # Increment row index only for valid videos
        echo "Processing video: $url"
        video_path="${OUTPUT_FOLDER}/$(basename "$url")"
        wget -O "$video_path" "$url"
        audio_path="${video_path%.*}.wav"
        echo "Converted audio path: $audio_path"
        ffmpeg -i "$video_path" -acodec pcm_s16le -ac 1 -ar 16000 "$audio_path"

        # Transcribe audio and update Excel directly
        echo "Transcribing audio for row $row_index..."
        transcription_text=$(python3.9 "$PYTHON_SCRIPT_TRANSCRIBE" "$audio_path" "$FILE" $row_index | tail -1)

        echo "Transcription result: $transcription_text"

        # Update Excel file with transcription and locations
        echo "Updating Excel for row $row_index..."
        python3.9 "$PYTHON_SCRIPT_UPDATE_EXCEL" "$FILE" $row_index "$transcription_text"

        echo "Updated Excel at row $row_index with transcription and locations"
        
    fi
done < <(tail -n +2 "${BASE_DIRECTORY}/video_links.csv")  # Skip the header line

echo "Process complete. Videos, transcripts, and locations are stored in $OUTPUT_FOLDER"
