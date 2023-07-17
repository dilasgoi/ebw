#!/bin/bash

# Trap the ERR and SIGINT signals
trap 'handle_error $LINENO $?' ERR
trap 'handle_sigint' SIGINT

# Set absolute path to the main script
SCRIPT_DIR=$(dirname $(readlink -f $0))

# Source utility scripts
source "${SCRIPT_DIR}/../lib/configuration.sh"
source "${SCRIPT_DIR}/../lib/utils.sh"
source "${SCRIPT_DIR}/../lib/checks.sh"

# Call parse_arguments function from utils.sh
read -r FILENAME USERNAME DRYRUN < <(parse_arguments "$@")

# Check if a filename and username have been provided
check_filename "${FILENAME}" || exit 1
check_username "${USERNAME}" || exit 1

# Search for the file in the script directory and its subdirectories
FILENAME=$(find "${SCRIPT_DIR}/.." -type f -name "${FILENAME}")

# Check if the file exists
check_file_exists "$FILENAME" || { echo "The file ${FILENAME} was not found"; exit 1; }

# Load EasyBuild's configuration
read -r BUILD_PATH HIDE_DEPS INSTALL_PATH COMMON_PATH SOURCE_PATH ROBOT_PATHS MODULES_TOOL HOOKS < <(load_eb_configuration)

# Parse the installation file file
parse_installation_file "${FILENAME}"

# Create the installation command
EB_COMMAND=$(create_eb_command ${BUILD_PATH} ${HIDE_DEPS} ${INSTALL_PATH} ${SOURCE_PATH} ${ROBOT_PATHS} ${MODULES_TOOL} ${HOOKS} ${EASYCONFIG})

# Add optional parameters to the command
EB_COMMAND=$(add_optional_options "${EB_COMMAND}" "${PARALLEL}" "${EULA}" "${CUDA_COMPUTE_CAPABILITIES}")

# If not a dry run, prepare for logging and run eb
if [ ${DRYRUN} -eq 0 ]; then
    # Prepare for logging
    TIMESTAMP="$(date +%Y%m%d%H%M%S)"
    LOGDIR="${SCRIPT_DIR}/../logs"
    LOGFILE="${LOGDIR}/${EASYCONFIG}-${TIMESTAMP}.log"

    # Register the start time and the easyconfig name
    echo "$(date): Installation started for ${EASYCONFIG} by ${USERNAME}" | tee -a "${LOGFILE}"

    # Log the content of the YAML file
    echo "YAML file content:" | tee -a "${LOGFILE}"
    cat "${FILENAME}" | tee -a "${LOGFILE}"

    # Log the SHA256 hash of the YAML file
    echo "SHA256 hash of the YAML file:" | tee -a "${LOGFILE}"
    sha256sum "${FILENAME}" | tee -a "${LOGFILE}"

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

    log_to_history "${TIMESTAMP}" "${EASYCONFIG}" "${EXIT_STATUS}" "${LOGDIR}"
else
    # Dry run
    echo "Performing dry run for ${EASYCONFIG}"
    ${EB_COMMAND} -Dr
fi
