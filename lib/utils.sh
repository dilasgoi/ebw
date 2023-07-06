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

# Function to load EasyBuild's configuration
function load_eb_configuration {
  local script_dir=$(dirname "$0")
  local conf_file="${script_dir}/../conf/settings.yaml"

  local build_path=$(yq e '.buildpath' ${conf_file})
  local hide_deps=$(yq e '.hide-deps' ${conf_file})
  local install_path=$(yq e '.installpath' ${conf_file})
  local common_path=$(yq e '.commonpath' ${conf_file})
  local source_path=$(yq e '.sourcepath' ${conf_file})
  local modules_tool=$(yq e '.modules-tool' ${conf_file})
  local hooks=$(yq e '.hooks' ${conf_file})

  echo $build_path $hide_deps $install_path $common_path $source_path $modules_tool $hooks
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
    COMMON=$(yq e '.common // false' $yaml_file)  # Use 'false' as default value
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

# Function to create the EasyBuild command
function create_eb_command {
  local buildpath=$1
  local hidedeps=$2
  local installpath=$3
  local sourcepath=$4
  local modulestool=$5
  local hooks=$6
  local easyconfig=$7

  echo "eb --buildpath=${buildpath} --hide-deps=${hidedeps} --installpath=${installpath} --sourcepath=${sourcepath} --modules-tool=${modulestool} --hooks=${hooks} ${easyconfig}.eb"
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
