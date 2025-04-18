<#
.SYNOPSIS
Resolves the full, absolute path of a given file or directory if it exists.

.DESCRIPTION
The `Resolve-FullPath` function attempts to resolve the full filesystem path using `Resolve-Path`.
If the path exists, it returns the absolute path.
If the path cannot be resolved (e.g., it doesn't exist), the original input is returned unchanged.

This is useful in project scripts or generators where resolving real paths is helpful but should not
interrupt execution if the target does not yet exist.

.PARAMETER Path
The path to resolve. This may be relative or absolute.

.EXAMPLE
Script:Resolve-FullPath -Path '.\src'

If the `src` folder exists, returns something like:
C:\Projects\MyApp\src

.EXAMPLE
PS> Script:Resolve-FullPath -Path "nonexistent.txt"

Returns:
nonexistent.txt

.NOTES
- Requires PowerShell 7.0+ due to use of the ternary conditional (`? :`) operator.
- If the path does not exist, the input is returned unchanged.
- Useful in file scaffolding and validation scripts.

.OUTPUTS
[string] The resolved absolute path if found, otherwise the original input string.
#>
function Script:Resolve-FullPath([string]$Path) {
    $resolved = Resolve-Path -Path $Path -ErrorAction SilentlyContinue
    # Required: PowerShell 7.0 or later
    return $resolved ? $resolved.Path : $Path
}

<#
.SYNOPSIS
Creates a directory if it does not already exist.

.DESCRIPTION
The `New-DirectoryIfMissing` function checks whether a directory exists at the specified path.
If the directory is missing, it creates it using `New-Item -ItemType Directory`.

The function respects `$WhatIfPreference`, allowing it to simulate actions during dry-run scenarios.
It also emits a verbose message if the directory is successfully created.

.PARAMETER Path
The full or relative path to the directory to create.
If the path is null or empty, the function does nothing.

.EXAMPLE
PS> Script:New-DirectoryIfMissing -Path ".\build"

Creates the `build` directory if it doesn't already exist.

.EXAMPLE
PS> $WhatIfPreference = $true
PS> Script:New-DirectoryIfMissing -Path ".\generated"

Simulates directory creation without making changes.

.NOTES
- This function is script-scoped and intended for use in automation scripts.
- It respects the `$WhatIfPreference` variable but does not use `[CmdletBinding()]`.
  For full support of `-WhatIf`, wrap in a cmdlet or add `SupportsShouldProcess = $true`.

.OUTPUTS
None. Creates a directory as a side effect if needed.
#>
function Script:New-DirectoryIfMissing([string]$Path) {
    if ($Path -and -not (Test-Path $Path)) {
        New-Item -ItemType Directory `
            -Path $Path `
            -Force `
            -Confirm:$false `
            -WhatIf:$WhatIfPreference | Out-Null
        Write-Verbose "✅ Created directory: $Path"
    }
}

<#
.SYNOPSIS
Writes a Haskell-style `module` declaration as the header of a file.

.DESCRIPTION
The `Write-ModuleHeader` function generates and writes a Haskell module declaration to the top of a
file.
It derives the module name from the file name (excluding the extension) and writes a line in the
format: `module <Name> where`.

This is useful for scaffolding Haskell source files with valid module declarations.

The operation respects `$WhatIfPreference`, making it safe to include in dry-run workflows.
It overwrites any existing file content unless prevented via `-WhatIf`.

.PARAMETER Path
The path to the file where the module header should be written.
The module name will be derived from this file's base name.

.EXAMPLE
PS> Script:Write-ModuleHeader -Path ".\src\Hello.hs"

Writes the following to the file:
module Hello where

.EXAMPLE
PS> $WhatIfPreference = $true
PS> Script:Write-ModuleHeader -Path ".\Utils.hs"

Simulates the header writing without modifying the file.

.NOTES
- Overwrites the entire file with just the module declaration.
- Intended for internal script use; script-scoped.
- Assumes UTF-8 encoding for output.

.OUTPUTS
None. Writes to file as a side effect.
#>
function Script:Write-ModuleHeader([string]$Path) {
    $module = [IO.Path]::GetFileNameWithoutExtension($Path)
    $header = "module $module where`n"
    Set-Content -Path $Path `
        -Value $header `
        -Force `
        -Encoding UTF8 `
        -Confirm:$false `
        -WhatIf:$WhatIfPreference
}

<#
.SYNOPSIS
Determines whether an existing file should be overwritten.

.DESCRIPTION
The `Test-ShouldOverwrite` function checks whether a file at the specified path already exists, and
based on the provided flags (`-Force`, `-NoInteractive`), it decides whether the file should be
overwritten.

- If the file does not exist, it returns `$true`.
- If `-Force` is set, it returns `$true` regardless of existence.
- If `-NoInteractive` is set and the file exists, it prints a warning and returns `$false`.
- Otherwise, it prompts the user interactively.

This utility is helpful when safely managing file creation or generation, particularly in
scaffolding scripts.

.PARAMETER Path
The file path to check.

.PARAMETER Force
If specified, bypasses all checks and returns `$true`.

.PARAMETER NoInteractive
Disables the prompt and prevents overwriting if the file exists (unless `-Force` is also set).

.EXAMPLE
PS> Test-ShouldOverwrite -Path "./Main.hs"

Prompts the user if the file exists.
Returns `$true` if the user agrees to overwrite it.

.EXAMPLE
PS> Test-ShouldOverwrite -Path "./Main.hs" -Force

Always returns `$true`, regardless of file existence.

.EXAMPLE
PS> Test-ShouldOverwrite -Path "./Main.hs" -NoInteractive

Returns `$false` and prints a warning if the file exists.
Returns `$true` if it does not.

.NOTES
- This function is script-scoped and intended for internal use in file generation tools.
- Prompts the user via `Read-Host` unless `-Force` or `-NoInteractive` is specified.
- Returns a [bool].

.OUTPUTS
[bool] Whether the file should be overwritten.
#>
function Script:Test-ShouldOverwrite([string]$Path, [switch]$Force, [switch]$NoInteractive) {
    if (-not (Test-Path $Path)) { return $true }
    if ($Force) { return $true }
    if ($NoInteractive) {
        Write-Host "⚠️ File already exists: $Path. Use -Force to overwrite." `
            -ForegroundColor DarkYellow
        return $false
    }

    $answer = Read-Host "⚠️ File '$Path' exists. Overwrite? (y/N)"
    return $answer -eq 'y' -or $answer -eq 'Y'
}

<#
.SYNOPSIS
Creates a new Haskell `.hs` file with a valid module declaration header.

.DESCRIPTION
The `New-HaskellFile` function scaffolds a Haskell source file with the correct `.hs` extension,
creates any missing parent directories, and writes a module declaration based on the file name.

It supports conditional overwriting through `-Force`, `-NoInteractive`, and integrates with
`ShouldProcess`, making it safe to use in preview and confirmation flows (e.g., `-WhatIf` and
`-Confirm`).

This function uses the following helper functions:
- `Add-HaskellExtensionIfMissing`
- `Resolve-FullPath`
- `Test-ShouldOverwrite`
- `New-DirectoryIfMissing`
- `Write-ModuleHeader`

.PARAMETER FileName
The name of the Haskell file to create.
If it does not end in `.hs`, the extension will be appended.
You may provide just a file name or a full path.
Accepts pipeline input.

.PARAMETER Force
Forces overwriting the file if it already exists, bypassing confirmation.

.PARAMETER NoInteractive
Prevents prompting the user when a file already exists.
If used without `-Force`, existing files will be skipped.

.EXAMPLE
PS> New-HaskellFile -FileName "Main"

Creates `Main.hs` with the following content:
```haskell
module Main where
```

.EXAMPLE
PS> "Utils.hs" | New-HaskellFile -Verbose

Creates `Utils.hs`, outputting verbose logs during the process.

.EXAMPLE
PS> New-HaskellFile -FileName ".\src\Lib" -WhatIf

Simulates file creation without writing anything to disk.

.EXAMPLE
PS> New-HaskellFile -FileName ".\src\Lib" -Force

Creates or overwrites `src\Lib.hs` without confirmation.

.NOTES
- Designed for use in script-based scaffolding or educational Haskell tooling.
- Automatically creates parent directories if they don't exist.
- The resulting file will contain a valid Haskell `module` declaration.

.OUTPUTS
None. Writes a Haskell file to disk as a side effect.
#>
function Script:New-HaskellFile {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string]$FileName,

        [switch]$Force,
        [switch]$NoInteractive
    )

    process {
        # Required: PowerShell 7.0 or later
        $finalName = $Name.EndsWith('.hs') ? $Name : "$Name.hs"
        $fullPath = Resolve-FullPath $finalName
        $directory = Split-Path $fullPath -Parent

        if (-not (Test-ShouldOverwrite -Path $fullPath -Force:$Force -NoInteractive:$NoInteractive)) {
            Write-Host "⏭️ Skipped: $fullPath" -ForegroundColor Gray
            return
        }

        if ($PSCmdlet.ShouldProcess($fullPath, 'Create Haskell file')) {
            try {
                New-DirectoryIfMissing $directory
                Write-ModuleHeader $fullPath
                Write-Verbose "✅ Created file: $fullPath"
            } catch {
                Write-Error "❌ Failed to create file '$fullPath': $_"
            }
        }
    }
}

<#
.SYNOPSIS
Creates multiple Haskell files inside a target directory, each with a valid module declaration.

.DESCRIPTION
The `Initialize-FilesInDirectory` function takes a directory path and a list of Haskell filenames,
then generates each file using `New-HaskellFile`.
If the files do not exist, they are created; if they do exist, the function prompts before
overwriting unless `-Force` or `-NoInteractive` is used.

Each file is created with a `.hs` extension (if missing), and a valid Haskell `module` declaration
based on the filename is inserted.

This function is ideal for batch-scaffolding common Haskell modules (e.g., `Main.hs`, `Lib.hs`)
in a given folder.

.PARAMETER Directory
The target directory where all files should be created.
This path is prepended to each file name in the `-Files` array.

.PARAMETER Files
An array of file names (with or without `.hs` extension) to be created inside the specified
directory.

.PARAMETER Force
Forces overwriting of files without confirmation.

.PARAMETER NoInteractive
Skips interactive prompts when a file already exists.
Files are skipped unless `-Force` is also set.

.EXAMPLE
PS> Initialize-FilesInDirectory -Directory ".\src" -Files "Main", "Lib"

Creates `src\Main.hs` and `src\Lib.hs`, inserting valid module headers.

.EXAMPLE
PS> Initialize-FilesInDirectory -Directory ".\src" -Files "Utils.hs" -Force

Overwrites `src\Utils.hs` without prompting.

.EXAMPLE
PS> Initialize-FilesInDirectory -Directory ".\src" -Files "Main" -WhatIf

Simulates file creation without writing to disk.

.NOTES
- Internally delegates to `New-HaskellFile` for each item in the file list.
- Automatically appends `.hs` extension to file names if missing.
- Respects `-WhatIf`, `-Confirm`, and `-Verbose` from the calling context.

.OUTPUTS
None. Creates files as a side effect.
#>
function Script:Initialize-FilesInDirectory {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)][string]$Directory,
        [Parameter(Mandatory)][string[]]$Files,
        [switch]$Force,
        [switch]$NoInteractive
    )
    foreach ($file in $Files) {
        $filePath = Join-Path -Path $Directory -ChildPath $file

        if ($PSCmdlet.ShouldProcess($filePath, 'Create Haskell file')) {
            New-HaskellFile -FileName $filePath `
                -Force:$Force `
                -NoInteractive:$NoInteractive `
                -Verbose:$VerbosePreference `
                -WhatIf:$WhatIfPreference `
                -Confirm:$false
        }
    }
}

<#
.SYNOPSIS
Initializes standard source folders and Haskell modules for a Cabal-based project.

.DESCRIPTION
The `Initialize-CabalModules` function creates scaffold files inside the default source directories
of a Haskell project that uses Cabal:

- `app\` for executables
- `src-lib\` for library modules
- `test\` for test modules

It generates each file with a `.hs` extension (if missing) and writes a valid `module <Name> where`
declaration into each one.

This function supports conditional overwriting via `-Force` and `-NoInteractive`, and is fully
compatible with `-WhatIf`, `-Verbose`, and `-Confirm`.
It internally delegates to `Initialize-FilesInDirectory` and `New-HaskellFile` for safe and
customizable generation.

Known aliases: `init-cabal`, `haskell-init`, `new-cabal-modules`.

.PARAMETER AppFiles
The names of the Haskell source files to create under `app\`.
Default: `Main.hs`.
Known aliases: `executables`, `apps`.

.PARAMETER LibFiles
The names of the Haskell library modules to create under `src-lib\`.
Default: `Lib.hs`.
Known aliases: `modules`, `libs`.

.PARAMETER TestFiles
The names of the Haskell test files to create under `test\`.
Default: `Main.hs`.
Known alias: `tests`.

.PARAMETER Force
Forces overwriting of existing files without confirmation.
Known alias: `-f`.

.PARAMETER NoInteractive
Skips prompts when a file already exists. Existing files will be skipped unless `-Force` is also
set.
Known aliases: `-ni`, `noPrompt`.

.EXAMPLE
Initialize-CabalModules

Creates the following by default:
- `app\Main.hs`
- `src-lib\Lib.hs`
- `test\Main.hs`

.EXAMPLE
Initialize-CabalModules -AppFiles "Main.hs", "Server.hs" -LibFiles "Core.hs" -Force

Creates additional app and library modules, forcibly overwriting existing files.

.EXAMPLE
Initialize-CabalModules -WhatIf -Verbose

Simulates the creation of default modules with detailed output.

.NOTES
- Uses script-scoped helpers like `Initialize-FilesInDirectory` and `New-HaskellFile`.
- Automatically adds `.hs` if missing from file names.
- Intended for use in new Haskell projects or automation workflows.

.INPUTS
None. Use parameters to specify file names.

.OUTPUTS
None. Files are written to disk as a side effect.
#>
function Initialize-CabalModules {
    [CmdletBinding(SupportsShouldProcess)]
    [Alias('init-cabal', 'haskell-init', 'new-cabal-modules')]
    param (
        [Alias('app', 'executables', 'apps')]
        [ValidateNotNullOrEmpty()]
        [string[]]$AppFiles = @('Main.hs'),

        [Alias('lib', 'modules', 'libs')]
        [ValidateNotNullOrEmpty()]
        [string[]]$LibFiles = @('Lib.hs'),

        [Alias('test', 'tests')]
        [ValidateNotNullOrEmpty()]
        [string[]]$TestFiles = @('Main.hs'),

        [Alias('f')]
        [switch]$Force,

        [Alias('ni', 'noPrompt')]
        [switch]$NoInteractive
    )

    begin {
        Write-Host "`n🚀 Initializing Haskell modules...`n" -ForegroundColor Cyan
    }

    process {
        if ($PSCmdlet.ShouldProcess('Initialize Haskell files', 'Creating Haskell files')) {
            $params = @{
                Verbose       = $VerbosePreference
                WhatIf        = $WhatIfPreference
                Force         = $Force
                NoInteractive = $NoInteractive
            }

            Initialize-FilesInDirectory -Directory 'app'     -Files $AppFiles  -Confirm:$false @params
            Initialize-FilesInDirectory -Directory 'src-lib' -Files $LibFiles  -Confirm:$false @params
            Initialize-FilesInDirectory -Directory 'test'    -Files $TestFiles -Confirm:$false @params
        }
    }

    end {
        if ($PSCmdlet.ShouldProcess('Haskell files', 'Final confirmation')) {
            Write-Host "`n✅ Haskell files created successfully." -ForegroundColor Green
        }
        if ($WhatIfPreference) {
            Write-Host "`nℹ️ WhatIf: No files were created." -ForegroundColor Yellow
        }
    }
}
