# Build Instructions


## Package Build

```bash
$ PKG_PATH=PATH_TO_TAGGER
$ 
$ cd ${PKG_PATH}
$ clickable clean --arch arm64
$ clickable build --arch arm64
$
$ clickable clean --arch armhf
$ clickable build --arch armhf
$
$ # work with the packages ...
$ touch ${PKG_PATH}/build/aarch64-linux-gnu/app/tagger_0.17.0_arm64.click
$ touch ${PKG_PATH}/build/build/arm-linux-gnueabihf/app/tagger_0.17.0_armhf.click
$
```
