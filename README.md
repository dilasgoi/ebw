# EasyBuild Command-Line Wrapper

This project is a command-line wrapper for the [EasyBuild](https://easybuild.io/) framework that facilitates software building and installation. It forces homogeneus reproducible installations defined through YAML files, user-based logging, and an option for dry runs.

## Table of Contents
- [Usage](#usage)
- [Requirements](#requirements)
- [Features](#features)
- [Project Organization](#project-organization)
- [Logging](#logging)

## Usage

The main script `eb_wrapper.sh` is used with flags to specify the YAML file for installation, the user, and an optional flag for dry run.

```bash
# Standard use
bin/eb_wrapper.sh -f <installation_file.yaml> -u <username>

# Dry run
bin/eb_wrapper.sh -f <installation_file.yaml> -u <username> -d
```

For example, to run a dry install for `Go-1.20.4.yaml` as user `Diego`, you would use:

```bash
bin/eb_wrapper.sh -f Go-1.20.4.yaml -u Diego -d
```

## Requirements

- EasyBuild framework
- yq for YAML parsing
- Bash shell

## Features

- Installations defined through YAML files: Makes it easy to specify software installation parameters and maintain installation recipes.
- User-based logging: Every installation attempt is logged with the user's name, installation start and end time, and the exit status.
- Dry run option: Allows users to see what would be installed and changed without making actual changes.

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

The wrapper logs every installation attempt, registering the start time, end time, and exit status. These logs also record the username to maintain a record of who performed the installation. Logs are located in the `logs` directory and each log file follows the format `${EASYCONFIG}-${TIMESTAMP}.log`.
```

