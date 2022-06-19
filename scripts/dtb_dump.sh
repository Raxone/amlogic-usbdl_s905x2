#!/bin/bash

echo "Dump DTB'S"
./bin/update mread mem 0x1000000 normal 0x30000 dtb.bin

dtc -I dtb -O dts dtb.bin -o dtb_dts
