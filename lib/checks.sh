#!/bin/bash

# Function to parse arguments
function parse_arguments {
  local dryrun=0
  local filename=""
  local username=""

  while getopts "f:u:d" opt; do
    case ${opt} in
        f )
            filename=$OPTARG
            ;;
        u )
            username=$OPTARG
            ;;
        d )
            dryrun=1
            ;;
        \? )
            echo "Usage: $(basename $0) -f <installation_file.yaml> -u <username> [-d]"
            exit 1
            ;;
    esac
  done
  shift $((OPTIND -1))

  echo $filename $username $dryrun
}


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

# Function to check the exit status
function check_exit_status {
    local exit_status=$1
    local easyconfig=$2
    local logfile=$3

    if [ ${exit_status} -ne 0 ]; then
        echo "$(date): Installation ended with error for ${easyconfig}, exit status: ${exit_status}" | tee -a "${logfile}"
        echo "Check the log file ${logfile} for details."
        exit ${exit_status}
    else
        echo "$(date): Installation ended successfully for ${easyconfig}, exit status: ${exit_status}" | tee -a "${logfile}"
    fi
}

# Error handling function
function handle_error {
    echo "An error occurred on line $1 of the script."
    echo "Exit status: $2"
    exit $2
}