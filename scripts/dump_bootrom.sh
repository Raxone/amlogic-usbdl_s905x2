#!/bin/bash

##Reboot to BL1

echo "Reboot to BL1"

./bin/update identify 7
./bin/update bulkcmd "echo 12345"
./bin/update bulkcmd  2>/dev/null "bootloader_is_old"
./bin/update bulkcmd 2>/dev/null "erase_bootloader"
./bin/update bulkcmd 2>/dev/null "reset"

echo "BL1"

./bin/update identify 7

echo "Dump Efuse 0xFFFE0000"

./bin/amlogic-usbdl ./payloads/bin/memdump_over_usb_bl1.bin Bootrom.bin


