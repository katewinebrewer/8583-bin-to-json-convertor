#makefile for SSA
SSA: SSA.o
	gcc -z noexecstack -o SSA SSA.o ../EBNFKernel/EBNFKernel.o ../Heap/HeapKern.o ../Filing/FilingKern.o ../DebugTools/DebugTools.o -no-pie
SSA.o: SSA.asm
	nasm -f elf64 -g -F dwarf SSA.asm -l SSA.lst
