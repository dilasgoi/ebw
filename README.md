# EasyBuild Command-Line Wrapper

This project is a command-line wrapper for the [EasyBuild](https://easybuild.io/) framework that facilitates software building and installation in HPC environments. It enforces homogeneous reproducible installations defined through YAML files, user-based logging, and options for dry runs and common installations.

## Table of Contents
- [Usage](#usage)
- [Requirements](#requirements)
- [Features](#features)
- [Installation YAML File Structure](#installation-yaml-file-structure)
- [Project Organization](#project-organization)
- [Logging](#logging)

## Usage

The main script `eb_wrapper.sh` is used with flags to specify the YAML file for installation, the user, and an optional flag for dry run.

```bash
# Standard use
eb_wrapper.sh -f <installation_file.yaml> -u <username>

# Dry run
eb_wrapper.sh -f <installation_file.yaml> -u <username> -d
```

For example, to run a dry install for `Go-1.20.4.yaml` as user `Diego`, you would use:

```bash
eb_wrapper.sh -f Go-1.20.4.yaml -u Diego -d
```

## Requirements

- EasyBuild framework
- yq for YAML parsing
- Bash shell

## Features

- **Installations defined through YAML files**: Makes it easy to specify software installation parameters and maintain installation recipes.
- **User-based logging**: Every installation attempt is logged with the user's name, installation start and end time, and the exit status.
- **Dry run option**: Allows users to see what would be installed and changed without making actual changes.
- **Common installation option**: Allows users to install microarchitecture independent code by setting the "common" field in the installation YAML file.
- **Parallel build option**: Allows users to build packages in parallel when the system supports it by setting the "parallel" field in the installation YAML file. By default EasyBuild will use all the cores.

## Installation YAML File Structure

Each installation is defined through a YAML file with the following fields:

- `application`: The name of the application to install.
- `version`: The version of the application.
- `toolchain`: (optional) The name of the compiler toolchain to use.
- `toolchain_version`: (optional) The version of the compiler toolchain.
- `suffix`: (optional) A suffix to append to the installation directory.
- `parallel`: (optional) An integer value to chose the number of cores to be used in the installation.
- `common`: (optional) A boolean value to specify a common installation.

An example YAML file would be:

```yaml
application: Go
version: 1.20.4
toolchain: GCC
toolchain_version: 11.3.0
suffix: 
parallel: 24
common: true
```

## Project Organization

```
.
├── bin
│   └── eb_wrapper.sh
├── conf
│   └── settings.yaml
├── installation_files
│   ├── GCC-11.3.0.yaml
│   └── Go-1.20.4.yaml
├── lib
│   └── utils.sh
└── logs
```

- `bin`: Contains the main script.
- `conf`: Configuration files for the project.
- `installation_files`: YAML files defining installations.
- `lib`: Utility script(s) for the main script.
- `logs`: Logs of installation attempts.

## Logging

The wrapper logs every installation attempt, registering the start time, end time, and exit status. These logs also record the username to maintain a record of

who performed the installation. Logs are located in the `logs` directory and each log file follows the format `${EASYCONFIG}-${TIMESTAMP}.log`.

```bash
# Log File
logs/${EASYCONFIG}-${USERNAME}-${TIMESTAMP}.log
```

## Contributions

Contributions are always welcome! Please read the [contribution guidelines](CONTRIBUTING.md) first.
