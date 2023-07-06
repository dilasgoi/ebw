#!/bin/bash -x

set -e

# Base directory of the script
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

# Include utility functions
source "${SCRIPT_DIR}/../lib/utils.sh"

# Directory where the logs are stored
LOG_DIR="${SCRIPT_DIR}/../logs"

# History file
HISTORY_FILE="${LOG_DIR}/history"

# Function to parse the status from a log file
parse_status() {
    local log_file=$1

    # Extract the status from the log file
    # (Modify this command to suit the actual structure of your logs)
    grep -E 'Installation ended.*for' ${log_file} | tail -1
}

# Remove the old history file if it exists
if [[ -f ${HISTORY_FILE} ]]; then
    rm ${HISTORY_FILE}
fi

# Loop over all log files in the logs directory
for LOG_FILE in ${LOG_DIR}/*.log; do
    # Extract the name, user, and timestamp from the filename
    BASENAME=$(basename ${LOG_FILE})
    EASYCONFIG=${BASENAME%-*.log}
    TIMESTAMP_USER=${BASENAME#*-${EASYCONFIG}-}
    TIMESTAMP=${TIMESTAMP_USER%-*}
    USERNAME=${TIMESTAMP_USER#*-}

    # Extract the status from the log file
    STATUS=$(parse_status ${LOG_FILE})

    # Write to the history file
    log_to_history "${TIMESTAMP}" "${EASYCONFIG}" "${STATUS}" "${LOG_DIR}"
done

