#!/bin/bash
set -euo pipefail

DEST=${DEST:-/opt/zyn-fusion}
PREFIX=${PREFIX:-/usr/local}

#This script needs:
# - To be run in the directory of the extracted tarball
# - To be run as root, or a user that can write to $DEST and $PREFIX
echo "This install script:"
echo "  1. Removes old ZynAddSubFX installs in $PREFIX and $DEST"
echo "  2. Installs zyn-fusion to $DEST"
echo "  3. Creates symbolic links in $PREFIX to the zyn-fusion install in\
 $DEST"
echo ""
echo "If you're ok with this press enter, otherwise press CTRL+C"
echo "and read the script for specifics"

read

#Verify this script is run in the correct directory
if [ ! -f ./zynaddsubfx ]
then
    echo "zynaddsubfx wasn't found in the current directory"
    echo "please run the script from witin the package directory"
    exit 1
fi

if [ ! -f ./zyn-fusion ]
then
    echo "zyn-fusion wasn't found in the current directory"
    echo "please run the script from witin the package directory"
    exit 1
fi

if [ ! -f ./libzest.so ]
then
    echo "libzest.so wasn't found in the current directory"
    echo "please run the script from witin the package directory"
    exit 1
fi

#Clean up any old installs
echo "Cleaning Up Any Old Zyn Installs"
echo "...Zyn-Fusion data dir"
rm -rf "$DEST"

echo "...ZynAddSubFX binaries"
rm -f "$PREFIX"/bin/zynaddsubfx
rm -f "$PREFIX"/bin/zyn-fusion

echo "...ZynAddSubFX banks"
rm -rf "$PREFIX"/share/zynaddsubfx/banks

echo "...ZynAddSubFX vst"
rm -rf "$PREFIX"/lib/vst/ZynAddSubFX.so

echo "...ZynAddSubFX lv2"
rm -rf "$PREFIX"/lib/lv2/ZynAddSubFX.lv2
rm -rf "$PREFIX"/lib/lv2/ZynAddSubFX.lv2presets

echo "Installing Zyn Fusion"
mkdir -p "$DEST"
cp -a ./* "$DEST"

echo "Installing Symbolic Links"

echo "...Zyn-Fusion"
ln -s "$DEST"/zyn-fusion  "$PREFIX"/bin/

echo "...ZynAddSubFX"
ln -s "$DEST"/zynaddsubfx "$PREFIX"/bin/

echo "...Banks"
mkdir -p "$PREFIX"/share/zynaddsubfx/
ln -s "$DEST"/banks "$PREFIX"/share/zynaddsubfx/banks

echo "...vst version"
mkdir -p "$PREFIX"/lib/vst
ln -s "$DEST"/ZynAddSubFX.so "$PREFIX"/lib/vst/

echo "...lv2 version"
mkdir -p  "$PREFIX"/lib/lv2/
ln -s "$DEST"/ZynAddSubFX.lv2        "$PREFIX"/lib/lv2/
ln -s "$DEST"/ZynAddSubFX.lv2presets "$PREFIX"/lib/lv2/

echo "...bash completion"
bashcompdir=$(pkg-config --variable=completionsdir bash-completion)
case "$bashcompdir" in
    /usr/share/*)
        bashcompdir="$PREFIX${bashcompdir#/usr}"
        ;;
esac
if [ "$bashcompdir" ]
then
    ln -sf /opt/zyn-fusion/completions/zyn-fusion "$bashcompdir"/zyn-fusion
fi

echo ""
echo "Thank you for supporting Zyn-Fusion"
echo "You can now use the 3.0.3 release via a LV2/VST plugin host or"
echo "by running the standalone via 'zynaddsubfx'"
