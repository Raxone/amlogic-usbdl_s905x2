# unsigned code loader for Amlogic bootrom

* https://github.com/frederic/amlogic-usbdl.git
* https://github.com/Raxone/amlogic-usbdl_s905x2.git

## Changes 
Minor changes of memory address from orginal frederic amlogic_usbdl for s905x2.

## Disclaimer
You will be solely responsible for any damage caused to your hardware/software/warranty/data/cat/etc...

## Description
Amlogic bootrom supports booting from USB. This method of boot requires an USB host to send a signed bootloader to the bootrom via USB port.

This tool exploits a [vulnerability](https://fredericb.info/2021/02/amlogic-usbdl-unsigned-code-loader-for-amlogic-bootrom.html) in the USB download mode to load and run unsigned code in Secure World.

## Supported targets
* A95x Max 
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

* chmod +x -R .         -fix permission command with point
* ./scripts/all.sh        

* All files be in dump_all dir.
* bl2aeskey -Bootloader(BL2) aeskey used for decrypt bootloader.
* bl2aesiv  -Bootloader(BL2) initialization vector(IV)used for decrypt bootloader.bin.
* bootloader.bin -Dumped main bootloader from box(BL2,FIP,BL3.1,BL33(U-boot)).
* bootloader_dec.bin -Decrypted bootloader.bin
* dtb.bin  -Device tree blob binary 
* dtb_dts  -Device tree blob txt
* root_rsa_keys.sha -sha256 of rootkeys used for encrypt booloader.
* pattern.secureboot.efuse -pattern writed in efuse from manufacturer to enable secureboot



```
./amlogic-usbdl <input_file> [<output_file>]
	input_file: payload binary to load and execute (max size 65280 bytes)
	output_file: file to write data returned by payload
```

## Payloads
Payloads are raw binary AArch64 executables. Some are provided in directory **payloads/**.

## License
Please see [LICENSE](/LICENSE).
