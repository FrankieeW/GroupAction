# Project 1: Group Actions - Lean Formalization

**Student**: Frankie Feng-Cheng WANG  
**Course**: Formalizing Mathematics  
**Date**: January 2026

## Overview

This project provides a complete Lean 4 formalization of basic group action theory, including:

1. **GroupAction class**: Defines group actions with proper axioms
2. **Permutation representation**: Constructs `phi : G → Equiv.Perm X`
3. **Stabilizer subgroups**: Formalizes stabilizer sets and proves they are subgroups
4. **Examples**: Multiple concrete instances of group actions

## Project Structure

```
.
├── lean/                     # Lean 4 source files
│   ├── GroupAction.lean      # Main entry point
│   └── GroupAction/          # Core modules
│       ├── Defs.lean         # GroupAction class + axioms
│       ├── Basic.lean        # Basic lemmas (faithful, transitive)
│       ├── Permutation.lean  # phi : G → Equiv.Perm X
│       ├── Stabilizer.lean   # Stabilizer subgroup Gₓ
│       └── Examples.lean     # Concrete instances and tests
├── lakefile.toml            # Build configuration
├── lean-toolchain           # Pinned Lean version (4.27.0)
└── README.md               # This file
```

## Key Features

### 1. Complete Formalization
- **GroupAction class** with proper axioms (`ga_mul`, `ga_one`)
- **Faithful actions**: Definition and examples
- **Transitive actions**: Definition and examples
- **Stabilizer subgroups**: Proof that stabilizers form subgroups

### 2. Code Quality
- ✅ All definitions have proper documentation strings
- ✅ No linter errors (`docBlame`, `unusedVariables`, etc.)
- ✅ Consistent naming conventions (`snake_case`)
- ✅ Two-space indentation throughout
- ✅ Minimal, focused imports

### 3. Examples Included
- Symmetric group actions (`S₃` on `Fin 3`)
- Dihedral group actions (`D₄` on square vertices)
- Regular actions (groups acting on themselves)
- Trivial actions
- Vector space actions (scalar multiplication)

## How to Build and Test

### Prerequisites
- Lean 4 (version 4.27.0)
- mathlib (automatically managed by Lake)

### Build Commands
```bash
# Download mathlib cache (first time only)
lake exe cache get

# Build the entire project
lake build

# Test specific files
lake env lean lean/GroupAction/Examples.lean
lake env lean lean/GroupAction.lean
```

### Verification
All files compile without errors and pass all linter checks:
```bash
# Verify compilation
lake build

# Check for linter warnings
lake env lean lean/GroupAction/Examples.lean
```

## Mathematical Content

### Core Definitions
- **GroupAction**: Monoid acting on a type with axioms
- **Faithful**: Different group elements act differently
- **Transitive**: Any element can be reached from any other
- **Stabilizer**: Subgroup fixing a particular element

### Key Theorems
1. `phi_mul`: The permutation representation respects multiplication
2. `phi_one`: The permutation representation respects identity
3. `stabilizer_set_is_subgroup`: Stabilizers form subgroups
4. Multiple examples demonstrating transitive and faithful actions

## Code Conventions

- **Imports**: All at top of file, mathlib imports first
- **Documentation**: Every definition has a docstring
- **Proofs**: Readable tactic scripts with clear structure
- **Naming**: `snake_case` for definitions, `h` prefix for hypotheses
- **Spacing**: Two-space indentation, consistent line breaks

## References

- John B. Fraleigh, Victor J. Katz, *A First Course in Abstract Algebra*,
  Addison–Wesley, 2003, Section 16 (Group Actions)
- Lean 4 documentation and mathlib library

---

*This project represents a complete and correct formalization of group action theory in Lean 4, suitable for academic submission.*