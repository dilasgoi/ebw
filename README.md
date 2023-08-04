# EasyBuild Command-Line Wrapper

This project is a simple command-line wrapper for the [EasyBuild](https://easybuild.io/) framework that assists in software building and installation in HPC environments. It enables homogeneous reproducible installations defined through JSON files and provides options for dry runs, microarchitecture independent installations, GPU-specific installations, and defining CUDA compute capabilities. One central objective of this project is to create a catalogue of successful installations, enabling the complete reproduction of the software stack when required.

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
- `jq` for JSON parsing
- `yq` for YAML parsing
- Bash shell

## Features

- **Installations defined through JSON files**: This makes it easy to specify software installation parameters and maintain installation recipes.
- **Logging**: Every installation attempt is logged with installation start and end time, and the exit status.
- **Dry run option**: Allows users to see what would be installed and changed without making actual changes.
- **Microarchitecture independent installation option**: Allows users to install software that is independent of specific microarchitectures by setting the "common" field in the installation JSON file to `true`.
- **GPU-specific installation option**: Enables users to specify installations that are specific to GPU environments.
- **CUDA compute capabilities**: Allows users to specify the CUDA compute capabilities for GPU-specific installations, applicable only if `gpu` is set to `true`.
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
└── README.md
```

- `bin`: Contains the main script.
- `config`: Configuration files for EasyBuild and this wrapper.
- `installation_files`: JSON files defining installations.
- `lib`: Utility scripts for the main script. The utility scripts are now separated into different files for better maintainability and readability:
    - `checks.sh`: Contains functions for checking and validating inputs and system configuration.
    - `configuration.sh`: Contains functions for configuring EasyBuild based on `settings.yaml` and setting up the installation environment depending on the options defined in the installation file.
    - `utils.sh`: Contains general utility functions used by the main script.
- `logs`: Logs of installation attempts.

## Installation JSON File Structure

Each installation is defined through a JSON file with the following structure:

- `easyconfigs`: An array of EasyBuild configurations, each consisting of:
    - `name`: The name of the EasyConfig file (`.eb`) to use for installation.
    - `options`: An object with keys and values representing the installation options. These are standard EasyBuild command line options.
    - `custom_options`: An object with keys and values representing custom options that are unique to this framework, and we can implement our own logic on them. The possible options include:
        - `common`: A boolean value to specify a microarchitecture independent installation. Default value is `false`.
        - `gpu`: A boolean value to specify a GPU-specific installation. Default value is `false`.
        - `enabled`: A boolean value to specify if this EasyConfig should be installed or skipped. Default value is `true`.

Example `AlphaFold.json` file:

```json
{
    "easyconfigs": [
        {
            "name": "CUDA-11.7.0.eb",
            "custom_options": {
                "common": true
            }
        },
        {
            "name": "AlphaFold-2.3.1-foss-2022a-CUDA-11.7.0.eb",
            "options": {
                "cuda-compute-capabilities": "7.5,8.0"
            },
            "custom_options": {
                "common": true,
                "gpu": true
            }
        }
    ]
}
```

## EasyBuild Configuration

The `configuration.sh` script in the `lib` directory is used to configure EasyBuild based on the `config/settings.yaml` file and to setup the installation environment depending on the options defined in the installation file. This configuration script overrides the system-wide EasyBuild installation configuration. 

The `settings.yaml` file includes settings such as the installation path, source path, build path, and a list of dependencies to hide. These configurations were previously set through environment variables or configuration files. You can define other EasyBuild configurations according to the [EasyBuild documentation](https://docs.easybuild.io/en/latest/Configuration.html).

This is how a typical EasyBuild settings file could look like:

```
installpath: "/scicomp/builds/Rocky/8.7/Skylake"
commonpath: "/scicomp/builds/Rocky/8.7/Common"
gpupath: "/scicomp/builds/Rocky/8.7/Skylake_GPU"
sourcepath: "/scicomp/builds/source"
buildpath: "/dev/shm/easybuild"
robot-paths: "/scicomp/builds/Rocky/8.7/Skylake/software/EasyBuild/4.8.0/easybuild/easyconfigs:/scicomp/admin/easybuild/easyconfigs"
hide-deps: "Bison,M4,XZ,XML-Parser,gettext,libdrm,LibTIFF,libGLU,FFmpeg,Little,CMS,PCRE,pixman,util-linux,Autoconf,Autotools,Automake,bzip2,freetype,zlib,X11,help2man,flex,intltool,Tk,Mesa,FLTK,LAME,xprop,Mako,x265,x264,Doxygen,hwloc,numactl,libtool,binutils,pkg-config,libpng,gperf,SQLite,libxml2,ImageMagick,Ghostscript,Glib,ncurses,NASM,Tcl,libreadline,ACTC,libjpeg-turbo,LittleCMS,GLib,cairo,GMP,Szip,Yasm,nettle,xorg-macros,cURL,JasPer,libffi,expat,FriBiDi,libunwind,Meson,Ninja,libglvnd,libpciaccess,UCX,fontconfig,kim-api,libmatheval,Guile,NASM,Tk,FFmpeg,Tkinter,molmod,yaff,gc,PROJ,libgit2,nlohmann_json,ATK,MPFR,nodejs,libopus,libvorbis,libtirpc,libunistring,FriBidi,pkgconfig,ScaFaCoS,pkg-config,gzip,tbb,archspec,PCRE,libjpeg-turbo,Voro++,pybind11,DB,UnZip,libdrm,libglvnd,lz4,zstd,libunwind,GLib,LLVM,DBus,Mesa,libGLU,snappy,NSPR,NSS,JasPer,libevent,libiconv,libfabric,makeinfo,groff,re2c,PMIx,Meson,double-conversion,PCRE2,Qt5,graphite2,ICU,GObject-Introspection,HarfBuzz,OpenJPEG,poppler,bwidget,Togl,libarc^Cve,Hypre,SuiteSparse,tcsh,time,Xvfb,libsndfile,UDUNITS,GLPK,Pango,Lua,libcerf,libgd,libdwarf,PAPI,libelf,libxsmm,Libint,Python,libvdwxc,Check,GDRCopy,hypothesis,scikit-build,networkx,pkgconf,UCC,OpenSSL,pkgconf,Brotli,libxslt,libgeotiff,GEOS,googletest,GTK2,Gdk-Pixbuf,GDAL,jbigkit,libdeflate,libogg,FLAC,SOCI,PostgreSQL,ant,yaml-cpp,arrow-R,Arrow,utf8proc,RapidJSON,RE2,FTGL,PyOpenGL,OpenPGM,libsodium,ZeroMQ,IPython,PyQt5,bsddb3,Pillow,Brotli,Perl,libyaml,Flask,PyYAML,cppy,spglib-python,paramz,arpack-ng,libctl,Harminv,libGDSII,libctl,libarchive,Qhull,cddlib,MPFR,GMP,FLINT,Arb,ANTIC,CoCoALib,nauty,xxd,VTK,protobuf,protobuf-python,LMDB,Zip,dill,git,UCX-CUDA,NCCL,Rust,JsonCpp,Bazel,make,jax,nsync,pytest-xdist,SWIG,giflib,flatbuffers-python,flatbuffers,ffnvcodec,libepoxy,at-spi2-core,at-spi2-atk,GTK3,CFITSIO,json-c,Xerces-C++,OpenEXR,Imath,Brunsli,Highway,LERC"
modules-tool: "Lmod"
job-backend: "Slurm"
hooks: "/scicomp/admin/easybuild/hooks/eb_hooks.py"
```

## Logging

Log files are located in the `logs` directory. Each installation attempt generates a log file named after the software, version, toolchain, optional CUDA version, and timestamp of the attempt. The `logs/history` file contains a summary of all installations.

## Contributions



Please see [CONTRIBUTING.md](CONTRIBUTING.md) for more information.

