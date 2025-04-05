# echo-app-cabal

> A simple Haskell project created with `cabal init`, showcasing a clean structure with library, executable, and test suite components.

This repository accompanies **two lessons** from the [Software Library Design and Implementation](https://dibs.pages.dev) course:

- 📘 [Creating a Basic Project in Haskell with Cabal](https://dibs.pages.dev/docs/build-systems/init/cabal/)
- 📘 [Structuring a Haskell Project with Multiple Modules](https://dibs.pages.dev/docs/build-systems/basic-config/cabal/)

- **Lesson Language:** Spanish  
- **Code and Repo Language:** English (to improve accessibility)

The goal is to provide a minimal but well-structured foundation for learning how to organize and build Haskell projects using Cabal and GHCup, with a focus on clean architecture and modularity.

## 📦 Project Structure

```
echo-app-cabal/
├── app/                 # Executable entry point
│   └── Main.hs
├── src-lib/             # Library source code
│   └── Echo.hs
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

On Windows, you may need to manually add GHC's `bin` directory to your `PATH`. The lessons explain how to do this with PowerShell.

### 3. Run the app

```bash
cabal run echo-app-cabal -- "Hi Barbie!" "Hi Ken!" "Do you guys ever think about dying?"
```

Expected output:

```plaintext
Hi Barbie!
Hi Ken!
Do you guys ever think about dying?
```

## 🧪 Running Tests

```bash
cabal test
```

## ✍️ About the Lessons

This project was initialized interactively using `cabal init`, with both lessons guiding you through:

- Choosing project layout and `.cabal` specification
- Separating reusable logic into a library (`src-lib`)
- Configuring an executable to consume the library
- Passing arguments from the terminal
- Preparing for testing by including a test suite early

The lessons go beyond just running commands: they explain the reasoning behind each choice and how to make your project modular and extensible from the start.

## 📚 References

- 📘 [Cabal User’s Guide](https://cabal.readthedocs.io/en/stable/)
- 📘 [GHCup Installation Guide](https://www.haskell.org/ghcup/)
- 📘 [DIBS Course – Official Website](https://dibs.pages.dev)

## ⚖️ License

BSD-2-Clause © [Ignacio Slater Muñoz](https://github.com/r8vnhill)
