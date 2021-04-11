-include env.mk

K = kernel
S = src
D = doc

OBJS = \
	$S/entry.o $S/start.o $S/main.o \
	$S/uart.o \
	$S/log.o

CHAPS = \
	$K/boot.nw \
	$K/spec.nw \
	$K/driver.nw \
	$K/log.nw

boot_subs = $S/entry.S $S/start.c $S/main.c
spec_subs = $S/types.h $S/param.h $S/memlayout.h $S/riscv.h
driver_subs = $S/uart.h $S/uart.c
log_subs = $S/log.h $S/log.c

SRC = \
	${boot_subs} \
	${spec_subs} \
	${driver_subs} \
	${log_subs}


.SUFFIXES: .pdf .nw
.tex.pdf:
	cd $D; pdflatex ../$*; pdflatex ../$*; pdflatex ../$*

.nw.tex:
	noweave -index -latex $< > $@

.PHONY: src doc qemu test clean clobber

mos-kernel: src ${OBJS} mos.ld
	${LD} ${LDFLAGS} -T mos.ld -o $@ ${OBJS}

src:
	@[ -d $S ] || mkdir $S && echo "Creating directory $S..."
	make ${SRC}

doc:
	@[ -d $D ] || mkdir $D && echo "Creating directory $D..."
	make ${CHAPS:.nw=.pdf}

qemu: mos-kernel 
	${QEMU} ${QEMUOPTS} -kernel mos-kernel

test: src
	cp $S/* -t ~/src/xv6-riscv/kernel

clean: 
	cd $D; ${RM} *.aux *.log
	cd $S; ${RM} *

clobber: clean
	${RM} -r $S $D
	${RM} mos-kernel

${boot_subs} : $K/boot.nw
	notangle -R${@F} $< > $@

${spec_subs} : $K/spec.nw
	notangle -R${@F} $< > $@

${driver_subs} : $K/driver.nw
	notangle -R${@F} $< > $@

${log_subs} : $K/log.nw
	notangle -R${@F} $< > $@

$S/start.o : $S/riscv.h $S/memlayout.h $S/param.h
$S/riscv.h : $S/types.h

