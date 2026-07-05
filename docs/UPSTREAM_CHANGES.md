# Planned touchHLE upstream changes

The included overlay changes only these upstream files:

- `Cargo.toml`: changes the library output to `staticlib` and `rlib`.
- `src/lib.rs`: includes `ios_bridge` only for an iOS host build.
- `src/ios_bridge.rs`: adds the initial C ABI entry points.

The bridge can call the current synchronous touchHLE entry point, but it is not a complete iOS host port. The runtime still needs iOS window, input, audio, path and CPU-backend work before the static library can be linked into the app.
