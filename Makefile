-include env.mk

L = lit
S = src
T = tool

# The order of chapters maters
CHAPS = \
	$L/des.nw \
	$L/layer.nw $L/riscv.nw $L/memlayout.nw \
	$L/boot.nw \
	$L/driver.nw \
	$L/log.nw \
	$L/prod.nw \
	$L/tool.nw

DOC = mos.pdf

C_SRC = \
	$S/start.c $S/main.c $S/uart.c $S/log.c

ASM_SRC = \
	$S/entry.S

SRC = ${ASM_SRC} ${C_SRC}

SCRIPTS = \
	$T/autolayout.sh $T/module.m4

MODULES = ${ASM_SRC:.S=} ${C_SRC:.c=}
OBJS = ${MODULES:=.o}

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
	${RM} ${OBJS}
	${RM} ${TOOLS} layout

clobber: clean
	${RM} -r $S $T
	${RM} mos-kernel ${DOC}

${SRC}: ${CHAPS} layout 
	notangle -R${@F} ${CHAPS} layout > $@

${SCRIPTS}: ${CHAPS}
	notangle -R${@F} ${CHAPS} > $@

layout: $T/autolayout
	${RM} layout
	@for f in ${SRC}; do \
		echo "generating layout for $$f..."; \
		./$T/autolayout $$f >> layout; \
	done

$T/autolayout.sh: $T/module.m4

