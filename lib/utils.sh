#!/bin/bash

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

# Function to create a entry in the history file
log_to_history() {
    local timestamp=$1
    local easyconfig=$2
    local status=$4
    local log_dir=$5

    echo "${timestamp}-${easyconfig} ${status}" >> "${log_dir}/history"
}
