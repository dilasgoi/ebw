#!/bin/bash

# Function to load EasyBuild's configuration
function load_eb_configuration {
  local script_dir=$(dirname "$0")
  local conf_file="${script_dir}/../config/settings.yaml"
  local build_path=$(yq e '.buildpath' ${conf_file})
  local hide_deps=$(yq e '.hide-deps' ${conf_file})
  local install_path=$(yq e '.installpath' ${conf_file})
  local common_path=$(yq e '.commonpath' ${conf_file})
  local source_path=$(yq e '.sourcepath' ${conf_file})
  local robot_paths=$(yq e '.robot-paths' ${conf_file})
  local modules_tool=$(yq e '.modules-tool' ${conf_file})
  local hooks=$(yq e '.hooks' ${conf_file})

  echo $build_path $hide_deps $install_path $common_path $source_path $robot_paths $modules_tool $hooks
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
    EULA=$(yq e '.eula // ""' $yaml_file)  # Use an empty string if null
    CUDA_COMPUTE_CAPABILITIES=$(yq e '.cuda_compute_capabilities // ""' $yaml_file)  # Use an empty string if null
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
  local build_path=$1
  local hide_deps=$2
  local install_path=$3
  local source_path=$4
  local robot_paths=$5
  local modules_tool=$6
  local hooks=$7
  local easyconfig=$8

  echo "eb --buildpath=${build_path} --hide-deps=${hide_deps} --installpath=${install_path} --sourcepath=${source_path} --robot-paths=${robot_paths} --modules-tool=${modules_tool} --hooks=${hooks} ${easyconfig}.eb"
}
