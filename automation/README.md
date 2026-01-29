# Lean-LaTeX Link Automation

This tool automates the process of linking Lean code definitions to LaTeX documentation by automatically determining line ranges and including surrounding comments.

## Problem

Manually maintaining `\leancodefile` calls in LaTeX with correct line numbers is error-prone and time-consuming. When Lean code changes, the line numbers in LaTeX documentation become outdated.

## Solution

This automation script:

1. **Parses Lean files** to extract definitions, theorems, lemmas, instances, and abbreviations
2. **Captures surrounding comments** tightly attached to definitions
3. **Matches LaTeX references** to Lean items based on file names and content
4. **Updates LaTeX files** with correct line ranges automatically

## Installation

```bash
# Ensure Python 3.8+ is available
python --version

# Install dependencies (if any)
pip install -r requirements.txt
```

## Usage

### Basic Usage

```bash
# Analyze Lean and LaTeX files
python automation/lean_latex_linker.py --analyze

# Show matching report
python automation/lean_latex_linker.py --match

# Dry run to see proposed changes
python automation/lean_latex_linker.py --dry-run

# Show diff of changes
python automation/lean_latex_linker.py --diff

# Apply updates
python automation/lean_latex_linker.py --update

# Full pipeline (recommended)
python automation/lean_latex_linker.py --full
```

### Command Line Options

```
--lean-dir DIR       Directory containing Lean files (default: lean)
--tex-file FILE      LaTeX file to update (default: tex/report.tex)
--analyze            Only analyze files and show statistics
--match              Analyze and match references (shows report)
--dry-run            Show what changes would be made without applying them
--diff               Show diff of changes to be made
--update             Apply updates to LaTeX file
--full               Run complete pipeline: analyze → match → report → update
--rollback           Rollback previous changes
--no-report          Skip generating match report in full mode
```

## Examples

### Example 1: First-time setup

```bash
# Switch to automation branch
git checkout automation-lean-latex-linking

# Run full analysis and updates
python automation/lean_latex_linker.py --full
```

### Example 2: Safe testing

```bash
# See what would change without modifying files
python automation/lean_latex_linker.py --dry-run

# See detailed diff
python automation/lean_latex_linker.py --diff
```

### Example 3: Custom directories

```bash
# Use custom Lean and LaTeX directories
python automation/lean_latex_linker.py --lean-dir src/lean --tex-file docs/main.tex --full
```

## How It Works

### 1. Lean Parsing
The script parses `.lean` files to extract:
- Function definitions (`def`)
- Theorems (`theorem`)
- Lemmas (`lemma`)
- Instances (`instance`)
- Abbreviations (`abbrev`)

For each item, it captures:
- Name and type
- Line numbers (start/end)
- Surrounding comments (above/below)

### 2. LaTeX Parsing
The script finds all `\leancodefile` calls in LaTeX files and extracts:
- Referenced Lean file path
- Current line ranges
- GitHub URLs

### 3. Intelligent Matching
Matches are made based on:
- File path correspondence
- Name similarity
- Line range proximity
- URL content hints

### 4. Automatic Updates
Updates LaTeX files with corrected line ranges that include:
- The definition itself
- Tightly attached comments above and below
- Proper line numbering

## Configuration

Edit `automation/config.ini` to customize behavior:

```ini
[MATCHING]
min_score_threshold = 0.5    # Minimum match confidence
max_candidates = 3           # Max matches to consider

[COMMENTS]
include_above = true         # Include comments above definitions
include_below = true         # Include comments below definitions
max_comment_lines = 10       # Max comment lines to include
```

## Safety Features

- **Backup files**: Original files are backed up before modification
- **Dry run mode**: Test changes without applying them
- **Rollback**: Restore original files if needed
- **Validation**: Checks that updated ranges contain valid Lean items

## Testing

Run the test suite:

```bash
cd automation
python -m pytest tests/ -v
```

Or run specific tests:

```bash
python tests/test_automation.py
```

## Troubleshooting

### Common Issues

1. **No matches found**
   - Check that Lean files exist at specified paths
   - Verify LaTeX file contains `\leancodefile` calls
   - Ensure file paths match between Lean and LaTeX references

2. **Incorrect line ranges**
   - Run with `--dry-run` to see proposed changes
   - Check that Lean syntax is valid
   - Verify comment attachment logic

3. **Permission errors**
   - Ensure write access to LaTeX files
   - Check that backup directory is writable

### Getting Help

```bash
python automation/lean_latex_linker.py --help
```

## Contributing

1. Create a feature branch from `automation-lean-latex-linking`
2. Add tests for new functionality
3. Update documentation
4. Submit a pull request

## License

This tool is part of the GroupAction formalization project.