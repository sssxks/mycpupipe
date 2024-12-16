#!/bin/bash

# Navigate to the script's directory/..
cd "$(dirname "$0")/.." || exit 1

# Define the source & include directory
SRC_DIR="src"
INCLUDE_DIR="src/include"

# Define the verilator file path
VERILATOR_FILE="scripts/verilator.f"

# Check if the source directory exists
if [ ! -d "$SRC_DIR" ]; then
  echo -e "\e[31mSource directory $SRC_DIR does not exist.\e[0m"
  exit 1
fi

# Initialize a variable to store the previous content
prev_content=""

# Main loop to monitor changes and update verilator.f
while true; do
  # Create a temporary file to store new content
  new_content=$(mktemp)
  
  # Generate the list of directories and files
  # find "$SRC_DIR" -type d -exec echo "-y $(realpath {})" \; > "$new_content"
  find "$SRC_DIR" -type f -name "*.sv" -exec echo "$(realpath {})" \; >> "$new_content"
  
  # Append additional verilator options
  echo "--top-module soc_simulation_tb" >> "$new_content"
  echo "--error-limit 4" >> "$new_content"
  echo "-I\"$INCLUDE_DIR\"" >> "$new_content"

  # Check if the content has changed and print the diff
  if [ "$prev_content" != "$(cat "$new_content")" ]; then
    if [ -n "$prev_content" ]; then
      echo -e "\e[32mChanges detected:\e[0m"
      diff <(echo "$prev_content") "$new_content"
    fi
    prev_content=$(cat "$new_content")
  fi

  # Update the verilator.f file
  mv "$new_content" "$VERILATOR_FILE"

  # Wait for 2 seconds before running again
  sleep 10
done
