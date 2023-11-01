
set path ="C:\Program Files (x86)\Arm GNU Toolchain aarch64-none-elf\12.3 rel1\bin" 

aarch64-none-elf-gcc -Wall -O2 -ffreestanding -nostdinc -nostdlib -nostartfiles -mcpu=cortex-a53+fp+simd -c src/boot.S -o obj/boot.o

aarch64-none-elf-gcc -Wall -O2 -ffreestanding -nostdinc -nostdlib -nostartfiles -mcpu=cortex-a53+fp+simd -c src/aarch64.c -o obj/aarch64.o
aarch64-none-elf-gcc -Wall -O2 -ffreestanding -nostdinc -nostdlib -nostartfiles -mcpu=cortex-a53+fp+simd -c src/exception.c -o obj/exception.o
aarch64-none-elf-gcc -Wall -O2 -ffreestanding -nostdinc -nostdlib -nostartfiles -mcpu=cortex-a53+fp+simd -c src/gic_v3.c -o obj/gic_v3.o
aarch64-none-elf-gcc -Wall -O2 -ffreestanding -nostdinc -nostdlib -nostartfiles -mcpu=cortex-a53+fp+simd -c src/main.c -o obj/main.o
aarch64-none-elf-gcc -Wall -O2 -ffreestanding -nostdinc -nostdlib -nostartfiles -mcpu=cortex-a53+fp+simd -c src/vector.S -o obj/vector.o






aarch64-none-elf-ld -nostdlib obj/boot.o obj/aarch64.o obj/exception.o obj/gic_v3.o obj/main.o obj/vector.o -T src/linker.ld -o obj/imx8.elf


aarch64-none-elf-objdump -D obj/imx8.elf > obj/kernel_disassemble.txt

aarch64-none-elf-objcopy -O binary obj/imx8.elf obj/imx8.img
