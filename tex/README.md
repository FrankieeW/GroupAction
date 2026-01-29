# LaTeX Report for Group Action Formalization

This directory contains the LaTeX source for the project report.

## Quick Start

```bash
cd tex
xelatex -shell-escape report.tex
xelatex -shell-escape report.tex  # Run twice for cross-references
```

## Minimal Template: Code Blocks with GitHub Hyperlinks

Below is a minimal working example showing how to import Lean code from files with clickable line-by-line GitHub hyperlinks.

### Minimal Template: `doc/minimal-example.tex`

See `doc/minimal-example.tex` for a complete, working example that demonstrates how to import Lean code from files with clickable line-by-line GitHub hyperlinks.

**To use the template:**

1. **Copy or edit** `doc/minimal-example.tex`
2. **Compile with XeLaTeX** (required for `fontspec` and `minted`):
   ```bash
   cd doc
   xelatex -shell-escape minimal-example.tex
   ```
3. **Click line numbers** in the PDF to open the corresponding line on GitHub

**Key features of the template:**
- Imports code directly from `.lean` source files
- Each line number is a clickable GitHub hyperlink
- Configured minted for Lean 4 syntax highlighting
- Shows how to specify line ranges and numbering

**Template components:**
- `\leancodefile` command for file import
- GitHub URL setup with `\leancodeurl` and `\FancyVerbFormatLine`
- Proper XeLaTeX package configuration

### Key Components

| Component | Purpose |
|-----------|---------|
| `\setleancodeurl{url}` | Sets the base GitHub URL for hyperlinks |
| `\FancyVerbFormatLine` | Wraps each line in a `\href` to GitHub |
| `\leancodefile` | Imports code from `.lean` files with specified line range |
| `firstline=N, lastline=M` | Specifies which lines to import from the source file |
| `firstnumber=N` | Sets the starting line number displayed in PDF |

### Parameters Explained

```latex
\leancodefile[
  firstline=20,      % Start importing from line 20 of source file
  lastline=23,       % Stop importing at line 23 of source file
  firstnumber=20     % Display line numbers starting from 20
]{../lean/GroupAction/Defs.lean}{https://github.com/.../Defs.lean}
   ↑ Local file path              ↑ GitHub URL (for hyperlinks)
```

### Benefits

- ✅ **Automatic sync**: Edit `.lean` files, recompile PDF → updated code
- ✅ **No duplication**: Single source of truth (the `.lean` files)
- ✅ **Clickable links**: Each line number opens GitHub at that exact line
- ✅ **No tab issues**: Imports preserve original formatting from source

### Troubleshooting

**Error: "Package minted Error: You must invoke LaTeX with the -shell-escape flag"**
- Solution: Use `xelatex -shell-escape` instead of just `xelatex`

**Error: "Package fontspec Error: The fontspec package requires XeTeX or LuaTeX"**
- Solution: Use `xelatex` or `lualatex`, not `pdflatex`

**Links don't work**
- Check that the GitHub URL is correct and ends with the file path
- Ensure `hyperref` package is loaded

**Wrong lines displayed**
- Verify `firstline`, `lastline`, and `firstnumber` parameters
- Remember: `firstline` is the source file line, `firstnumber` is the displayed number

## Full Project Structure

```
├── doc/
│   ├── minimal-example.tex      # Working template for code import with GitHub links
│   └── minimal-example.pdf   # Compiled example (clickable links)
├── lean/                    # Lean source files
│   └── GroupAction/         # Main Lean modules
├── tex/
│   ├── report.tex           # Main report (uses leancodefile extensively)
│   ├── assignment.cls       # Custom LaTeX class
│   ├── references.bib       # Bibliography
│   ├── figures/             # Images and diagrams
│   ├── out/                 # Build artifacts (gitignored)
│   └── README.md           # This file
├── doc/                    # Documentation and templates
└── AGENTS.md               # Tex knowledge base
```

## Advanced Usage

### Highlight specific lines

```latex
\leancodefile[
  firstline=20,
  lastline=30,
  firstnumber=20,
  highlightlines={22-24}  % Highlight lines 22-24
]{../lean/file.lean}{https://github.com/.../file.lean}
```

### Different style per block

```latex
% Use a different minted style for this block
\leancodefile[
  firstline=10,
  lastline=15,
  style=colorful
]{../lean/file.lean}{https://github.com/.../file.lean}
```

### Import entire file

```latex
% Omit firstline/lastline to import the whole file
\leancodefile[firstnumber=1]{../lean/file.lean}{https://github.com/.../file.lean}
```

## References

- [Minted documentation](https://ctan.org/pkg/minted)
- [Hyperref documentation](https://ctan.org/pkg/hyperref)
- [Fontspec documentation](https://ctan.org/pkg/fontspec)

## Related Templates

- **`doc/minimal-example.tex`** - Complete working template
- **`doc/minimal-example.pdf`** - Compiled example with clickable GitHub links
- **`AGENTS.md`** - Tex knowledge base for automated assistance

## License

Copyright (c) 2026 Frankie Feng-Cheng WANG. All rights reserved.
