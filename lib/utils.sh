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
    PARALLEL=$(yq e '.parallel // ""' $yaml_file)  # Use an empty string if null
    COMMENTS=$(yq e '.comments' $yaml_file)

    EASYCONFIG="${APPLICATION}-${VERSION}"

    if [ -n "$TOOLCHAIN" ]; then
        EASYCONFIG+="-${TOOLCHAIN}"
    fi

    if [ -n "$TOOLCHAIN_VERSION" ]; then
        EASYCONFIG+="-${TOOLCHAIN_VERSION}"
    fi

    if [ -n "$SUFFIX" ]; then
        EASYCONFIG+="-${SUFFIX}"
    fi
}

# Function to check the exit status
function check_exit_status {
    local exist_status=$1
    local easyconfig=$2
    local logfile=$3

    if [ ${exist_status} -ne 0 ]; then
        echo "$(date): Installation ended with error for ${easyconfig}, exit status: ${exist_status}" | tee -a "${logfile}"
        echo "Check the log file ${logfile} for details."
        exit ${exit_status}
    else
        echo "$(date): Installation ended successfully for ${easyconfig}, exit status: ${exist_status}" | tee -a "${logfile}"
    fi
}

# Function to create a post-execution summary
function post_execution_summary {
    local filename=$1
    local username=$2
    local application=$3
    local version=$4
    local toolchain=$5
    local toolchain_version=$6
    local suffix=$7
    local parallel=$8
    local easyconfig=$9
    local eb_command=${10}
    local logfile=${11}

    echo "==== Post-execution Summary ====" | tee -a "${logfile}"
    echo "Installation File: ${filename}" | tee -a "${logfile}"
    echo "Username: ${username}" | tee -a "${logfile}"
    echo "Application: ${application}" | tee -a "${logfile}"
    echo "Version: ${version}" | tee -a "${logfile}"
    if [ -n "$toolchain" ]; then echo "Toolchain: ${toolchain}" | tee -a "${logfile}"; fi
    if [ -n "$toolchain_version" ]; then echo "Toolchain Version: ${toolchain_version}" | tee -a "${logfile}"; fi
    if [ -n "$suffix" ]; then echo "Suffix: ${suffix}" | tee -a "${logfile}"; fi
    if [ -n "$parallel" ]; then echo "Parallel: ${parallel}" | tee -a "${logfile}"; fi
    echo "Easyconfig: ${easyconfig}" | tee -a "${logfile}"
    echo "Command: ${eb_command}" | tee -a "${logfile}"
    echo "Log File: ${logfile}" | tee -a "${logfile}"
}

# Error handling function
function handle_error {
    echo "An error occurred on line $1 of the script."
    echo "Exit status: $2"
    exit $2
}
