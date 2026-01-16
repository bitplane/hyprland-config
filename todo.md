# TODO

## Build Dependencies

Need to add proper checking/installation for build-time dependencies:

### eww build deps
- libgtk-3-dev
- libdbusmenu-glib-dev
- libgtk-layer-shell-dev
- libpango1.0-dev

### whisper-cpp build deps
- cmake
- build-essential

## Future Work

- [ ] Add `make test` that runs build in a container to verify deps are complete
- [ ] Add BUILD_DEPS check using pkg-config before building eww/whisper
- [ ] Refactor bin/ - keep scripts in scripts/ or src/, gitignore all of bin/, have install copy/link everything into bin/
- [ ] fix pycache dirs being linked in, but without special casing it.
