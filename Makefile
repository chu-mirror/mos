-include env.mk

K = kernel

OBJS = \
	$K/entry.o $K/start.o $K/main.o

CHAPS = \
	$K/boot.nw \
	$K/spec.nw

boot_subs = $K/entry.S $K/start.c $K/main.c
spec_subs = $K/types.h $K/param.h $K/memlayout.h $K/riscv.h

SRC = \
	${boot_subs} \
	${spec_subs}


.SUFFIXES: .pdf .nw
.tex.pdf:
	cd doc; pdflatex ../$*; pdflatex ../$*; pdflatex ../$*

.nw.tex:
	noweave -index -latex $< > $@

.nw:
	notangle -R$@ $< > $@.c
	${CC} -g -o $@ $@.c


$K/kernel: ${OBJS} kernel.ld
	${LD} ${LDFLAGS} -T kernel.ld -o $K/kernel ${OBJS}

src: ${SRC}
	@[ -d src ] || mkdir src && echo "Creating directory src..."
	cp ${SRC} -t src

docs:
	@[ -d doc ] || mkdir doc && echo "Creating directory doc..."
	make ${CHAPS:.nw=.pdf}

qemu: $K/kernel 
	$(QEMU) $(QEMUOPTS)

test: src
	cp src/* -t ~/src/xv6-riscv/kernel

clean: 
	cd $K; ${RM} *.c *.S *.h *.o *.d kernel
	cd ${DOC}; ${RM} *.aux *.log

clobber: clean
	rm -rf doc src

${boot_subs} : $K/boot.nw
	notangle -R${@F} $< > $@

${spec_subs} : $K/spec.nw
	notangle -R${@F} $< > $@

$K/start.o : $K/riscv.h $K/memlayout.h $K/param.h
$K/riscv.h : $K/types.h

