#!/bin/bash

# Function to check if a filename has been provided
function check_filename {
    local filename=$1
    if [ -z "$filename" ]; then
        echo "Error: Filename is required. Usage: $(basename $0) -f <installation_file.yaml> -u <username> [-d]"
        return 1
    fi
}

# Function to check if a username has been provided
function check_username {
    local username=$1
    if [ -z "$username" ]; then
        echo "Error: Username is required. Usage: $(basename $0) -f <installation_file.yaml> -u <username> [-d]"
        return 1
    fi
}

# Function to check if the file exists
function check_file_exists {
    local script_dir=$1
    local filename=$2
    echo "Checking if $script_dir/../installation_files/$filename exists"
    if [ ! -f "$script_dir/../installation_files/$filename" ]; then
        echo "File $filename not found in the installation_files/ directory"
        return 1
    fi
}

# Function to parse the YAML file using yq
function parse_yaml {
    local script_dir=$1
    local yaml_file="$script_dir/../installation_files/$2"
    APPLICATION=$(yq e '.application' $yaml_file)
    VERSION=$(yq e '.version' $yaml_file)
    TOOLCHAIN=$(yq e '.toolchain // ""' $yaml_file)  # Use an empty string if null
    TOOLCHAIN_VERSION=$(yq e '.toolchain_version // ""' $yaml_file)  # Use an empty string if null
    SUFFIX=$(yq e '.suffix // ""' $yaml_file)  # Use an empty string if null
    COMMENTS=$(yq e '.comments' $yaml_file)

    # If toolchain or toolchain_version are not specified, do not include them or the following hyphen
    if [ -z "$TOOLCHAIN" ] && [ -z "$TOOLCHAIN_VERSION" ]; then
        EASYCONFIG="${APPLICATION}-${VERSION}${SUFFIX}"
    else
        EASYCONFIG="${APPLICATION}-${VERSION}-${TOOLCHAIN}-${TOOLCHAIN_VERSION}${SUFFIX}"
    fi
}

