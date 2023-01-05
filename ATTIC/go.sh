#!/bin/sh
./slc2byte.pl < levels.slc > levels.h
../dasm/dasm.exe kernel.asm -I../dasm/machines/atari2600 -lkernel.txt -f3 -v5 -okernel.bin
