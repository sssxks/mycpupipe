#!/bin/bash

# Navigate to the script's directory
cd "$(dirname "$0")" || exit 1

# Define the source directory
SRC_DIR="../src"

# Check if the source directory exists
if [ ! -d "$SRC_DIR" ]; then
  echo "Source directory $SRC_DIR does not exist."
  exit 1
fi

# Generate the verilator.f file and output results to stdout
find "$SRC_DIR" -type d -exec echo "-y $(realpath {})" \; | tee verilator.f
find "$SRC_DIR" -type f -name "*.sv" -exec echo "$(realpath {})" \; | tee -a verilator.f
echo "--top-module cpu" | tee -a verilator.f
