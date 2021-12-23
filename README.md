# AltServer-Linux
AltServer for AltStore, but on-device

## Build Instruction

- Preparation: `git clone --recursive https://github.com/NyaMisty/AltServer-Linux`

- prerequisites: xxd, python, uuid, openssl, cmake, zlib

- Install corecrypto_static
    - download source code from https://developer.apple.com/security/, look for "Download corecrypto source (2020 OS Releases)"
    - unzip and put corecrypto in the root directory of this repo
    - replace

```
#include <mach/mach_time.h>
```

with following in file corecrypto_test/include/ccshadow_decls.h

```
#if CC_KERNEL || CC_DARWIN || CORECRYPTO_SIMULATE_POSIX_ENVIRONMENT
#include <mach/mach_time.h>
#endif
```

- Install cpprestsdk static lib

- Install boost static lib

- Build Configuration 1 (AltServer): Simple AltServer running on normal Linux host, working through usbmuxd
  ```
  make NO_USBMUXD_STUB=1 NO_UPNP_STUB=1
  ```
  
- Build Configuration 2 (AltServerNet): AltServer running on normal Linux host, working through manually specifying IP
  ```
  make NO_UPNP_STUB=1
  ```

- Build Configuration 3 (AltServerUPnP): AltServer running on iSH, working through manually specifying IP in a UPnP enabled router
  ```
  make
  ```

## Usage

- For build configuration 1 (AltServer): Works just like a normal AltServer on windows
  - Install IPA: `./AltServer -u [UDID] -a [AppleID account] -p [AppleID password] [ipaPath.ipa]`
  - Running as AltServer Daemon: `./AltServer`
- For build configuration 2 (AltServerNet): AltServer over Network
  - Install IPA: `./AltServerNet -u [UDID] -P [jitterbug pair file] -i [device IP] -a [AppleID account] -p [AppleID password] [ipaPath.ipa]`
  - Running as AltServer Daemon not supported
- For build configuration 2 (AltServerUPnP): AltServer over Network
  - Install IPA: `./AltServerUPnP -u [UDID] -P [jitterbug pair file] -i [device IP] -a [AppleID account] -p [AppleID password] [ipaPath.ipa]`
