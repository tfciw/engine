#!/bin/bash
#
# Copyright 2013 The Flutter Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Run a tool that generates a treemap showing the contribution of each
# component to the size of a binary.
#
# Usage:
#   binary_size_treemap.sh [binary_path] [output_dir]

set -e

INPUT_PATH="$(cd $(dirname "$1"); pwd -P)/$(basename "$1")"
DEST_DIR="$(cd $(dirname "$2"); pwd -P)/$(basename "$2")"
CI_DIRECTORY=$(cd $(dirname "${BASH_SOURCE[0]}"); pwd -P)
ENGINE_BUILDROOT=$(cd "$CI_DIRECTORY/../.."; pwd -P)

if [ "$(uname)" == "Darwin" ]; then
  NDK_PLATFORM="darwin-x86_64"
else
  NDK_PLATFORM="linux-x86_64"
fi
ADDR2LINE="third_party/android_tools/ndk/toolchains/aarch64-linux-android-4.9/prebuilt/$NDK_PLATFORM/bin/aarch64-linux-android-addr2line"

# Run the binary size script from the buildroot directory so the treemap path
# navigation will start from there.
cd "$ENGINE_BUILDROOT"
RUN_BINARY_SIZE_ANALYSIS="third_party/dart/third_party/binary_size/src/run_binary_size_analysis.py"
if [[ ! -f "$RUN_BINARY_SIZE_ANALYSIS" ]]; then
  # Fallback to the old path until https://dart-review.googlesource.com/c/sdk/+/332963 rolls to Flutter Engine.
  RUN_BINARY_SIZE_ANALYSIS="third_party/dart/runtime/third_party/binary_size/src/run_binary_size_analysis.py"
fi
python3 "$RUN_BINARY_SIZE_ANALYSIS" --library "$INPUT_PATH" --destdir "$DEST_DIR" --addr2line-binary "$ADDR2LINE"
