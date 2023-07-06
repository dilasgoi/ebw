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

## EasyBuild configuration

EasyBuild wrapper retrieves its configuration from the `conf/settings.yaml` file. This file includes settings such as the installation path, source path, build path, and a list of dependencies to hide. Previously these configurations were set using environment variables, but now they are conveniently located in this YAML file.

Here is an example of `settings.yaml`:

```yaml
installpath: "/scicomp/builds/Rocky/8.7/Skylake"
commonpath: "/scicomp/builds/Rocky/8.7/Common"
sourcepath: "/scicomp/builds/source"
buildpath: "/dev/shm/easybuild"
hide-deps: "Bison,M4,XZ,XML-Parser,gettext,libdrm,LibTIFF,libGLU,FFmpeg,Little,CMS,PCRE,pixman,util-linux,Autoconf,Autotools,Automake,bzip2,freetype,zlib,X11,help2man,flex,intltool,Tk,Mesa,FLTK,LAME,xprop,Mako,x265,x264,Doxygen,hwloc,numactl,libtool,binutils,pkg-config,libpng,gperf,SQLite,libxml2,ImageMagick,Ghostscript,Glib,ncurses,NASM,Tcl,libreadline,ACTC,libjpeg-turbo,LittleCMS,GLib,cairo,GMP,Szip,Yasm,nettle,xorg-macros,cURL,JasPer,libffi,expat,FriBiDi,libunwind,Meson,Ninja,libglvnd,libpciaccess,UCX,fontconfig,kim-api,libmatheval,Guile,NASM,Tk,FFmpeg,Tkinter,molmod,yaff,PLUMED,gc,h5py,PROJ,libgit2,nlohmann_json,ATK,MPFR,nodejs,libopus,libvorbis,libtirpc,libunistring,FriBidi,pkgconfig,ScaFaCoS,pkg-config,gzip,tbb,archspec,PCRE,libjpeg-turbo,Voro++,pybind11,CMake,DB,UnZip,libdrm,libglvnd,lz4,zstd,libunwind,GLib,LLVM,DBus,Mesa,libGLU,snappy,NSPR,NSS,JasPer,libevent,libiconv,libfabric,makeinfo,groff,re2c,PMIx,Meson,double-conversion,PCRE2,Qt5,graphite2,ICU,GObject-Introspection,HarfBuzz,OpenJPEG,poppler,bwidget,Togl,libarchive,Qhull,cddlib,MPFR,GMP,FLINT,Arb,ANTIC,CoCoALib,nauty,xxd,VTK,protobuf,protobuf-python,LMDB,Zip,dill,git,UCX-CUDA,NCCL,Rust,JsonCpp,Bazel"
modules-tool: "Lmod"
```

The fields in the `settings.yaml` file represent the following:

- `installpath`: The base path where the software will be installed.
- `commonpath`: The base path where common software will be installed when the `common` field in the installation YAML file is set to `true`.
- `sourcepath`: The path where source files are located.
- `buildpath`: The temporary directory where the software will be built before being installed to the `installpath` or `commonpath`.
- `hide-deps`: A comma-separated list of dependencies that EasyBuild should not load as modules.
- `modules-tool`: The module system used by your HPC environment (currently only "Lmod" is supported).

In addition to these settings, you can define other EasyBuild configurations according to the [EasyBuild documentation](https://docs.easybuild.io/en/latest/Configuration.html).

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
