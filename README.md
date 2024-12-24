# unsigned code loader for Amlogic bootrom
* This vulnerability was identified, and tools were created for it by [Frederic](https://github.com/frederic/amlogic-usbdl) and Raxone added support for the S905X2 chipset, as well as scripts and other necessary components.
* https://github.com/frederic/amlogic-usbdl.git
* https://github.com/repk/gxlimg.git

## Changes 

* 14.09.2024
* add extract acs.bin, bl33.bin(U-boot_LZ4)
* fix some script 

## Disclaimer
You will be solely responsible for any damage caused to your hardware/software/warranty/data/cat/etc...

## Description
Amlogic bootrom supports booting from USB. This method of boot requires an USB host to send a signed bootloader to the bootrom via USB port.

This tool exploits a [vulnerability](https://fredericb.info/2021/02/amlogic-usbdl-unsigned-code-loader-for-amlogic-bootrom.html) in the USB download mode to load and run unsigned code in Secure World.

## Supported targets
* A95x Max secured
* Probably work with all s905x2 box.

## Scripts
* all.sh		
* Dump bootloader+dtb, convert dtb to dts, dump efuse/sram extract asekey and iv,decrypt bootloader.
* All files be in dump_all dir.


## Usage
Box must be in usbdl mod.
To put box to usbdl mod with toothpick in AV hole on box push button and connect box with USB-A to USB-A cable with PC, keep pressed (10sec) after connect usb cable with pc.

* git clone https://github.com/Raxone/amlogic-usbdl_s905x2.git

* cd amlogic-usbdl_s905x2

* If board usb password protect, put password file in password folder,and rename to password.bin

* ./scripts/all.sh        

* All files be in dump_all dir.

* If board in nonsecured mode

* Only dump boot.bin dtb.bin bootloader.bin efuse.bin and extract dtb.bin to dts.

* If board in secured mode  


* bl2aeskey -Bootloader(BL2) aeskey used for decrypt bootloader.
* bl2aesiv  -Bootloader(BL2) initialization vector(IV)used for decrypt bootloader.bin.
* bootloader.bin -Dumped main bootloader from box(BL2,FIP,BL3.1,BL33(U-boot)).
* bootloader_dec.bin -Decrypted bootloader.bin
* dtb.bin  -Device tree blob binary 
* dtb_dts  -Device tree blob txt
* root_rsa_keys.sha -sha256 of rootkeys used for encrypt booloader.
* pattern.secureboot.efuse -pattern burned in efuse from manufacturer to enable secureboot

* Extract bootloader with gxlimg to part (bl2,bl30,bl31,bl33_u-boot) folder image.

```
./amlogic-usbdl <input_file> [<output_file>]
	input_file: payload binary to load and execute (max size 65280 bytes)
	output_file: file to write data returned by payload
```

## Payloads
Payloads are raw binary AArch64 executables. Some are provided in directory **payloads/**.

## License
Please see [LICENSE](/LICENSE).
