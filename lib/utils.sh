#!/bin/bash

# Function to create a post-execution summary
function post_execution_summary {
    local filename=$1
    local easyconfig=$2
    local eb_command=$3
    local logfile=$4

    echo "==== Post-execution Summary ====" | tee -a "${logfile}"
    echo "Installation File: ${filename}" | tee -a "${logfile}"
    echo "Easyconfig: ${easyconfig}" | tee -a "${logfile}"
    echo "Command: ${eb_command}" | tee -a "${logfile}"
    echo "Log File: ${logfile}" | tee -a "${logfile}"
}

# Function to create a entry in the history file
log_to_history() {
    local timestamp=$1
    local easyconfig=$2
    local exit_status=$3
    local log_dir=$4

    echo "${timestamp} ${easyconfig} ${exit_status}" >> "${log_dir}/history"
}
