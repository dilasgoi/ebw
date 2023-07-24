#!/bin/bash

# Function to create a post-execution summary
function post_execution_summary {
    local filename=$1
    local application=$2
    local version=$3
    local toolchain=$4
    local toolchain_version=$5
    local suffix=$6
    local parallel=$7
    local easyconfig=$8
    local eb_command=$9
    local logfile=${10}

    echo "==== Post-execution Summary ====" | tee -a "${logfile}"
    echo "Installation File: ${filename}" | tee -a "${logfile}"
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

# Function to create a entry in the history file
log_to_history() {
    local timestamp=$1
    local easyconfig=$2
    local exit_status=$3
    local log_dir=$4

    echo "${timestamp} ${easyconfig} ${exit_status}" >> "${log_dir}/history"
}
