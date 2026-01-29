#!/usr/bin/env python3
"""
LaTeX Parser Module

Parses LaTeX files to find \leancodefile calls and extract their parameters.
"""

import re
from pathlib import Path
from typing import List, Dict, Optional
from dataclasses import dataclass


@dataclass
class LaTeXCodeRef:
    """Represents a \leancodefile call in LaTeX"""
    file_path: str
    line_number: int  # Line number in the LaTeX file where the call appears
    lean_file: str    # Path to the Lean file being referenced
    first_line: Optional[int]   # First line to include from the Lean file
    last_line: Optional[int]    # Last line to include from the Lean file
    first_number: Optional[int] # Line number to start numbering from
    github_url: str   # GitHub URL for the code
    options: str      # Raw options string from the LaTeX call


class LaTeXParser:
    """Parser for LaTeX files containing \leancodefile calls"""

    def __init__(self):
        self.references: List[LaTeXCodeRef] = []

    def parse_file(self, file_path: Path) -> List[LaTeXCodeRef]:
        """Parse a LaTeX file and extract all \leancodefile calls and TODO markers"""
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()

        references = []

        # Find all \leancodefile calls
        pattern = r'\\leancodefile\[([^\]]*)\]\{([^}]+)\}\{([^}]+)\}'
        for match in re.finditer(pattern, content):
            options = match.group(1)
            lean_file = match.group(2)
            github_url = match.group(3)

            # Parse options
            first_line = None
            last_line = None
            first_number = None

            if options:
                # Extract line numbers from options
                first_line_match = re.search(r'firstline=(\d+)', options)
                last_line_match = re.search(r'lastline=(\d+)', options)
                first_number_match = re.search(r'firstnumber=(\d+)', options)

                if first_line_match:
                    first_line = int(first_line_match.group(1))
                if last_line_match:
                    last_line = int(last_line_match.group(1))
                if first_number_match:
                    first_number = int(first_number_match.group(1))

            ref = LaTeXCodeRef(
                file_path=str(file_path),
                line_number=match.start(),  # Approximate line number
                lean_file=lean_file,
                github_url=github_url,
                first_line=first_line,
                last_line=last_line,
                first_number=first_number,
                options=options
            )
            references.append(ref)

         # Find all TODO markers
        todo_pattern = r'%TODO:lean-(\w+)'
        for match in re.finditer(todo_pattern, content):
            lean_name = match.group(1)

            # Create a placeholder reference for TODO markers
            ref = LaTeXCodeRef(
                file_path=str(file_path),
                line_number=match.start(),  # Approximate line number
                lean_file=f"TODO:{lean_name}",  # Special marker
                github_url="",
                first_line=None,
                last_line=None,
                first_number=None,
                options=""
            )
            references.append(ref)

        self.references = references
        return references

    def _parse_options(self, options_str: str) -> tuple[Optional[int], Optional[int], Optional[int]]:
        """Parse the options string to extract firstline, lastline, firstnumber"""
        first_line = last_line = first_number = None

        # Extract values using regex
        if 'firstline=' in options_str:
            match = re.search(r'firstline=(\d+)', options_str)
            if match:
                first_line = int(match.group(1))

        if 'lastline=' in options_str:
            match = re.search(r'lastline=(\d+)', options_str)
            if match:
                last_line = int(match.group(1))

        if 'firstnumber=' in options_str:
            match = re.search(r'firstnumber=(\d+)', options_str)
            if match:
                first_number = int(match.group(1))

        return first_line, last_line, first_number

    def get_references_by_file(self, lean_file: str) -> List[LaTeXCodeRef]:
        """Get all references to a specific Lean file"""
        return [ref for ref in self.references if ref.lean_file == lean_file]

    def get_references_by_pattern(self, pattern: str) -> List[LaTeXCodeRef]:
        """Get references where the Lean file matches a regex pattern"""
        return [ref for ref in self.references if re.search(pattern, ref.lean_file)]

    def validate_references(self) -> Dict[str, List[str]]:
        """Validate that all referenced Lean files exist and line numbers are reasonable"""
        issues = {}

        for ref in self.references:
            lean_path = Path(ref.file_path).parent / ref.lean_file

            if not lean_path.exists():
                if ref.lean_file not in issues:
                    issues[ref.lean_file] = []
                issues[ref.lean_file].append(f"File does not exist: {lean_path}")

            else:
                # Check if line numbers are within file bounds
                try:
                    with open(lean_path, 'r', encoding='utf-8') as f:
                        line_count = sum(1 for _ in f)

                    if ref.first_line is not None and ref.last_line is not None:
                        if ref.first_line > line_count or ref.last_line > line_count:
                            if ref.lean_file not in issues:
                                issues[ref.lean_file] = []
                            issues[ref.lean_file].append(
                                f"Line numbers out of bounds: {ref.first_line}-{ref.last_line} "
                                f"(file has {line_count} lines)"
                            )

                        if ref.first_line > ref.last_line:
                            if ref.lean_file not in issues:
                                issues[ref.lean_file] = []
                            issues[ref.lean_file].append(
                                f"Invalid range: first_line ({ref.first_line}) > last_line ({ref.last_line})"
                            )

                except Exception as e:
                    if ref.lean_file not in issues:
                        issues[ref.lean_file] = []
                    issues[ref.lean_file].append(f"Error reading file: {e}")

        return issues


def main():
    """Command-line interface for testing the LaTeX parser"""
    import argparse

    parser = argparse.ArgumentParser(description="Parse LaTeX files for leancodefile calls")
    parser.add_argument('file', help='LaTeX file to parse')
    parser.add_argument('--validate', action='store_true', help='Validate that referenced files exist')
    parser.add_argument('--output', '-o', help='Output file for results')

    args = parser.parse_args()

    latex_parser = LaTeXParser()
    references = latex_parser.parse_file(Path(args.file))

    print(f"Found {len(references)} \\leancodefile references")

    for ref in references:
        print(f"\nLaTeX line {ref.line_number}: {ref.lean_file}")
        print(f"  Lines: {ref.first_line}-{ref.last_line}, numbered from {ref.first_number}")
        print(f"  URL: {ref.github_url}")

    if args.validate:
        print("\n🔍 Validating references...")
        issues = latex_parser.validate_references()

        if issues:
            print("❌ Found validation issues:")
            for file_path, file_issues in issues.items():
                print(f"  {file_path}:")
                for issue in file_issues:
                    print(f"    - {issue}")
        else:
            print("✅ All references are valid")

    if args.output:
        import json
        with open(args.output, 'w') as f:
            # Convert to serializable format
            serializable = [
                {
                    'latex_file': ref.file_path,
                    'latex_line': ref.line_number,
                    'lean_file': ref.lean_file,
                    'first_line': ref.first_line,
                    'last_line': ref.last_line,
                    'first_number': ref.first_number,
                    'github_url': ref.github_url
                }
                for ref in references
            ]

            json.dump(serializable, f, indent=2)
        print(f"Results saved to {args.output}")


if __name__ == '__main__':
    main()