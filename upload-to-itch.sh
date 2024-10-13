#!/bin/bash

# exit script early on failure
set -e

GAME=cooperra/punkin-chunkin
FILETITLE=punkinchunkin2024

if [ -n "$1" ]
then
    echo usage: "$0"
    echo
    echo "Upload all builds to Itch.io"
    echo
    echo "Step 1: Configure the Itch.io butler tool."
    echo "         -> https://itch.io/docs/butler/"
    echo "Step 2: Export-all within Godot editor."
    echo "         -> Project -> Export -> Export All -> Release"
    echo "Step 3: Run this script."
    echo "         -> $0"
    echo
    echo "Don't run this script if you just want to upload one build."
    echo 'Instead, run `butler push builds/$TAG/ '$GAME':$TAG`,'
    echo 'where $TAG is web, linux64, win64, macos, or android.'
    exit 1
fi

for TAG in web linux64 win64 macos android
do
    butler push builds/$TAG/ $GAME:$TAG --ignore .gitkeep
done

