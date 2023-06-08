# Build Instructions


## Package Build

```bash
$ PKG_PATH=PATH_TO_UBCARDS
$ 
$ cd ${PKG_PATH}
$ clickable clean --arch arm64
$ clickable build --arch arm64
$
$ clickable clean --arch armhf
$ clickable build --arch armhf
$
$ # work with the packages ...
$ touch ${PKG_PATH}/build/aarch64-linux-gnu/app/ubcards_0.1.0_arm64.click
$ touch ${PKG_PATH}/build/build/arm-linux-gnueabihf/app/ubcards_0.1.0_armhf.click
$
```
