#!/bin/bash

# Function to parse arguments
function parse_arguments {
  local dryrun=0
  local filename=""

  while getopts "f:d" opt; do
    case ${opt} in
        f )
            filename=$OPTARG
            ;;
        d )
            dryrun=1
            ;;
        \? )
            echo "Usage: $(basename $0) -f <installation_file.yaml> [-d]"
            exit 1
            ;;
    esac
  done
  shift $((OPTIND -1))

  echo $filename $dryrun
}

# Function to check the existence of the installation file
check_filename() {
  local filename="$1"
  local found_file

  # First, try to find the file with the given name
  found_file=$(find "${SCRIPT_DIR}/.." -type f -name "${filename}")

  # If the file is not found, try appending the ".json" extension and search again
  if [ -z "$found_file" ] && [[ ! "$filename" == *.json ]]; then
    found_file=$(find "${SCRIPT_DIR}/.." -type f -name "${filename}.json")
  fi

  if [ -n "$found_file" ]; then
    echo "$found_file"
    return 0
  else
    echo "Error: File not found." >&2
    return 1
  fi
}

# Function to validate JSON installation file
validate_json() {
  local filename="$1"

  # Using 'jq' to check if the file is a valid JSON
  if ! jq . "$filename" > /dev/null 2>&1; then
    echo "Error: Invalid JSON file." >&2
    return 1
  fi

  return 0
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
    local logfile=$1
    echo "An error occurred on line $1 of the script." | tee -a "${logfile}"
    echo "Exit status: $2" | tee -a "${logfile}"
}

# Function to handle SIGINT (Ctrl+C)
handle_sigint() {
    echo "User interrupted the script. Exiting..."
    exit 1
}
