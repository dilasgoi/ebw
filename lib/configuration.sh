#!/bin/bash

# Function to load EasyBuild's configuration
function load_eb_configuration {
  local script_dir=$(dirname "$0")
  local conf_file="${script_dir}/../config/settings.yaml"
  local common=$1  # common path flag from argument
  local build_path=$(yq e '.buildpath' ${conf_file})
  local hide_deps=$(yq e '.hide-deps' ${conf_file})
  local install_path=$(yq e '.installpath' ${conf_file})
  local common_path=$(yq e '.commonpath' ${conf_file})
  local gpu_path=$(yq e '.gpupath' ${conf_file})
  local source_path=$(yq e '.sourcepath' ${conf_file})
  local robot_paths=$(yq e '.robot-paths' ${conf_file})
  local modules_tool=$(yq e '.modules-tool' ${conf_file})
  local hooks=$(yq e '.hooks' ${conf_file})

  # Override install path if common is true
  if [ "${common}" == "true" ]; then
    install_path=${common_path}
  fi

  echo $build_path $hide_deps $install_path $common_path $source_path $gpu_path $robot_paths $modules_tool $hooks
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

# Function to add options from the JSON file to the eb command
function add_options {
  local eb_command=$1
  local json_file=$2
  local easyconfig_index=$3

  local option_keys=$(jq -r ".easyconfigs[$easyconfig_index].options | keys[]" $json_file)

  for option_key in $option_keys; do
    local option_value=$(jq -r ".easyconfigs[$easyconfig_index].options[\"$option_key\"]" $json_file)

    if [[ -n "$option_value" && "$option_value" != "false" ]]; then
      eb_command+=" --${option_key}=${option_value}"
    fi
  done

  echo "$eb_command"
}

# Function to add custom options from the JSON file to the eb command
function add_custom_options {
  local eb_command=$1
  local json_file=$2
  local easyconfig_index=$3
  local install_path=$4
  local common_path=$5
  local gpu_path=$6

  local custom_options_length=$(jq ".easyconfigs[$easyconfig_index][\"custom-options\"] // [] | length" $json_file)

  for (( custom_option_index=0; custom_option_index<$custom_options_length; custom_option_index++ )); do
    local custom_option_key=$(jq -r ".easyconfigs[$easyconfig_index][\"custom-options\"][$custom_option_index].key" $json_file)
    local custom_option_value=$(jq -r ".easyconfigs[$easyconfig_index][\"custom-options\"][$custom_option_index].value" $json_file)

    if [[ -n "$custom_option_value" && "$custom_option_value" != "false" ]]; then
      # Treat 'common' and 'gpu' options specially
      if [ "$custom_option_key" == "common" ] && [ "$custom_option_value" == "true" ]; then
        eb_command=${eb_command/--installpath=${install_path}/--installpath=${common_path}}
      elif [ "$custom_option_key" == "gpu" ] && [ "$custom_option_value" == "true" ]; then
        eb_command=${eb_command/--installpath=${install_path}/--installpath=${gpu_path}}
      else
        # Modify the corresponding part of eb_command with the new value for all other options
        eb_command=${eb_command/--${custom_option_key}=${!custom_option_key}/--${custom_option_key}=${custom_option_value}}
      fi
    fi
  done

  echo "$eb_command"
}

