#!/bin/bash

set -e

# Trap the ERR signal
trap 'handle_error $LINENO $?' ERR

# Set absolute path to the main script
SCRIPT_DIR=$(dirname $(readlink -f $0))

# Source utility scripts
source "${SCRIPT_DIR}/../lib/utils.sh"

# Initialize the dryrun variable to 0 (false)
DRYRUN=0

# Parse command-line arguments
while getopts "f:u:d" opt; do
    case ${opt} in
        f )
            FILENAME=$OPTARG
            ;;
        u )
            USERNAME=$OPTARG
            ;;
	d )
            DRYRUN=1
            ;;
        \? )
            echo "Usage: $(basename $0) -f <installation_file.yaml> -u <username> [-d]"
            exit 1
            ;;
    esac
done
shift $((OPTIND -1))

# Check if a filename and username have been provided
check_filename "${FILENAME}" || exit 1
check_username "${USERNAME}" || exit 1

# Check if the file exists
check_file_exists "$SCRIPT_DIR" "$FILENAME" || exit 1

# Load configuration
CONF_FILE="${SCRIPT_DIR}/../conf/settings.yaml"
BUILD_PATH=$(yq e '.buildpath' ${CONF_FILE})
HIDE_DEPS=$(yq e '.hide_deps' ${CONF_FILE})

# Parse the YAML file
parse_yaml "${SCRIPT_DIR}" "${FILENAME}"

EB_COMMAND="eb --buildpath=${BUILD_PATH} --hide-deps=${HIDE_DEPS} ${EASYCONFIG}.eb"

# If PARALLEL is not empty, add --parallel option
if [ -n "${PARALLEL}" ]; then
    EB_COMMAND+=" --parallel=${PARALLEL}"
fi

# If not a dry run, prepare for logging and run eb
if [ ${DRYRUN} -eq 0 ]; then
    # Prepare for logging
    TIMESTAMP="$(date +%Y%m%d%H%M%S)"
    LOGFILE="${SCRIPT_DIR}/../logs/${EASYCONFIG}-${TIMESTAMP}.log"

    # Register the start time and the easyconfig name
    echo "$(date): Installation started for ${EASYCONFIG} by ${USERNAME}" | tee -a "${LOGFILE}"

    # Log the content of the YAML file
    echo "YAML file content:" | tee -a "${LOGFILE}"
    cat "${SCRIPT_DIR}/../installation_files/$FILENAME" | tee -a "${LOGFILE}"

    # Log the SHA256 hash of the YAML file
    echo "SHA256 hash of the YAML file:" | tee -a "${LOGFILE}"
    sha256sum "${SCRIPT_DIR}/../installation_files/${FILENAME}" | tee -a "${LOGFILE}"

    # Run eb with specific buildpath and hidden dependencies, and capture the exit status
    ${EB_COMMAND} -r
    EXIT_STATUS=$?

    # Call the function to check the exit status
    check_exit_status "${EXIT_STATUS}" \
                      "${EASYCONFIG}" \
                      "${LOGFILE}"

    post_execution_summary "${FILENAME}" "${USERNAME}" "${APPLICATION}" "${VERSION}" "${TOOLCHAIN}" \
                           "${TOOLCHAIN_VERSION}" "${SUFFIX}" "${PARALLEL}" "${EASYCONFIG}" \
                           "${EB_COMMAND}" "${LOGFILE}"
else
    # Dry run
    echo "Performing dry run for ${EASYCONFIG}"
    ${EB_COMMAND} -Dr
fi
