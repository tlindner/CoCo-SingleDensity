#!/bin/sh
set -e


decb dskini sd.dsk
decb copy -t allram.bas sd.dsk,ALLRAM.BAS
decb copy -t sd.bas sd.dsk,SD.BAS
lwasm -osd.bin -lsd.lst sd.asm
decb copy -2b sd.bin sd.dsk,SD.BIN
