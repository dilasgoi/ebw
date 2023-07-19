#!/bin/bash

# Function to load EasyBuild's configuration
function load_eb_configuration {
  local script_dir=$(dirname "$0")
  local conf_file="${script_dir}/../config/settings.yaml"
  local build_path=$(yq e '.buildpath' ${conf_file})
  local hide_deps=$(yq e '.hide-deps' ${conf_file})
  local install_path=$(yq e '.installpath' ${conf_file})
  local common_path=$(yq e '.commonpath' ${conf_file})
  local gpu_path=$(yq e '.gpupath' ${conf_file})
  local source_path=$(yq e '.sourcepath' ${conf_file})
  local robot_paths=$(yq e '.robot-paths' ${conf_file})
  local modules_tool=$(yq e '.modules-tool' ${conf_file})
  local hooks=$(yq e '.hooks' ${conf_file})

  echo $build_path $hide_deps $install_path $common_path $source_path $gpu_path $robot_paths $modules_tool $hooks
}

# Function to parse the installation file
function parse_installation_file {
    local json_file=$1
    local EASYCONFIGS=""

    local easyconfigs_length=$(jq '.easyconfigs | length' $json_file)

    for (( easyconfig_index=0; easyconfig_index<$easyconfigs_length; easyconfig_index++ )); do
        local easyconfig=$(jq -r ".easyconfigs[$easyconfig_index].name" $json_file)
        local common=$(jq -r ".easyconfigs[$easyconfig_index].options.common // \"false\"" $json_file)
        local gpu=$(jq -r ".easyconfigs[$easyconfig_index].options.gpu // \"false\"" $json_file)
        local cuda_compute_capabilities=$(jq -r ".easyconfigs[$easyconfig_index].options.cuda_compute_capabilities // \"\"" $json_file)

        # Construct the line
        local line="Easyconfig: $easyconfig | Common: $common | GPU: $gpu | CUDA Compute Capabilities: $cuda_compute_capabilities"

        # Add the line to the EASYCONFIGS variable
        if [ -z "$EASYCONFIGS" ]; then
            EASYCONFIGS="$line"
        else
            EASYCONFIGS="$EASYCONFIGS;$line"
        fi
    done

    echo "$EASYCONFIGS"
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

  echo "eb --buildpath=${build_path} --hide-deps=${hide_deps} --installpath=${install_path} --sourcepath=${source_path} --robot-paths=${robot_paths} --modules-tool=${modules_tool} --hooks=${hooks} ${easyconfig}"
}
 
function add_optional_options {
  local eb_command=$1
  local parallel=$2
  local eula=$3
  local gpu=$4
  local cuda_compute_capability=$5

  local -a commands_array  # Array to store all commands

  # If PARALLEL is not empty, add --parallel option
  if [ -n "${parallel}" ]; then
    eb_command+=" --parallel=${parallel}"
  fi

  # If EULA is not empty, add --accept-eula-for option
  if [ -n "${eula}" ]; then
    eb_command+=" --accept-eula-for=${eula}"
  fi

  # If GPU is true, add --cuda-compute-capabilities option for each capability
  if [ "${gpu}" == "true" ] && [ -n "${cuda_compute_capability}" ]; then
      eb_command+=" --cuda-compute-capabilities=${cuda_compute_capability}"
  fi

  echo "${eb_command}"
}

