# echo-app-cabal

> A simple Haskell project created with `cabal init`, showcasing a clean structure with library, executable, and test suite components.

This repository accompanies the lesson **"Creating a Basic Project in Haskell with Cabal"** from the [Software Library Design and Implementation](https://dibs.pages.dev/docs/build-systems/init/cabal/) course.

- **Lesson Language:** Spanish
- **Code and Repo Language:** English (to improve accessibility)

The goal is to provide a minimal but well-structured foundation for learning how to organize and build Haskell projects using Cabal and GHCup.

## 📦 Project Structure

```
echo-app-cabal/
├── app/                 # Executable entry point
│   └── Main.hs
├── src-lib/             # Library source code
│   └── MyLib.hs
├── test/                # Test suite
│   └── Main.hs
├── echo-app-cabal.cabal # Project definition
└── LICENSE              # License (BSD-2-Clause)
```

## 🚀 Quick Start

### 1. Install GHCup (if not already installed)

- macOS: 
  ```bash
  brew install ghcup
  ```
- Linux:  
  ```bash
  curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh
  ```
- Windows (with [Scoop](https://scoop.sh)):  
  ```powershell
  scoop install ghcup
  ```

### 2. Install tools

```bash
ghcup install ghc
ghcup install cabal
```

On Windows, you may need to manually add GHC's `bin` directory to your `PATH`. The lesson explains how to do this with PowerShell.

### 3. Run the app

```bash
cabal run
```

Expected output:

```plaintext
I do not belong to the world. That is the limit, the boundary between all and self.
```

## 🧪 Running Tests

```bash
cabal test
```

## ✍️ About the Lesson

This repository was created interactively using `cabal init`, explaining each option and choice along the way—from naming, licensing, and versioning to directory structure and language extensions.

The lesson emphasizes:

- Clean separation between app and library logic
- Declarative configuration using `.cabal` files
- Choosing modern standards like `GHC2021`
- Integrating a test suite from the beginning
- Understanding the *why* behind each setting

## 📚 References

- 📘 [Cabal User’s Guide](https://cabal.readthedocs.io/en/stable/)
- 📘 [GHCup Installation Guide](https://www.haskell.org/ghcup/)
- 📘 [DIBS Course – Official Website](https://dibs.pages.dev)

## ⚖️ License

BSD-2-Clause © [Ignacio Slater Muñoz](https://github.com/r8vnhill)
