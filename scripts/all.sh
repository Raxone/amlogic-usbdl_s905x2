#!/bin/bash

#set -x 
set -o pipefail

debug=0
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
RESET='\033[m'

echo "USB Connect"



# Print debug function
# --------------------
print_debug()
{
   if [[ $debug == 1 ]]; then
      echo -e $YELLOW"$1"$RESET
   fi
}

# Wrapper for the Amlogic 'update' command
# ----------------------------------------
run_update_return()
{
    local cmd
    local need_spaces

    cmd="./bin/update identify 7"
    need_spaces=0
    if [[ "$1" == "bulkcmd" ]] || [[ "$1" == "tplcmd" ]]; then
       need_spaces=1
    fi
    cmd+=" $1"
    shift 1

    for arg in "$@"; do
        if [[ "$arg" =~ ' ' ]]; then
           cmd+=" \"     $arg\""
        else
           if [[ $need_spaces == 1 ]]; then
              cmd+=" \"     $arg\""
           else
              cmd+=" $arg"
           fi
        fi
    done

    update_return=""
    print_debug "\nCommand ->$CYAN $cmd $RESET"
    if [[ "$simu" != "1" ]]; then
       update_return=`eval "$cmd"`
    fi
    print_debug "- Results ---------------------------------------------------"
    print_debug "$RED $update_return $RESET"
    print_debug "-------------------------------------------------------------"
    print_debug ""
    return 0
}

# Wrapper to the Amlogic 'update' command
# ---------------------------------------
run_update()
{
    local cmd
    local ret=0

    run_update_return "$@"

    if `echo $update_return | grep -q "ERR"`; then
       ret=1
    fi

    return $ret
}

# Assert update wrapper
# ---------------------
run_update_assert()
{
    run_update "$@"
    if [[ $? != 0 ]]; then
       echo -e "
       		[NOT_FIND_DEVICES]
       					"
       exit 1
    fi
}

run_dump_bootloader()
{
    local cmd
    local need_spaces

    cmd="../bin/update mread store bootloader normal 0x200000 bootloader.bin"
    need_spaces=0
    if [[ "$1" == "bulkcmd" ]] || [[ "$1" == "tplcmd" ]]; then
       need_spaces=1
    fi
    cmd+=" $1"
    shift 1

    for arg in "$@"; do
        if [[ "$arg" =~ ' ' ]]; then
           cmd+=" \"     $arg\""
        else
           if [[ $need_spaces == 1 ]]; then
              cmd+=" \"     $arg\""
           else
              cmd+=" $arg"
           fi
        fi
    done

    update_return=""
    print_debug "\nCommand ->$CYAN $cmd $RESET"
    if [[ "$simu" != "1" ]]; then
       update_return=`eval "$cmd"`
    fi
    print_debug "- Results ---------------------------------------------------"
    print_debug "$RED $update_return $RESET"
    print_debug "-------------------------------------------------------------"
    print_debug ""
    return 0
}

run_dump_dtb()
{
    local cmd
    local need_spaces

    cmd="../bin/update mread mem 0x1000000 normal 0x30000 dtb.bin"
    need_spaces=0
    if [[ "$1" == "bulkcmd" ]] || [[ "$1" == "tplcmd" ]]; then
       need_spaces=1
    fi
    cmd+=" $1"
    shift 1

    for arg in "$@"; do
        if [[ "$arg" =~ ' ' ]]; then
           cmd+=" \"     $arg\""
        else
           if [[ $need_spaces == 1 ]]; then
              cmd+=" \"     $arg\""
           else
              cmd+=" $arg"
           fi
        fi
    done

    update_return=""
    print_debug "\nCommand ->$CYAN $cmd $RESET"
    if [[ "$simu" != "1" ]]; then
       update_return=`eval "$cmd"`
    fi
    print_debug "- Results ---------------------------------------------------"
    print_debug "$RED $update_return $RESET"
    print_debug "-------------------------------------------------------------"
    print_debug ""
    return 0
}

run_reboot_BL1()
{
    local cmd
    local need_spaces

    cmd="../bin/update identify 7"
	../bin/update bulkcmd  "echo 12345" 
	../bin/update bulkcmd  "bootloader_is_old"
	../bin/update bulkcmd  "erase_bootloader"
	../bin/update bulkcmd  "reset"
	 
    need_spaces=0
    if [[ "$1" == "bulkcmd" ]] || [[ "$1" == "tplcmd" ]]; then
       need_spaces=1
    fi
    cmd+=" $1"
    shift 1

    for arg in "$@"; do
        if [[ "$arg" =~ ' ' ]]; then
           cmd+=" \"     $arg\""
        else
           if [[ $need_spaces == 1 ]]; then
              cmd+=" \"     $arg\""
           else
              cmd+=" $arg"
           fi
        fi
    done

    update_return=""
    print_debug "\nCommand ->$CYAN $cmd $RESET"
    if [[ "$simu" != "1" ]]; then
       update_return=`eval "$cmd"`
    fi
    print_debug "- Results ---------------------------------------------------"
    print_debug "$RED $update_return $RESET"
    print_debug "-------------------------------------------------------------"
    print_debug ""
    return 0
}


run_update_assert



rm -rf ./dump_all
mkdir ./dump_all
cd ./dump_all

echo "Dump Bootloader"

run_dump_bootloader

echo "Dump DTB'S"

run_dump_dtb

echo "Reboot to BL1"

run_reboot_BL1

sleep 10

echo "Dump Efuse 0xFFFE0000"

../bin/amlogic-usbdl ../payloads/bin/memdump_over_usb_efuse.bin EFuse.bin

echo -n `hexdump -ve '1/1 "%.2X"' -n 0x20 -s 0x7c20 EFuse.bin` >> bl2aeskey
echo -n `hexdump -ve '1/1 "%.2X"' -n 0x10 -s 0x7c40 EFuse.bin` >> bl2ivkey
echo -n `hexdump -ve '1/1 "%.2X"' -n 0x20 -s 0x7ca0 EFuse.bin` >> pattern.secureboot.efuse
echo -n `hexdump -ve '1/1 "%.2X"' -n 0x20 -s 0x7d40 EFuse.bin` >> root_rsa_key.sha


file=$(cat bl2aeskey)
for aeskey in $file
do
echo -e "$aeskey\n"
done

file=$(cat bl2ivkey)
for ivkey in $file
do
echo -e "$ivkey\n"
done

echo "Decrypt bootloader"

openssl enc -aes-256-cbc -nopad -d -K $aeskey -iv $ivkey -in bootloader.bin -out bootloader_dec.bin

echo "dtb_to_dts"

dtc -q -I dtb -O dts dtb.bin -o dtb_dts

echo "Finish"






