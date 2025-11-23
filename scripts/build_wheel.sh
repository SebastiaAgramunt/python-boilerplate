#!/bin/bash

set -e

THIS_DIR=$(dirname "$0")
PROJECT_DIR=$(realpath "$THIS_DIR/..")


arch="$(uname -m)"
os="$(uname -s | tr '[:upper:]' '[:lower:]')"

# create virtual environment and install build dependencies
create_venv() {
    rm -rf "$PROJECT_DIR/dist"
    rm -rf "$PROJECT_DIR/build"
    rm -rf "$PROJECT_DIR/.venv"

    python3 -m venv "$PROJECT_DIR/.venv"
    source "$PROJECT_DIR/.venv/bin/activate"
    python -m pip install --upgrade pip

    python -m pip install wheel pybind11 auditwheel repairwheel patchelf build
    python -m pip install setuptools==70.3.0
}


build_wheel_linux() {

    # get platform tag for architecture
    # supporting glibc 2.28 and above
    # to kon your glibc in linux: ldd --version
    if [[ "$(uname -m)" == "x86_64" ]]; then
        PLATFORM_TAG="manylinux_2_28_x86_64"
    elif [[ "$(uname -m)" == "aarch64" ]]; then
        PLATFORM_TAG="manylinux_2_28_aarch64"
    else
        echo "Unsupported architecture: $(uname -m)"
        exit 1
    fi

    # build wheel
    source "$PROJECT_DIR/.venv/bin/activate"
    python -m build "$PROJECT_DIR"

    # repair wheel
    WHEEL_FILE="$(ls "$PROJECT_DIR"/dist/*.whl | head -n 1)"

    # create wheelhouse directory and repair wheel into it
    # repair the wheel: include all shared libraries by default. Allow load of system libraries at runtime
    # like glibc, libm, libstdc++, etc.
    # optionally exclude libraries like libcuda with "--exclude libcu* --exclude libnvcomp*"
    mkdir -p "$PROJECT_DIR/wheelhouse"
    auditwheel repair "$WHEEL_FILE" --plat "$PLATFORM_TAG" -w "$PROJECT_DIR/wheelhouse"
    echo "Wheel built and repaired successfully. Find it in $PROJECT_DIR/wheelhouse"
}

build_wheel_macos() {
    source "$PROJECT_DIR/.venv/bin/activate"
    python -m build "$PROJECT_DIR"
    echo "Wheel built successfully. Find it in $PROJECT_DIR/dist"
}

main() {
    echo "Building wheel for OS: $os, ARCH: $arch"

    if [[ "$os" == "linux" ]]; then
        create_venv
        build_wheel_linux
    elif [[ "$os" == "darwin" ]]; then
        create_venv
        build_wheel_macos
    else
        echo "Unsupported OS: $os"
        exit 1
    fi
}

main "$@"