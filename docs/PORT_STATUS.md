# Port status

## Implemented

- Native iPhone SwiftUI application
- IPA import from Files
- Persistent game library
- Safe ZIP path and symlink checks
- Info.plist metadata parsing
- 32-bit ARM Mach-O detection
- cryptid encryption detection
- Per-game folders
- Game deletion
- Runtime logs
- Unsigned IPA GitHub Actions build

## Not implemented

- touchHLE execution on iOS
- Guest rendering
- Guest touch forwarding
- Guest audio
- Guest accelerometer
- Runtime stop support
- JIT or interpreter CPU backend

## Source blockers found

- The supplied source archive has empty Git submodule directories for Dynarmic, SDL, OpenAL Soft and stb.
- touchHLE creates its window, OpenGL context and input loop directly through SDL in src/window.rs.
- touchHLE owns the full run loop through Environment::run, so it is not currently designed to live inside a UIViewController.
- Dynarmic is the only CPU backend and its iOS executable-memory/JIT path is not implemented.
- OpenAL Soft and Dynarmic build scripts have Android, macOS, Linux and Windows cases but no iOS configuration.
- Resource and user-data paths have Android/macOS behavior but no iOS app-container behavior.
- The public entry point is command-line shaped and synchronous. The overlay only exposes that existing entry point; stop and touch APIs need deeper refactoring.

## Next core milestone

1. Add an iOS host platform module instead of using the desktop SDL Window directly.
2. Render guest GLES 1 output into a CAEAGLLayer or Metal-backed compatibility surface.
3. Replace SDL event polling with an input queue fed by UIKit.
4. Add iOS sandbox paths and bundled resource lookup.
5. Cross-compile Dynarmic for arm64 iOS and establish a supported JIT entitlement workflow, or add an ARM32 interpreter.
6. Move Environment ownership to a long-lived runtime object so stop, touch and accelerometer calls can reach it.
