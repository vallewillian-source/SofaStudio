# Getting Started

## Prerequisites

- CMake 3.16+
- Qt 6 (Components: Core, Gui, Qml, Quick)
- C++17 compatible compiler

## Build and Run

1.  **Configure:**

    ```bash
    cmake -S . -B build
    ```

2.  **Build:**

    ```bash
    cmake --build build
    ```

3.  **Run:**

    ```bash
    ./build/apps/desktop/sofa-studio
    ```

## Troubleshooting

### macOS: `dyld: Library not loaded ... libicui18n.XX.dylib`

If you encounter an error related to `icu4c` libraries (e.g., mismatch between version 74 and 77), it means your Qt installation is outdated relative to your system libraries (common after Homebrew updates).

**Fix:**
Run the following commands to update Qt:

```bash
brew upgrade qt
# If that doesn't work:
brew reinstall qt
```

Then delete the `build` folder and try again.
