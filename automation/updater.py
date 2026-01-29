#!/usr/bin/env python3
"""
Updater Module

Updates LaTeX files with corrected \leancodefile calls based on matched Lean items.
"""

import re
from pathlib import Path
from typing import Dict, List, Tuple
from lean_parser import LeanItem
from latex_parser import LaTeXCodeRef


class Updater:
    """Updates LaTeX files with corrected line ranges"""

    def __init__(self):
        self.updates_made = 0
        self.backup_files = []

    def update_latex_file(self, latex_file: Path, matches: Dict[str, Tuple[LaTeXCodeRef, LeanItem]],
                         create_backup: bool = True) -> bool:
        """Update a LaTeX file with corrected \\leancodefile calls"""
        if not latex_file.exists():
            raise FileNotFoundError(f"LaTeX file not found: {latex_file}")

        # Create backup
        if create_backup:
            backup_file = latex_file.with_suffix('.bak')
            backup_file.write_text(latex_file.read_text())
            self.backup_files.append(backup_file)

        # Read current content
        content = latex_file.read_text()

        # Apply updates
        updated_content = self._apply_updates(content, matches)

        # Write back
        if updated_content != content:
            latex_file.write_text(updated_content)
            self.updates_made += 1
            return True

        return False

    def _apply_updates(self, content: str, matches: Dict[str, Tuple[LaTeXCodeRef, LeanItem]]) -> str:
        """Apply all updates to the content"""
        for file_path, (ref, item) in matches.items():
            # Calculate new line range including comments
            new_first = item.start_line - len(item.comments_above)
            new_last = item.end_line + len(item.comments_below)

            # Ensure we don't go below 1
            new_first = max(1, new_first)

            # Check if this is a TODO marker
            if ref.lean_file.startswith("TODO:"):
                # Replace TODO marker with full leancodefile call
                lean_name = ref.lean_file[5:]  # Remove "TODO:" prefix
                new_call = self._build_leancodefile_call_from_todo(lean_name, item, new_first, new_last)
                old_pattern = r'%TODO:lean-' + re.escape(lean_name)
                content = re.sub(old_pattern, lambda m: new_call, content)
            else:
                # Update existing leancodefile call
                old_pattern = self._build_leancodefile_pattern(ref)

                def replacement(match):
                    new_call = self._build_leancodefile_call(ref, new_first, new_last)
                    return new_call

                content = re.sub(old_pattern, replacement, content, flags=re.MULTILINE)

        return content

    def _build_leancodefile_pattern(self, ref: LaTeXCodeRef) -> str:
        """Build a regex pattern to match the specific leancodefile call"""
        # Escape special regex characters
        escaped_lean_file = re.escape(ref.lean_file)
        escaped_url = re.escape(ref.github_url)

        # Build pattern: \leancodefile[options]{lean_file}{url}
        pattern = r'\\leancodefile\[([^\]]*)\]\{' + escaped_lean_file + r'\}\{' + escaped_url + r'\}'

        return pattern

    def _build_leancodefile_call(self, ref: LaTeXCodeRef, new_first: int, new_last: int) -> str:
        """Build the updated \leancodefile call"""
        return f'\\leancodefile[firstline={new_first},lastline={new_last},firstnumber={new_first}]{{{ref.lean_file}}}{{{ref.github_url}}}'

    def _build_leancodefile_call_from_todo(self, lean_name: str, item: LeanItem, new_first: int, new_last: int) -> str:
        """Build a full \leancodefile call from a TODO marker"""
        item_path = item.file_path
        if 'GroupAction' in item_path:
            parts = item_path.split('GroupAction')
            relative_path = 'lean/GroupAction' + parts[-1]
        else:
            relative_path = item_path
        
        lean_file_path = f"../{relative_path}"
        github_base = "https://github.com/FrankieeW/GroupAction/blob/v1.1.0"
        github_url = f"{github_base}/{relative_path}"
        
        return f'\\leancodefile[firstline={new_first},lastline={new_last},firstnumber={new_first}]{{{lean_file_path}}}{{{github_url}}}'

    def generate_diff_report(self, original_file: Path, updated_file: Path) -> str:
        """Generate a diff report showing changes made"""
        import difflib

        try:
            with open(original_file, 'r') as f:
                original_lines = f.readlines()

            with open(updated_file, 'r') as f:
                updated_lines = f.readlines()

            diff = difflib.unified_diff(
                original_lines,
                updated_lines,
                fromfile=str(original_file),
                tofile=str(updated_file),
                lineterm=''
            )

            return ''.join(diff)

        except Exception as e:
            return f"Error generating diff: {e}"

    def validate_updates(self, latex_file: Path, lean_items: Dict[str, List[LeanItem]]) -> List[str]:
        """Validate that updates are reasonable"""
        issues = []

        # Re-parse the updated file
        from latex_parser import LaTeXParser
        parser = LaTeXParser()
        refs = parser.parse_file(latex_file)

        # Check each reference
        for ref in refs:
            if ref.lean_file in lean_items:
                file_items = lean_items[ref.lean_file]

                # Check if the line range contains at least one item
                range_contains_item = False
                for item in file_items:
                    if ref.first_line is not None and ref.last_line is not None:
                        if (ref.first_line <= item.start_line <= ref.last_line or
                            ref.first_line <= item.end_line <= ref.last_line):
                            range_contains_item = True
                            break

                if not range_contains_item:
                    issues.append(
                        f"Warning: {ref.lean_file} lines {ref.first_line}-{ref.last_line} "
                        "doesn't contain any Lean items"
                    )

        return issues

    def rollback_changes(self) -> None:
        """Rollback all changes by restoring backup files"""
        for backup_file in self.backup_files:
            original_file = backup_file.with_suffix('').with_suffix('.tex')  # Remove .bak, add .tex
            if backup_file.exists():
                backup_file.replace(original_file)
                print(f"Restored {original_file} from backup")

        self.backup_files = []


def main():
    """Command-line interface for updating LaTeX files"""
    import argparse
    from automation.lean_parser import LeanParser
    from automation.latex_parser import LaTeXParser
    from automation.matcher import Matcher

    parser = argparse.ArgumentParser(description="Update LaTeX files with corrected line ranges")
    parser.add_argument('--lean-dir', default='lean', help='Lean source directory')
    parser.add_argument('--latex-file', default='tex/report.tex', help='LaTeX file to update')
    parser.add_argument('--dry-run', action='store_true', help='Show changes without applying them')
    parser.add_argument('--diff', action='store_true', help='Show diff of changes')
    parser.add_argument('--rollback', action='store_true', help='Rollback previous changes')

    args = parser.parse_args()

    updater = Updater()

    if args.rollback:
        updater.rollback_changes()
        return

    # Parse Lean files
    lean_parser = LeanParser()
    lean_items = lean_parser.parse_directory(Path(args.lean_dir))

    # Parse LaTeX file
    latex_parser = LaTeXParser()
    latex_refs = latex_parser.parse_file(Path(args.latex_file))

    # Match references to items
    matcher = Matcher(lean_items)
    matches = matcher.match_all(latex_refs)

    best_matches = matcher.get_best_matches()

    if not best_matches:
        print("No matches found to update")
        return

    print(f"Found {len(best_matches)} references to update")

    if args.dry_run:
        print("DRY RUN - No files will be modified")
        for file_path, (ref, item) in best_matches.items():
            new_first = item.start_line - len(item.comments_above)
            new_last = item.end_line + len(item.comments_below)
            print(f"  {file_path}: {ref.first_line}-{ref.last_line} -> {new_first}-{new_last}")
    elif args.diff:
        # Apply updates to a temporary copy for diff
        import tempfile
        with tempfile.NamedTemporaryFile(mode='w', suffix='.tex', delete=False) as temp_file:
            temp_path = Path(temp_file.name)
            temp_file.write(Path(args.latex_file).read_text())

        updater.update_latex_file(temp_path, best_matches, create_backup=False)
        diff_report = updater.generate_diff_report(Path(args.latex_file), temp_path)
        print("Changes to be made:")
        print(diff_report)

        # Clean up
        temp_path.unlink()
    else:
        # Apply updates
        success = updater.update_latex_file(Path(args.latex_file), best_matches)

        if success:
            print(f"Successfully updated {updater.updates_made} references")

            # Validate the updates
            issues = updater.validate_updates(Path(args.latex_file), lean_items)
            if issues:
                print("Validation issues found:")
                for issue in issues:
                    print(f"  {issue}")
            else:
                print("All updates validated successfully")
        else:
            print("No updates were needed")


if __name__ == '__main__':
    main()