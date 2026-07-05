# LegacyiOS milestone 0.1

This is the first working iPhone-side milestone for a touchHLE host port. It builds an unsigned IPA that imports, validates and catalogs decrypted 32-bit iOS IPAs. It does not run games yet.

## Build with GitHub Actions from Windows

1. Create a new GitHub repository.
2. Upload every file in this folder.
3. Open Actions and run `build unsigned ipa`.
4. Open the finished run and download `LegacyiOS-unsigned`.
5. Extract the artifact ZIP to get `LegacyiOS-unsigned.ipa`.
6. Sign that IPA with ESign or Sideloadly and install it.

## Why the emulator is not linked yet

The current touchHLE core is a desktop/Android program built around SDL, Dynarmic JIT and a synchronous run loop. A modern iPhone app needs a new iOS host layer and a workable CPU backend. Normal ESign or Sideloadly signing does not automatically grant JIT.

## Source setup

The uploaded touchHLE ZIP omitted all Git submodule contents. Run this on macOS or in a later workflow to fetch a complete checkout:

```sh
./scripts/fetch_touchhle.sh
```

The script clones touchHLE recursively and adds the first static-library C API overlay. That overlay is not enough to compile the core for iOS yet; the blockers are listed in `docs/PORT_STATUS.md`.

More detailed steps are in `docs/BUILD_AND_INSTALL.md`.
