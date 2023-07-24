# EasyBuild Command-Line Wrapper

This project is a simple command-line wrapper for the [EasyBuild](https://easybuild.io/) framework that assists in software building and installation in HPC environments. It enables homogeneous reproducible installations defined through JSON files and options for dry runs, microarchitecture independent installations, GPU-specific installations, and defining CUDA compute capabilities. One central objective of this project is to create a catalogue successful installations, enabling the complete reproduction of the software stack when required.

It follows a similar approach as the one described in the [EasyBuild documentation about Easystacks](https://docs.easybuild.io/easystack-files/), but offers simplicity and flexible customization options out of the EasyBuild Framework. However, utilizing both easystacks and hooks should generally provide a more general and authentic solution.

## Table of Contents
- [Usage](#usage)
- [Requirements](#requirements)
- [Features](#features)
- [Installation JSON File Structure](#installation-json-file-structure)
- [Project Organization](#project-organization)
- [EasyBuild Configuration](#easybuild-configuration)
- [Logging](#logging)
- [Contributions](#contributions)

## Usage

The main script `ebw` is used with flags to specify the JSON file for installation.

```bash
# Standard use
ebw -f <installation_file.json>
```

For example, to install software defined in `AlphaFold.json`:

```bash
ebw -f AlphaFold.json
```

## Requirements

- EasyBuild 
- ``jq`` for JSON parsing
- ``yq`` for YAML parsing
- Bash shell

## Features

- **Installations defined through JSON files**: This makes it easy to specify software installation parameters and maintain installation recipes.
- **Logging**: Every installation attempt is logged with installation start and end time, and the exit status.
- **Dry run option**: Allows users to see what would be installed and changed without making actual changes.
- **Common installation option**: Allows users to install microarchitecture independent code by setting the "common" field in the installation JSON file.
- **GPU-specific installation option**: Enables users to specify installations that are specific to GPU environments.
- **CUDA compute capabilities**: Allows users to specify the CUDA compute capabilities for GPU-specific installations.
- **Enabling/disabling installations**: Allows user to enable or disable the installations in the installation JSON files.

## Project Organization

```
.
├── bin
│   └── ebw
├── config
│   └── settings.yaml
├── CONTRIBUTING.md
├── installation_files
│   ├── a
│   │   ├── AlphaFold.json
│   │   └── Amber.json
│   ├── c
│   │   └── cuDNN.json
│   ├── f
│   │   └── foss.json
│   ├── g
│   │   └── Go.json
│   ├── i
│   │   └── intel.json
│   ├── j
│   │   └── Java.json
│   ├── l
│   │   └── LAMMPS.json
│   ├── n
│   │   └── NVHPC.json
│   ├── q
│   │   └── QuantumESPRESSO.json
│   ├── r
│   │   └── R.json
│   ├── s
│   │   └── Siesta.json
│   ├── v
├── lib
│   ├── checks.sh
│   ├── configuration.sh
│   └── utils.sh
├── logs
│   ├── AlphaFold-2.3.1-foss-2022a-CUDA-11.7.0-20230720180224.log
│   ├── Amber-22.0-foss-2021b-AmberTools-22.3-CUDA-11.4.1-20230720175050.log
│   ├── CUDA-11.4.1-20230720174837.log
│   ├── CUDA-11.7.0-20230720180224.log
│   └── history
└── README.md
```

- `bin`: Contains the main script.
- `config`: Configuration files for EasyBuild.
- `installation_files`: JSON files defining installations.
- `lib`: Utility scripts for the main script. The utility scripts are now separated into different files for better maintainability and readability:
    - `checks.sh`: Contains functions for checking and validating inputs and system configuration.
    - `configuration.sh`: Contains functions for loading configuration from the `settings.yaml` file.
    - `utils.sh`: Contains general utility functions used by the main script.
- `logs`: Logs of installation attempts.

## Installation JSON File Structure

Each installation is defined through a JSON file with the following structure:

- `easyconfigs`: An array of EasyBuild configurations, each consisting of:
    - `name`: The name of the EasyConfig file (`.eb`) to use for installation.
    - `options`: An object with keys and values representing the installation options. The possible options include:
        - `common`: A boolean value to specify a common installation. Default value is `false`.
        - `gpu`: A boolean value to specify a GPU-specific installation.
        - `cuda_compute_capabilities`: A string specifying the CUDA compute capabilities, applicable only if `gpu` is `true`.
        - `enabled`: A boolean value to specify if this EasyConfig should be installed or skipped. Default value is `true`

Example `AlphaFold.json` file:

```json
{
    "easyconfigs": [
        {
            "name": "CUDA-11.7.0.eb",
            "options": {
                "common": true,
                "enabled": true
            }
        },    
        {
            "name": "AlphaFold-2.3.1-foss-2022a-CUDA-11.7.0.eb",
            "options": {
                "common": false,
                "gpu": true,
                "cuda_compute_capabilities": "7.5,8.0",
                "enabled": true
            }
        }
    ]
}
```

## EasyBuild Configuration

The wrapper retrieves its configuration from the `config/settings.yaml` file and overrides the system-wide EasyBuild installation configuration. This file includes settings such as the installation path, source path, build path, and a list of dependencies to hide. These configurations were previously set through environment variables or command-line arguments.

The fields in the `settings.yaml` file represent the following:

- `installpath`: The base path where the software will be installed.
- `commonpath`: The base path where common software will be installed when the `common` field in the installation JSON file is set to `true`.
- `sourcepath`: The path where source files are located.
- `buildpath`: The temporary directory where the software will be built before being installed to the `installpath` or `commonpath`.
- `hide-deps`: A comma-separated list of dependencies that `Lmod` should keep hidden..
- `modules-tool`: The module system used by your HPC environment.

In addition to these settings, you can define other EasyBuild configurations according to the [EasyBuild documentation](https://docs.easybuild.io/en/latest/Configuration.html).

## Logging

Log files are located in the `logs` directory. Each installation attempt generates a log file named after the software, version, toolchain, optional CUDA version, and timestamp of the attempt. The `logs/history` file contains a summary of all installations.

## Contributions

Please see [CONTRIBUTING.md](CONTRIBUTING.md) for more information.

