#!/bin/bash

set -Eeuo pipefail

mkdir /opt/gcc-arm-none-eabi
wget -qO - https://developer.arm.com/-/media/Files/downloads/gnu-rm/10.3-2021.10/gcc-arm-none-eabi-10.3-2021.10-x86_64-linux.tar.bz2 | tar xj --strip-components=1 -C /opt/gcc-arm-none-eabi
