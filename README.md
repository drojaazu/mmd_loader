# Mega CD MMD Loader
This is an example project for loading and executing an MMD file as used in Sonic CD, and can be used as a basis for original Mega CD homebrew projects.

## Prerequisites
This code is M68000 assembly written in GNU Assembler syntax. You will need an GNU M68k cross-architecture toolchain to build it, as well as mkisofs (within the cdrtools project) for creating the disc image.

You will also need an MMD file from the Sonic CD disc to load for the example.

## Usage
    make setup
This will create the out/disc directory structure. Place any files you want on the disc within the out/disc directory. In particular, place the MMD file here.

    make disc
This will build the files and the disc image.

Please refer to http://sudden-desu.net/page/sega-mega-cd-mmd-loader for a tutorial.
