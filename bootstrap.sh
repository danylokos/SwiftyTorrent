#!/bin/bash

set -e
set -o pipefail

ROOT_DIR=$(pwd)
DEPS_DIR="$ROOT_DIR/Thirdparties"

rm -rf $DEPS_DIR/

## libtorrent

LIBTORRENT_DIR="$DEPS_DIR/libtorrent"
LIBTORRENT_TARBALL="$LIBTORRENT_DIR/libtorrent.tar.gz"

echo "[*] downloading libtorrent..."
curl -L -o "$LIBTORRENT_TARBALL" --create-dirs \
	"https://github.com/arvidn/libtorrent/releases/download/v1.2.14/libtorrent-rasterbar-1.2.14.tar.gz"

echo "[*] extracting libtorrent..."
cd $LIBTORRENT_DIR
mkdir -p "$LIBTORRENT_DIR/src"
tar -xzf "$LIBTORRENT_TARBALL" --strip 1 \
	-C "$LIBTORRENT_DIR/src"

rm "$LIBTORRENT_TARBALL"

## boost

BOOST_DIR="$DEPS_DIR/boost"
BOOST_TARBALL="$BOOST_DIR/boost.tar.gz"

echo "[*] downloading boost..."
curl -L -o "$BOOST_TARBALL" --create-dirs \
	"https://boostorg.jfrog.io/artifactory/main/release/1.69.0/source/boost_1_69_0.tar.gz"

echo "[*] extracting boost..."
mkdir -p "$BOOST_DIR/src"
tar -xzf "$BOOST_TARBALL" --strip 1 \
	-C "$BOOST_DIR/src"

rm "$BOOST_TARBALL"

echo "[+] done."
