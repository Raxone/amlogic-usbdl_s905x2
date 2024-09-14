#!/bin/bash

echo "Dump Bootloader"
./bin/update mread store bootloader normal 0x200000 bootloader.bin
