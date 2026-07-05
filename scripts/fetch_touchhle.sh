#!/bin/bash
set -e
cd "$(dirname "$0")/.."
rm -rf touchhle
git clone --recursive https://github.com/touchHLE/touchHLE.git touchhle
python3 scripts/patch_touchhle.py
