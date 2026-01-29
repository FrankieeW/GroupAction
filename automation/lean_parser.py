#!/usr/bin/env python3
"""
Lean Parser Module

Parses Lean files to extract definitions, theorems, lemmas, instances, etc.
with their line numbers and surrounding comments.
"""

import re
from pathlib import Path
from typing import List, Dict, Optional
from dataclasses import dataclass


@dataclass
class LeanItem:
    """Represents a Lean definition, theorem, lemma, etc."""
    name: str
    item_type: str  # 'def', 'theorem', 'lemma', 'instance', 'abbrev'
    start_line: int  # 1-indexed line number where item starts
    end_line: int    # 1-indexed line number where item ends
    file_path: str
    comments_above: List[str]  # Comments immediately above the item
    comments_below: List[str]  # Comments immediately below the item


class LeanParser:
    """Parser for Lean source files"""

    # Patterns for Lean item definitions
    ITEM_PATTERNS = [
        (r'^def\s+([^\s:]+)', 'def'),
        (r'^theorem\s+([^\s:]+)', 'theorem'),
        (r'^lemma\s+([^\s:]+)', 'lemma'),
        (r'^instance\s+([^\s:\[]+)', 'instance'),
        (r'^abbrev\s+([^\s:]+)', 'abbrev'),
    ]

    def __init__(self):
        self.items: Dict[str, List[LeanItem]] = {}

    def parse_file(self, file_path: Path) -> List[LeanItem]:
        """Parse a single Lean file and return all items found"""
        if not file_path.exists():
            raise FileNotFoundError(f"Lean file not found: {file_path}")

        with open(file_path, 'r', encoding='utf-8') as f:
            lines = f.readlines()

        items = []
        i = 0

        while i < len(lines):
            item = self._parse_item_at_line(lines, i, file_path)
            if item:
                items.append(item)
                # Skip to after this item
                i = item.end_line
            else:
                i += 1

        return items

    def _parse_item_at_line(self, lines: List[str], line_idx: int, file_path: Path) -> Optional[LeanItem]:
        """Parse a potential Lean item starting at the given line"""
        line = lines[line_idx].strip()

        # Check if this line starts a Lean item
        item_type = None
        item_name = None

        for pattern, itype in self.ITEM_PATTERNS:
            match = re.match(pattern, line)
            if match:
                item_name = match.group(1)
                item_type = itype
                break

        if not item_type or not item_name:
            return None

        # Found an item, now determine its boundaries
        start_line = line_idx + 1  # 1-indexed
        end_line = self._find_item_end_corrected(lines, line_idx)

        # Extract surrounding comments
        comments_above = self._extract_comments_above(lines, line_idx)
        comments_below = self._extract_comments_below(lines, end_line - 1)  # Convert back to 0-indexed

        return LeanItem(
            name=item_name,
            item_type=item_type,
            start_line=start_line,
            end_line=end_line,
            file_path=str(file_path),
            comments_above=comments_above,
            comments_below=comments_below
        )

    def _find_item_end(self, lines: List[str], start_idx: int) -> int:
        """Find the end line of a Lean item starting at start_idx"""
        i = start_idx + 1  # Start from the line after the item definition

        while i < len(lines):
            line = lines[i].strip()

            # Check if this line starts a new item (at any indentation)
            for pattern, _ in self.ITEM_PATTERNS:
                if re.match(pattern, line):
                    return i  # End before next item

            i += 1

        return len(lines)  # End of file

    def _find_item_end_corrected(self, lines: List[str], start_idx: int) -> int:
        """Find the end line of a Lean item starting at start_idx (corrected version)"""
        i = start_idx  # Start from the item definition line

        # Find the actual end of this item by looking for patterns that indicate continuation
        brace_depth = 0
        in_string = False
        string_char = None

        while i < len(lines):
            line = lines[i]

            # Skip the definition line itself
            if i == start_idx:
                i += 1
                continue

            # Check for new item definition (this would be the start of the next item)
            stripped = line.strip()
            for pattern, _ in self.ITEM_PATTERNS:
                if re.match(pattern, stripped):
                    return i  # End before next item

            # Simple heuristic: if we hit a comment or empty line after non-empty content, stop
            if stripped.startswith('/-') or (stripped == "" and i > start_idx + 1):
                return i

            i += 1

        return len(lines)  # End of file

    def _extract_comments_above(self, lines: List[str], item_line_idx: int) -> List[str]:
        """Extract comments immediately above an item"""
        comments = []
        i = item_line_idx - 1

        while i >= 0:
            line = lines[i].strip()

            # Stop at non-comment, non-empty line
            if line != "" and not line.startswith('/-'):
                break

            # Skip empty lines
            if line == "":
                i -= 1
                continue

            # Extract comment content
            if line.startswith('/-') and line.endswith('-/'):
                # Single-line comment - remove comment markers
                comment_content = line[2:-2].strip()
                # Handle doc comments that start with '!'
                if comment_content.startswith('!'):
                    comment_content = comment_content[1:].strip()
                comments.insert(0, comment_content)
            elif line.startswith('/-'):
                # Multi-line comment start - just take the whole line for now
                comment_content = line[2:].strip()
                # Handle doc comments that start with '!'
                if comment_content.startswith('!'):
                    comment_content = comment_content[1:].strip()
                comments.insert(0, comment_content)
                # Look for continuation
                i -= 1
                while i >= 0:
                    next_line = lines[i].strip()
                    if next_line.endswith('-/'):
                        continuation = next_line[:-2].strip()
                        comments.insert(0, continuation)
                        break
                    elif next_line.startswith('/-'):
                        # Another comment
                        break
                    else:
                        comments.insert(0, next_line)
                    i -= 1

            i -= 1

        return comments

    def _extract_comments_below(self, lines: List[str], item_end_idx: int) -> List[str]:
        """Extract comments immediately below an item"""
        comments = []
        i = item_end_idx + 1

        while i < len(lines):
            line = lines[i].strip()

            # Lean block comments: /- ... -/
            if line.startswith('/-') and line.endswith('-/'):
                comment_content = line[2:-2].strip()
                # Handle doc comments that start with '!'
                if comment_content.startswith('!'):
                    comment_content = comment_content[1:].strip()
                comments.append(comment_content)
                i += 1
            elif line == "":
                i += 1  # Skip empty lines
            else:
                break  # Stop at non-comment, non-empty line

        return comments

    def parse_directory(self, directory: Path) -> Dict[str, List[LeanItem]]:
        """Parse all .lean files in a directory recursively"""
        items_by_file = {}

        for lean_file in directory.rglob("*.lean"):
            if lean_file.is_file():
                try:
                    items = self.parse_file(lean_file)
                    relative_path = lean_file.relative_to(directory.parent)
                    items_by_file[str(relative_path)] = items
                except Exception as e:
                    print(f"Error parsing {lean_file}: {e}")

        self.items = items_by_file
        return items_by_file

    def get_item_by_name(self, name: str, file_path: Optional[str] = None) -> List[LeanItem]:
        """Find items by name, optionally filtered by file"""
        results = []

        for fpath, items in self.items.items():
            if file_path and fpath != file_path:
                continue

            for item in items:
                if item.name == name:
                    results.append(item)

        return results

    def get_items_by_type(self, item_type: str) -> List[LeanItem]:
        """Get all items of a specific type (def, theorem, etc.)"""
        results = []

        for items in self.items.values():
            for item in items:
                if item.item_type == item_type:
                    results.append(item)

        return results


def main():
    """Command-line interface for testing the Lean parser"""
    import argparse

    parser = argparse.ArgumentParser(description="Parse Lean files")
    parser.add_argument('directory', help='Directory containing Lean files')
    parser.add_argument('--output', '-o', help='Output file for results')

    args = parser.parse_args()

    lean_parser = LeanParser()
    items_by_file = lean_parser.parse_directory(Path(args.directory))

    # Print results
    total_items = sum(len(items) for items in items_by_file.values())
    print(f"Parsed {len(items_by_file)} files with {total_items} items total")

    for file_path, items in items_by_file.items():
        print(f"\n{file_path}:")
        for item in items:
            print(f"  {item.item_type} {item.name}: lines {item.start_line}-{item.end_line}")
            if item.comments_above:
                print(f"    Comments above: {item.comments_above}")
            if item.comments_below:
                print(f"    Comments below: {item.comments_below}")

    if args.output:
        import json
        with open(args.output, 'w') as f:
            # Convert to serializable format
            serializable = {}
            for file_path, items in items_by_file.items():
                serializable[file_path] = [
                    {
                        'name': item.name,
                        'type': item.item_type,
                        'start_line': item.start_line,
                        'end_line': item.end_line,
                        'comments_above': item.comments_above,
                        'comments_below': item.comments_below
                    }
                    for item in items
                ]

            json.dump(serializable, f, indent=2)
        print(f"Results saved to {args.output}")


if __name__ == '__main__':
    main()