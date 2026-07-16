#!/bin/bash

# 1. Define the base directory for builds
BASE_DIR="src/builds"

# Create the base directory if it doesn't exist yet
mkdir -p "$BASE_DIR"

# 2. Scan and store existing build directories into an array
existing_builds=()
shopt -s nullglob
for dir in "$BASE_DIR"/*; do
    if [ -d "$dir" ]; then
        existing_builds+=("$(basename "$dir")")
    fi
done
shopt -u nullglob

# 3. Display the selection menu to the user
echo "============================================="
echo " Yocto Build Directory Selection"
echo "============================================="
echo "0) [Create a new build directory]"

# Print the list of existing directories with index numbers (starting from 1)
for i in "${!existing_builds[@]}"; do
    echo "$((i+1))) ${existing_builds[$i]}"
done
echo "============================================="

# 4. Get and process user input
read -p "Select an option (0-${#existing_builds[@]}): " choice

# If the user selects 0 -> Create a new build directory
if [ "$choice" = "0" ]; then
    read -p "Enter a name for the new build (e.g., build-bbb, build-qemu): " new_build_name
    
    # Check if the user left the build name empty
    if [ -z "$new_build_name" ]; then
        echo "[ERROR] Build name cannot be empty!"
        exit 1
    fi
    
    BUILD_DIR="$BASE_DIR/$new_build_name"
    
    # Double-check if this new name already exists to prevent accidental overwrites
    if [ -d "$BUILD_DIR" ]; then
        echo "[INFO] Directory '$BUILD_DIR' already exists. Loading it instead..."
    else
        echo "[INFO] Creating a new build directory: '$BUILD_DIR'..."
        mkdir -p "$BUILD_DIR"
    fi

# If the user selects a valid number from the list
elif [ "$choice" -gt 0 ] 2>/dev/null && [ "$choice" -le "${#existing_builds[@]}" ] 2>/dev/null; then
    # Get the directory name using the index (subtract 1 since Bash arrays are 0-indexed)
    selected_dir="${existing_builds[$((choice-1))]}"
    BUILD_DIR="$BASE_DIR/$selected_dir"
    echo "[INFO] Loading existing configuration for '$BUILD_DIR'..."

# Handle invalid inputs (letters, special symbols, or out-of-bounds numbers)
else
    echo "[ERROR] Invalid selection! Please run the script again."
    exit 1
fi

# 5. Initialize the Yocto environment with the chosen directory
source .tmp/poky/oe-init-build-env "$BUILD_DIR"