-include env.mk

L = lit
S = src
T = tool

# The order of chapters matters
CHAPS = \
	$L/des.nw \
	$L/layer.nw $L/riscv.nw $L/memlayout.nw \
	$L/proc.nw \
	$L/boot.nw \
	$L/driver.nw \
	$L/log.nw \
	$L/prod.nw \
	$L/tool.nw

DOC = mos.pdf

C_SRC = \
	$S/spinlock.c $S/task.c \
	$S/start.c $S/main.c $S/log.c

HEADER = \
	$S/repdri.h

ASM_SRC = \
	$S/intvec.S \
	$S/entry.S

# extern source files
EX_SRC= \
	$S/uart.c

SRC = ${ASM_SRC} ${C_SRC}

SCRIPTS = \
	$T/autolayout.sh $T/module.m4

MODULES = ${ASM_SRC:.S=} ${C_SRC:.c=}
OBJS = ${MODULES:=.o} ${EX_SRC:.c=.o}

TOOLS = \
	$T/autolayout

.SUFFIXES: .pdf
.tex.pdf:
	pdflatex $*; pdflatex $*; pdflatex $*

.PHONY: all doc qemu clean clobber tool prep gen-layout

all: tool mos-kernel

doc: ${DOC}

mos-kernel: ${OBJS} mos.ld
	${LD} ${LDFLAGS} -T mos.ld -o $@ ${OBJS}

prep:
	@[ -d $S ] || mkdir $S && echo "Creating directory $S..."
	@[ -d $T ] || mkdir $T && echo "Creating directory $T..."

${DOC:.pdf=.tex}: ${CHAPS}
	noweave -index -latex ${CHAPS} > $@

tool: prep ${TOOLS}

qemu: mos-kernel 
	${QEMU} ${QEMUOPTS} -kernel mos-kernel

clean: 
	${RM} *.aux *.log *.tex
	${RM} ${OBJS} ${SRC} ${SRC:.c=.d} ${HEADER} ${EX_SRC:.c=.d}
	${RM} ${TOOLS} layout

clobber: clean
	${RM} mos-kernel ${DOC}

${SRC}: ${CHAPS} ${HEADER} layout 
	notangle -R${@F} ${CHAPS} layout > $@

${SCRIPTS}: ${CHAPS}
	notangle -R${@F} ${CHAPS} > $@

$S/repdri.h: ${CHAPS}
	notangle -R"repertoire of driver layer" ${CHAPS} > $@

layout: $T/autolayout
	${RM} layout
	@for f in ${SRC}; do \
		echo "generating layout for $$f..."; \
		./$T/autolayout $$f >> layout; \
	done

$T/autolayout.sh: $T/module.m4

