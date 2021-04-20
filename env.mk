# riscv64-unknown-elf- or riscv64-linux-gnu-
# perhaps in /opt/riscv/bin
TOOLPREFIX = riscv64-unknown-elf-

QEMU = qemu-system-riscv64

CC = $(TOOLPREFIX)gcc
AS = $(TOOLPREFIX)gas
LD = $(TOOLPREFIX)ld
OBJCOPY = $(TOOLPREFIX)objcopy
OBJDUMP = $(TOOLPREFIX)objdump

# -Wall: turn on all warnings
# -Werror: make all warning into errors
# -O: optimize
# -fno-omit-frame-pointer: do not omit frame pointer
# -ggdb: produce debugging information for use by GDB
# -MD: print rules used by make
# -mcmodel=medany: generate code for the medium-any code model
# -ffreestanding: A freestanding enviroment is one in which the standard library may not exitst
# -fno-common: ...
# -nostdlib: do not use the standard system startup files or libraries when linking
# -mno-relax: ...
CFLAGS = -Wall -Werror -O -fno-omit-frame-pointer -ggdb
CFLAGS += -MD
CFLAGS += -mcmodel=medany
CFLAGS += -ffreestanding -fno-common -nostdlib -mno-relax
CFLAGS += -I.
CFLAGS += $(shell $(CC) -fno-stack-protector -E -x c /dev/null >/dev/null 2>&1 && echo -fno-stack-protector)
CFLAGS += -fno-pie -no-pie

LDFLAGS = -z max-page-size=4096

# Prevent deletion of intermediate files, e.g. cat.o, after first build, so
# that disk image changes after first build are persistent until clean.  More
# details:
# http://www.gnu.org/software/make/manual/html_node/Chained-Rules.html
.PRECIOUS: %.o

# try to generate a unique GDB port
GDBPORT = $(shell expr `id -u` % 5000 + 25000)
# QEMU's gdb stub command line changed in 0.11
QEMUGDB = $(shell if $(QEMU) -help | grep -q '^-gdb'; \
	then echo "-gdb tcp::$(GDBPORT)"; \
	else echo "-s -p $(GDBPORT)"; fi)
ifndef CPUS
CPUS := 2
endif

QEMUOPTS = -machine virt -bios none -m 128M -smp $(CPUS) -nographic
# QEMUOPTS += -drive file=fs.img,if=none,format=raw,id=x0
# QEMUOPTS += -device virtio-blk-device,drive=x0,bus=virtio-mmio-bus.0


.gdbinit: .gdbinit.tmpl-riscv
	sed "s/:1234/:$(GDBPORT)/" < $^ > $@

qemu-gdb: kernel 
	@echo "*** Now run 'gdb' in another window." 1>&2
	$(QEMU) $(QEMUOPTS) -S $(QEMUGDB)

