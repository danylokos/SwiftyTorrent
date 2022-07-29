#!/bin/bash

set -e
set -o pipefail

LIBTORRENT_VER=1.2.17
BOOST_VER=1.69.0

ROOT_DIR=$(pwd)
DEPS_DIR="$ROOT_DIR/Thirdparties"

rm -rf "$DEPS_DIR/"

## libtorrent

LIBTORRENT_DIR="$DEPS_DIR/libtorrent-$LIBTORRENT_VER"
LIBTORRENT_XCFRAMEWORK_ZIP="$LIBTORRENT_DIR/libtorrent.xcframework.zip"

echo "[*] downloading libtorrent..."
curl -L -o "$LIBTORRENT_XCFRAMEWORK_ZIP" --create-dirs \
  "https://github.com/danylokos/libtorrent-Apple/releases/download/$LIBTORRENT_VER/libtorrent.xcframework.zip"

echo "[*] extracting libtorrent..."
cd "$LIBTORRENT_DIR"
unzip "$LIBTORRENT_XCFRAMEWORK_ZIP"

rm "$LIBTORRENT_XCFRAMEWORK_ZIP"

## boost

BOOST_DIR="$DEPS_DIR/boost-$BOOST_VER"
BOOST_TARBALL="$BOOST_DIR/boost-$BOOST_VER.tar.gz"

echo "[*] downloading boost..."
BOOST_VER_FIX=$(echo $BOOST_VER | sed -r "s/\./_/g")
curl -L -o "$BOOST_TARBALL" --create-dirs \
  "https://boostorg.jfrog.io/artifactory/main/release/$BOOST_VER/source/boost_$BOOST_VER_FIX.tar.gz"

echo "[*] extracting boost..."
mkdir -p "$BOOST_DIR"
tar -xzf "$BOOST_TARBALL" --strip 1 -C "$BOOST_DIR"

rm "$BOOST_TARBALL"

echo "[+] done."
