#!/bin/bash

#set -x 
#set -o pipefail

debug=0
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
RESET='\033[m'
TOOL_PATH="$(pwd)"
soc=g12a

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

    cmd="$TOOL_PATH/bin/update 2>/dev/null"
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
    run_update_return identify 7

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

run_dump_boot()
{
    local cmd
    local need_spaces

    cmd="../bin/update mread store boot normal 0x1000000 boot.bin"
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
	../bin/update bulkcmd >/dev/null "echo 12345" 
	../bin/update bulkcmd >/dev/null "bootloader_is_old"
	../bin/update bulkcmd >/dev/null "erase_bootloader"
	../bin/update bulkcmd >/dev/null "reset"
	 
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


cp -a ./dump_all backup_`date +"%m%d_%H%M"`
rm -rf ./dump_all
mkdir ./dump_all
cd ./dump_all

echo "Dump Bootloader"

run_dump_bootloader

echo "Dump DTB'S"

run_dump_dtb

echo "Dump Boot"

run_dump_boot

echo "Reboot to BL1"

run_reboot_BL1

sleep 10

# Check if the board is locked with a password
# --------------------------------------------
need_password=0
run_update_return identify 7
if `echo $update_return | grep -iq "Password check NG"`; then
   need_password=1
fi
if [[ $need_password == 1 ]]; then
   if [[ -z $password ]]; then
     echo "The board is locked with a password, put password.bin in folder password !"
     echo -n "Unlocking usb interface "
     run_update_return password $TOOL_PATH/password/password.bin
     run_update_return identify 7
     if `echo $update_return | grep -iq "Password check OK"`; then
         echo -e $GREEN"Password [OK]"$RESET
      else
         echo -e $RED"[KO]"$RESET
         echo "It seems you provided an incorrect password !"
         exit 1
      fi
   fi
fi



# Check if board is secure
# ------------------------
secured=0
value=0
# Board secure info is extracted from SEC_AO_SEC_SD_CFG10 register
if [[ "$soc" == "gxl" ]]; then
   run_update_return rreg 4 0xc8100228
   value=0x`echo $update_return|grep -i c8100228|awk -F: '{gsub(/ /,"",$2);print $2}'`
   print_debug "0xc8100228      = $value"
   value=$(($value & 0x10))
   print_debug "Secure boot bit = $value"
fi
if [[ "$soc" == "axg" ]] || [[ $soc == "txlx" ]] || [[ $soc == "g12a" ]]; then
   run_update_return rreg 4 0xff800228
   value=0x`echo $update_return|grep -i ff800228|awk -F: '{gsub(/ /,"",$2);print $2}'`
   print_debug "0xff800228      = $value"
   value=$(($value & 0x10))
   print_debug "Secure boot bit = $value"
fi
if [[ "$soc" == "m8" ]]; then
   run_update_return rreg 4 0xd9018048
   value=0x`echo $update_return|grep -i d9018048|awk -F: '{gsub(/ /,"",$2);print $2}'`
   print_debug "0xd9018048      = $value"
   value=$(($value & 0x80))
   print_debug "Secure boot bit = $value"
fi
if [[ $value != 0 ]]; then
   secured=1
   echo "Board is in secure mode"
fi

echo "Dump Efuse 0xFFFE0000"

echo "Run Amlogic-usbdl playload" 
 
../bin/amlogic-usbdl ../payloads/bin/memdump_over_usb_efuse.bin EFuse.bin

if [[ $value != 0 ]]; then
   secured=1
   
echo "Board is in secure mode"

echo -n `hexdump -ve '1/1 "%.2X"' -n 0x20 -s 0x7c20 EFuse.bin` >> bl2aeskey
echo -n `hexdump -ve '1/1 "%.2X"' -n 0x10 -s 0x7c40 EFuse.bin` >> bl2ivkey
echo -n `hexdump -ve '1/1 "%.2X"' -n 0x20 -s 0x7ca0 EFuse.bin` >> pattern.secureboot.efuse
echo -n `hexdump -ve '1/1 "%.2X"' -n 0x20 -s 0x7d40 EFuse.bin` >> root_rsa_key.sha


file=$(cat bl2aeskey)
for aeskey in $file
do
echo >/dev/null "$aeskey\n"
done

file=$(cat bl2ivkey)
for ivkey in $file
do
echo >/dev/null "$ivkey\n"
done

echo "Decrypt bootloader"

openssl enc -aes-256-cbc -nopad -d -K $aeskey -iv $ivkey -in bootloader.bin -out bootloader_dec.bin

echo "Extract All"

#dd if=bootloader_dec.bin skip=8 count=120 of=bl2_cfg.bin status=none
dd if=bootloader_dec.bin skip=128 count=32 of=fip.bin status=none
dd if=bootloader_dec.bin bs=1 skip=680 count=1036 of=bl2key.bin status=none
dd if=bootloader_dec.bin bs=1 skip=2928 count=1036 of=rootkey.bin status=none
dd if=bootloader.bin bs=1 skip=500736 count=787968 of=u-boot_enc.bin status=none
#dd >/dev/null if=boot.bin bs=1 skip=2304 count=9734268 of=boot_enc.bin status=none



echo -n `hexdump -ve '1/1 "%.2X"' -n 0x20 -s 0x1b4 fip.bin` >> bl3xaeskey
#echo -n `hexdump -ve '1/1 "%.2X"' -n 0x20 -s 0x1354 fip.bin` >> kernelaeskey

echo "Decrypt U-boot"

file=$(cat bl3xaeskey)
for bl3xaeskey in $file
do
echo >/dev/null "$bl3xaeskey\n"
done

file=$(cat bl2ivkey)
for ivkey in $file
do
echo >/dev/null "$ivkey\n"
done

openssl enc -aes-256-cbc -nopad -d -K $bl3xaeskey -iv $ivkey -in u-boot_enc.bin -out u-boot_dec.bin

#echo "Decrypt Boot"

#file=$(cat kernelaeskey)
#for kernelaeskey in $file
#do
#echo >/dev/null "$kernelaeskey\n"
#done

#file=$(cat bl2ivkey)
#for ivkey in $file
#do
#echo >/dev/null "$ivkey\n"
#done

#openssl enc -aes-256-cbc -nopad -d -K $kernelaeskey -iv $ivkey -in boot.bin -out boot_dec.bin

fi

echo "Extract_DTB"

../python/extract-dtb -o dts dtb.bin

echo "DTB_to_DTS"

cd dts

dtc -q -I dtb -O dts -o dts1 01_dtbdump_Amlogic.dtb
dtc -q -I dtb -O dts -o dts2 02_dtbdump_Amlogic.dtb


echo "Extract Bootloader signed bl2,bl30,bl31,bl33_uboot" 

cd ..

mkdir image

../bin/gxlimg -e bootloader_dec.bin image








echo "Done"





















