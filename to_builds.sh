#!/bin/bash

build_for_platform() {
  local platform=$1
  local target_os=$2
  local target_arch=$3
  mkdir -p "build/$platform"
  dart compile exe \
    --target-os=$target_os \
    --target-arch=$target_arch \
    -o "build/$platform/dartser" \
    bin/main.dart
}

build_for_platform "linux" "linux" "x64" || {
  echo "Linux build failed."
}

build_for_platform "windows" "windows" "x64" || {
  echo "Windows build failed."
}

build_for_platform "macos" "macos" "arm64" || {
  echo "macOS build failed."
}

echo "Builds completed."