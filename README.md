# EasyBuild Command-Line Wrapper

This project is a simple command-line wrapper for the [EasyBuild](https://easybuild.io/) framework that assists in software building and installation in HPC environments. It enables homogeneous reproducible installations defined through JSON files and provides options for dry runs, microarchitecture independent installations, GPU-specific installations, and custom options. One central objective of this project is to create a catalogue of successful installations, enabling the complete reproduction of the software stack when required.

It follows a similar approach as the one described in the [EasyBuild documentation about Easystacks](https://docs.easybuild.io/easystack-files/), but offers simplicity and flexible customization options out of the EasyBuild Framework. However, utilizing both easystacks and hooks should generally provide a more general and authentic solution.

## Table of Contents
- [Usage](#usage)
- [Requirements](#requirements)
- [Features](#features)
- [Installation JSON File Structure](#installation-json-file-structure)
- [Project Organization](#project-organization)
- [EasyBuild Configuration](#easybuild-configuration)
- [Logging](#logging)
- [Bash completion](#bash-completion)
- [Contributions](#contributions)

## Features

- **JSON-based Configuration**: Define installation parameters, recipes, and custom options through JSON files, allowing flexibility and easy version control.
- **Logging**: Records every installation attempt with information such as start/end times and exit status.
- **Microarchitecture Flexibility**: Support for both common microarchitecture-independent installations and specific configurations tailored to particular hardware.
- **Conditional Installation Options**: Enable or disable specific installations or features within the installation JSON files, providing fine-grained control over the process.
- **Extensible Customization**: Utilize custom options to adapt to various needs, including GPU-specific installations, different versions, toolchains, and more.

## Requirements

- EasyBuild
- `jq` for JSON parsing
- `yq` for YAML parsing
- Bash shell

## Usage

The main script `ebw` is used with flags to specify the JSON file for installation, along with optional flags for a dry run or alternative EasyBuild settings file.

```bash
# Standard use
ebw -f <installation_file.json>

# Dry run (print actions without executing)
ebw -f <installation_file.json> -d

# Specify an alternative EasyBuild settings file
ebw -f <installation_file.json> -c <alternative_config_file.yaml>

# Combination of dry run and alternative settings
ebw -f <installation_file.json> -d -c <alternative_config_file.yaml>
```

For example, to install software defined in `AlphaFold.json`:

```bash
ebw -f AlphaFold.json
```

To perform a dry run for `AlphaFold.json`:

```bash
ebw -f AlphaFold.json -d
```

To use an alternative EasyBuild settings file:

```bash
ebw -f AlphaFold.json -c my_custom_settings.yaml
```

*Note: .json file extension is not mandatory.*

The `-d` flag enables dry run mode, which prints the actions without executing them. The `-c` flag allows specifying an alternative EasyBuild settings file within the `config` directory. If not provided, the default `settings.yaml` file will be used.

With bash completion enabled, you can use the `Tab` key to auto-complete filenames when using the `-f` flag:

```bash
ebw -f Alph # Press Tab after typing "Alpha" to auto-complete ("AlphaFold", for example) or see available options.
```

## Project Organization

```
.
├── bin
│   └── ebw 
├── config
│   └── settings.yaml
├── CONTRIBUTING.md
├── installation_files
│   ├── a [AFNI, AIMAll, AlphaFold, ...]
│   ├── b [Bazel, BerkeleyGW, Boost, ...]
│   ├── c [CASTEP, CCP4, cuDNN, ...]
    ...   
│   └── v [VAMPIR, VASP]
├── lib
│   ├── checks.sh
│   ├── configuration.sh
│   ├── ebw_completion.sh
│   └── utils.sh
├── LICENSE.md
├── logs
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
    - `custom-options`: An object with keys and values representing custom options that are unique to this framework, and we can implement our own logic on them. The possible options include:
        - `common`: A boolean value to specify a microarchitecture independent installation. Default value is `false`.
        - `gpu`: A boolean value to specify a GPU-specific installation. Default value is `false`.
        - `enabled`: A boolean value to specify if this EasyConfig should be installed or skipped. Default value is `true`.
        - `comments`: A comment section.

Example `AlphaFold.json` file:

```json
{
    "easyconfigs": [
        {
            "name": "Java-11.0.18.eb",
            "custom-options": {
                "common": "true"
            }
        },
	{
            "name": "Java-11.eb",
            "custom-options": {
                "common": "true"
            }
        },
	{
            "name": "CUDA-11.7.0.eb",
            "custom-options": {
                "common": "true"
            }
        },    
	{
            "name": "cuDNN-8.4.1.50-CUDA-11.7.0.eb",
            "custom-options": {
                "common": "true"
            }
        },
        {
            "name": "AlphaFold-2.3.1-foss-2022a-CUDA-11.7.0.eb",
            "options": {
                "cuda-compute-capabilities": "7.5,8.0"    
	    },
	    "custom-options": {
                "gpu": "true"
	    }
        }
    ]
}
```

## EasyBuild Configuration

Functions in the `configuration.sh` script in the `lib` directory are used to configure EasyBuild based on a settings file located in the `config` directory, and to set up the installation environment depending on the options defined in the installation file. By default, it uses the `config/settings.yaml` file, but you can override this by providing an alternative settings file using the `-c` modifier followed by the filename. This file has to be placed in the `config` directory. This configuration script overrides the system-wide EasyBuild installation configuration.

The settings file includes settings such as the installation path, source path, build path, and a list of dependencies to hide. You can define other EasyBuild configurations according to the [EasyBuild documentation](https://docs.easybuild.io/en/latest/Configuration.html).

This is how a typical EasyBuild settings file could look like:

```yaml
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

Log files are located in the `logs` directory. Each installation attempt generates a log file named after the easyconfig file, and timestamp of the attempt. 

## Bash Completion

The `ebw` tool includes a Bash completion script. The completion script, `ebw_completion.sh`, is located in the `lib` directory. You can enable this feature by:

1. **Source the Completion Script**: If the completion script is stored in a file (e.g., `ebw_completion.sh`), you can enable it by sourcing the script in your shell profile. Add the following line to your `.bashrc` or `.bash_profile`:

   ```bash
   source /path/to/ebw_completion.sh
   ```

2. **Set the Installation Files Directory**: You can specify the directory of the installation files by setting the `EBW_INSTALLATION_FILES_DIR` environment variable. If you don't set this variable, the completion script will default to a specified path. Add this line to your `.bashrc` or `.bash_profile` to set the directory:

   ```bash
   export EBW_INSTALLATION_FILES_DIR="/custom/path/to/installation_files"
   ```

   Replace `/custom/path/to/installation_files` with the actual path to your installation files.

   You can also replace the default value defined in the completion script.

3. **Reload your Shell Profile**: After making these changes, you may need to reload your shell profile or restart your terminal for the changes to take effect.

   ```bash
   source ~/.bashrc # or source ~/.bash_profile
   ```
   
With bash completion enabled, you can use the `Tab` key to auto-complete filenames when using the `-f` flag:

```bash
ebw -f Alph # Press Tab after typing "Alpha" to auto-complete ("AlphaFold", for example) or see available options.
```

## Contributions

Please see [CONTRIBUTING.md](CONTRIBUTING.md) for more information.

