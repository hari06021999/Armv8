# Test commands.
#	make run
#	Ctrl-A X (Exit)


IMAGE := imx8mm.elf

CROSS = aarch64-linux-gnu
CC = ${CROSS}-gcc
AS = ${CROSS}-as
LD = ${CROSS}-ld
OBJDUMP = ${CROSS}-objdump
CFLAGS =  -mcpu=cortex-a53 -Wall -Wextra -g
#	-mcpu=name
#		Specify the name of the target processor
#	-Wall
#		Turns on all optional warnings which are desirable for normal code
#	-Wextra
#		This enables some extra warning flags that are not enabled by -Wall
#	-g  Produce debugging information in the operating system's native format.
#		 GDB can work with this debugging information.

ASM_FLAGS = -mcpu=cortex-a57 -g

OBJS = boot.o vector.o exception.o imx8mm.o gic_v3.o uart.o psw.o aarch64.o timer.o
# OBJS = boot.o gic-pl390.o imx8mm.o


all: $(IMAGE)

${IMAGE}: linker.ld ${OBJS}
	${LD} -T linker.ld $^ -o $@
	${OBJDUMP} -D imx8mm.elf > imx8mm.list

#boot.o: boot.S
%.o: %.S
	# ${AS} ${ASM_FLAGS} -c $< -o $@
	$(CC) ${CFLAGS} -c $< -o $@			# for include header file in assembly

%.o : %.c
	$(CC) ${CFLAGS} -c $<

run:
	$(MAKE) imx8mm.elf
	# qemu-system-aarch64 -machine virt -cpu cortex-a57 -m 128 -serial stdio -nographic -nodefaults -imx8mm imx8mm.elf
	# qemu-system-aarch64 -machine virt,gic_version=3 -cpu cortex-a57 -nographic -imx8mm imx8mm.elf
	#qemu-system-aarch64 -machine virt -cpu cortex-a57 -nographic -imx8mm imx8mm.elf

gen_tags:
	./gen_tags.sh

clean_tags:
	rm -rf tags cscope*

clean:
	rm -f *.o *.elf *.list

.PHONY: run gen_tags clean_tags clean
