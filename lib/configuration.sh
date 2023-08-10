#!/bin/bash

# Function to parse arguments
function parse_arguments {
  local dryrun=0
  local filename=""
  local configfile="settings.yaml" # default configuration file

  while getopts "f:dc:" opt; do
    case ${opt} in
        f )
            filename=$OPTARG
            ;;
        d )
            dryrun=1
            ;;
        c )
            configfile=$OPTARG
            ;;
        \? )
            echo "Usage: $(basename $0) -f <installation_file.yaml> [-d] [-c <config_file.yaml>]"
            exit 1
            ;;
    esac
  done
  shift $((OPTIND -1))

  # Prepend the script directory path to the config file
  local script_dir=$(dirname $(readlink -f $0))
  configfile="${script_dir}/../config/${configfile}"

  echo $filename $dryrun $configfile
}

# Function to load EasyBuild's configuration
function load_eb_configuration {
  local conf_file="$1"
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

  if jq -e ".easyconfigs[$easyconfig_index].options != null" $json_file > /dev/null; then
    local option_keys=$(jq -r ".easyconfigs[$easyconfig_index].options | keys[]" $json_file)

    for option_key in $option_keys; do
      local option_value=$(jq -r ".easyconfigs[$easyconfig_index].options[\"$option_key\"]" $json_file)

      if [[ "$option_value" == "true" ]]; then
        eb_command+=" --${option_key}"
      elif [[ -n "$option_value" && "$option_value" != "false" ]]; then
        eb_command+=" --${option_key}=${option_value}"
      fi
    done
  fi

  echo "$eb_command"
}

# Function to add custom options from the JSON file to the eb command
function add_custom_options {
  local eb_command=$1
  local original_eb_command=$eb_command  # Store the original value
  local json_file=$2
  local easyconfig_index=$3
  local install_path_altered=false       # Flag to check if install path was altered

  if jq -e ".easyconfigs[$easyconfig_index].custom_options != null" $json_file > /dev/null; then
    local custom_option_keys=$(jq -r ".easyconfigs[$easyconfig_index].custom_options // {} | keys[]" $json_file)

    for custom_option_key in $custom_option_keys; do
      local custom_option_value=$(jq -r ".easyconfigs[$easyconfig_index].custom_options[\"$custom_option_key\"]" $json_file)

      if [[ "$custom_option_key" == "common" && "$custom_option_value" == "true" ]]; then
          eb_command=$(echo $eb_command | sed "s|--installpath=${INSTALL_PATH}|--installpath=${COMMON_PATH}|g")
          install_path_altered=true
      fi

    done
  fi

  # Reset to original value if install path was not altered
  if [[ "$install_path_altered" == "false" ]]; then
    eb_command=$original_eb_command
  fi

  echo "$eb_command"
}

