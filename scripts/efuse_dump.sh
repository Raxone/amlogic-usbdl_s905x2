#!/bin/bash

##Reboot to BL1

echo "Reboot to BL1"

./bin/update identify 7
./bin/update bulkcmd "echo 12345"
./bin/update bulkcmd  2>/dev/null "bootloader_is_old"
./bin/update bulkcmd 2>/dev/null "erase_bootloader"
./bin/update bulkcmd 2>/dev/null "reset"


sleep 5


./bin/update identify 7

echo "Dump Efuse 0xFFFE0000"

./bin/amlogic-usbdl ./payloads/bin/memdump_over_usb_efuse.bin EFuse.bin

echo -n `hexdump -ve '1/1 "%.2X"' -n 0x20 -s 0x20 EFuse.bin` >> bl2aeskey
echo -n `hexdump -ve '1/1 "%.2X"' -n 0x10 -s 0x40 EFuse.bin` >> bl2ivkey
echo -n `hexdump -ve '1/1 "%.2X"' -n 0x20 -s 0xa0 EFuse.bin` >> pattern.secureboot.efuse
echo -n `hexdump -ve '1/1 "%.2X"' -n 0x20 -s 0x140 EFuse.bin` >> root_rsa_key.sha
