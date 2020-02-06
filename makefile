###################################################
# SEGA MEGA CD library
###################################################

SSCD_DIR?=/opt/mcdd

# Name of project; used as the filename for the disc
PROJECT:=SCDLOADER

# specify your M68k GNU toolchain prefix
M68K_PREFIX?=m68k-elf-

# project source code & resources directories
# C source code
SRC_DIR:=src
# C headers
INC_DIR:=inc
# Output directory (build files, final ROM, etc)
OUT_DIR:=out

# link scripts
CFG_DIR:=cfg

# The name of your final ROM binary
BIN=rom.bin

BOOT_DIR:=boot

DISC_DIR:=$(OUT_DIR)/disc
# Name of the CD boot sector binary
BOOTBIN:=boot.bin

###################################################
# You shouldn't need to configure anything further
# for your project below this line
###################################################

# fancy colors cause we're fancy
CLEAR=\033[0m
RED=\033[1;31m
YELLOW=\033[1;33m
GREEN=\033[1;32m

# NOTE: we assume all commands appear somewhere in PATH.
# If you've manually configured/built some of these
# tools and their directories are not listed in PATH
# you will need to specify the full path of each command

# m68k toolset
CC:=$(M68K_PREFIX)gcc
OBJCPY:=$(M68K_PREFIX)objcopy
NM:=$(M68K_PREFIX)nm
LD:=$(M68K_PREFIX)ld
AS:=$(M68K_PREFIX)as

# gather code & resources
SRC_C:=$(wildcard $(SRC_DIR)/*.c)
SRC_S:=$(wildcard $(SRC_DIR)/*.s)

# setup output objects
OBJ:=$(SRC_S:.s=.o)
#OBJ+=$(SRC_C:.c=.o)

OBJS:=$(addprefix $(OUT_DIR)/, $(OBJ))

# setup includes
INC:=-I$(BOOT_DIR) -I$(INC_DIR)

# default flags
DEF_FLAGS_AS:=-m68000 --register-prefix-optional --bitwise-or
DEF_FLAGS_LD:=-nostdlib --oformat binary

boot: BUILDTYPE=boot
boot: prebuild $(OUT_DIR)/$(BOOTBIN) postbuild

disc: BUILDTYPE=disc
disc: prebuild $(OUT_DIR)/$(PROJECT).iso postbuild

release: FLAGS:=$(DEF_FLAGS_M68K) -O3 -fuse-linker-plugin -fno-web -fno-gcse -fno-unit-at-a-time -fomit-frame-pointer -flto
release: BUILDTYPE=release
release: prebuild $(OUT_DIR)/$(BIN) postbuild

debug: FLAGS:=$(DEF_FLAGS_M68K) -O1 -ggdb -DDEBUG=1
debug: BUILDTYPE=debug
debug: prebuild $(OUT_DIR)/$(BIN) $(OUT_DIR)/rom.out $(OUT_DIR)/symbols.txt postbuild

all: release
default: release
Default: release
Release: release

.PHONY: clean

setup:
	@mkdir -p $(OUT_DIR)
	@mkdir -p $(DISC_DIR)
	@echo -e "${GREEN}Created work directories${CLEAR}"

clean:
	@rm -f $(OUT_DIR)/*.o $(OUT_DIR)/*.bin

cleandebug: clean
	@rm -f $(OUT_DIR)/symbols.txt

cleanRelease: cleanrelease
cleanDebug: cleandebug
cleanAsm: cleanasm



prebuild:
	@mkdir -p $(OUT_DIR)
	@mkdir -p $(DISC_DIR)
	@echo -e "${YELLOW}Beginning $(BUILDTYPE) ...${CLEAR}"

postbuild:
	@echo -e "${GREEN}Build complete!${CLEAR}"

$(OUT_DIR)/$(PROJECT).iso: $(OUT_DIR)/$(BOOTBIN)
	mkisofs -iso-level 1 -G $< -pad -V "$(PROJECT)" -o $@ $(DISC_DIR)

$(OUT_DIR)/$(BOOTBIN): $(OUT_DIR)/sp.bin $(OUT_DIR)/ip.bin
	$(AS) --register-prefix-optional -mcpu=68000 -I$(BOOT_DIR) $(BOOT_DIR)/boot.s -o $(OUT_DIR)/boot.out
	$(OBJCPY) -O binary $(OUT_DIR)/boot.out $@

$(OUT_DIR)/sp.o: $(BOOT_DIR)/sp.s 
	$(AS) $(DEF_FLAGS_AS) $(INC) -o $@ $<

$(OUT_DIR)/sp.bin: $(OUT_DIR)/sp.o
	$(LD) $(DEF_FLAGS_LD) -T $(CFG_DIR)/sp.ld -o $@ $<

$(OUT_DIR)/ip.o: $(BOOT_DIR)/ip.s
	$(AS) $(DEF_FLAGS_AS) $(INC) -o $@ $<

$(OUT_DIR)/ip.bin: $(OUT_DIR)/ip.o
	$(LD) $(DEF_FLAGS_LD) -T $(CFG_DIR)/ip.ld -o $@ $<

$(OUT_DIR)/%.o: %.c
	$(CC) $(FLAGS) -c $< -o $@

$(OUT_DIR)/%.o: %.s
	$(AS) --register-prefix-optional -mcpu=68000 $(INC) $< -o $@

