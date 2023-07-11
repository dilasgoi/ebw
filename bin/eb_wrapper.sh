#!/bin/bash

# Trap the ERR signal
trap 'handle_error $LINENO $?' ERR

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

# Check if the file exists
check_file_exists "$SCRIPT_DIR" "$FILENAME" || exit 1

# Load EasyBuild's configuration
read -r BUILD_PATH HIDE_DEPS INSTALL_PATH COMMON_PATH SOURCE_PATH MODULES_TOOL HOOKS < <(load_eb_configuration)

# Parse the YAML file
parse_yaml "${SCRIPT_DIR}" "${FILENAME}"

# Override installpath if common is set to true
if [ "${COMMON}" == "true" ]; then
    INSTALL_PATH=${COMMON_PATH}
fi

# Create the installation command
EB_COMMAND=$(create_eb_command ${BUILD_PATH} ${HIDE_DEPS} ${INSTALL_PATH} ${SOURCE_PATH} ${MODULES_TOOL} ${HOOKS} ${EASYCONFIG})

# If PARALLEL is not empty, add --parallel option
if [ -n "${PARALLEL}" ]; then
    EB_COMMAND+=" --parallel=${PARALLEL}"
fi

# If EULA is not empty, add --accept-eula-for option
if [ -n "${EULA}" ]; then
	    EB_COMMAND+=" --accept-eula-for=${EULA}"
    fi

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

    log_to_history "${TIMESTAMP}" "${EASYCONFIG}" "${EXIT_STATUS}" "${LOGDIR}"
else
    # Dry run
    echo "Performing dry run for ${EASYCONFIG}"
    ${EB_COMMAND} -Dr
fi
