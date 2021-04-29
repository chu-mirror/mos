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
	$L/tool.nw

DOC = mos.pdf

C_SRC = \
	$S/spinlock.c $S/task.c \
	$S/start.c $S/main.c $S/log.c

HEADER = \
	$S/repdri.h

ASM_SRC = \
	$S/entry.S \
	$S/intvec.S

# extern source files
EX_SRC= \
	$S/uart.c

SRC = ${ASM_SRC} ${C_SRC}

SCRIPTS = \
	$T/autolayout.sh $T/module.m4 \
	$T/parse.sh $T/macros.m4 

MODULES = ${ASM_SRC:.S=} ${C_SRC:.c=}
OBJS = ${MODULES:=.o} ${EX_SRC:.c=.o}

TOOLS = \
	$T/autolayout \
	$T/parse

.SUFFIXES: .pdf
.tex.pdf:
	pdflatex $*; pdflatex $*; pdflatex $*

.PHONY: all doc qemu clean clobber tool prep gen-append

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
	${RM} ${TOOLS} append

clobber: clean
	${RM} mos-kernel ${DOC}

${SRC}: ${CHAPS} ${HEADER} append 
	notangle -R${@F} ${CHAPS} append > $@

${SCRIPTS}: ${CHAPS}
	notangle -R${@F} ${CHAPS} > $@

$S/repdri.h: ${CHAPS}
	notangle -R"repertoire of driver layer" ${CHAPS} > $@

append: $T/autolayout $T/parse
	${RM} append
	@for f in ${SRC}; do \
		echo "generating layout for $$f..."; \
		./$T/autolayout $$f >> append; \
	done
	./$T/parse >> append

$T/autolayout.sh: $T/module.m4
$T/parse.sh: $T/macros.m4

