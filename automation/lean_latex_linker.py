#!/usr/bin/env python3
"""
Lean-LaTeX Code Linking Automation Script

This script automates the process of maintaining accurate \\leancodefile references
between Lean source code and LaTeX documentation by automatically determining
correct line ranges and including surrounding comments.
"""

import sys
import argparse
from pathlib import Path
from typing import Dict, List, Tuple, Optional

import sys
import os
from pathlib import Path

# Add the automation directory to Python path
sys.path.insert(0, os.path.dirname(__file__))

# Import our modules
from lean_parser import LeanParser, LeanItem
from latex_parser import LaTeXParser, LaTeXCodeRef
from matcher import Matcher
from updater import Updater


class LeanLaTeXLinker:
    """Main class for linking Lean code to LaTeX references"""

    def __init__(self, lean_dir: str = "../lean", tex_file: str = "../tex/report.tex"):
        # Convert relative paths to absolute paths based on script location
        script_dir = Path(__file__).parent
        project_root = script_dir.parent

        self.lean_dir = project_root / lean_dir
        self.tex_file = project_root / tex_file
        self.lean_parser = LeanParser()
        self.latex_parser = LaTeXParser()
        self.matcher = None
        self.updater = Updater()

    def run_analysis(self) -> Dict[str, List[LeanItem]]:
        """Run analysis on Lean and LaTeX files"""
        print("🔍 Analyzing Lean files...")
        lean_items = self.lean_parser.parse_directory(self.lean_dir)

        print("📄 Analyzing LaTeX file...")
        latex_refs = self.latex_parser.parse_file(self.tex_file)

        print(f"📊 Found {sum(len(items) for items in lean_items.values())} Lean items")
        print(f"📊 Found {len(latex_refs)} LaTeX references")

        return lean_items

    def run_matching(self, lean_items: Dict[str, List[LeanItem]]) -> Dict[str, List[Tuple[LaTeXCodeRef, LeanItem]]]:
        """Run matching between LaTeX references and Lean items"""
        print("🔗 Matching references to Lean items...")

        latex_refs = self.latex_parser.references
        self.matcher = Matcher(lean_items)
        matches = self.matcher.match_all(latex_refs)

        print(f"📊 Found matches for {len(matches)} files")

        return matches

    def generate_report(self, matches: Dict[str, List[Tuple[LaTeXCodeRef, LeanItem]]]) -> None:
        """Generate and display a comprehensive report"""
        if not self.matcher:
            print("❌ No matcher available. Run matching first.")
            return

        report = self.matcher.generate_match_report()
        print("\n" + "="*60)
        print(report)
        print("="*60)

    def apply_updates(self, matches: Dict[str, List[Tuple[LaTeXCodeRef, LeanItem]]],
                     dry_run: bool = False, show_diff: bool = False) -> None:
        """Apply updates to LaTeX file"""
        if not matches:
            print("❌ No matches to apply")
            return

        best_matches = self.matcher.get_best_matches() if self.matcher else {}

        if not best_matches:
            print("❌ No best matches found")
            return

        if dry_run:
            print("🔍 DRY RUN - Showing proposed changes:")
            for file_path, (ref, item) in best_matches.items():
                new_first = item.start_line - len(item.comments_above)
                new_last = item.end_line + len(item.comments_below)
                new_first = max(1, new_first)
                print(f"  {file_path}: lines {ref.first_line}-{ref.last_line} → {new_first}-{new_last}")
            return

        if show_diff:
            print("🔍 Showing diff of proposed changes:")
            # Create temporary updated version for diff
            import tempfile
            with tempfile.NamedTemporaryFile(mode='w', suffix='.tex', delete=False) as temp_file:
                temp_path = Path(temp_file.name)
                temp_file.write(self.tex_file.read_text())

            self.updater.update_latex_file(temp_path, best_matches, create_backup=False)
            diff_report = self.updater.generate_diff_report(self.tex_file, temp_path)
            print(diff_report)

            # Clean up
            temp_path.unlink()
            return

        # Apply actual updates
        print("🔄 Applying updates to LaTeX file...")
        success = self.updater.update_latex_file(self.tex_file, best_matches)

        if success:
            print(f"✅ Successfully updated {self.updater.updates_made} references")

            # Validate updates
            lean_items = self.lean_parser.items
            issues = self.updater.validate_updates(self.tex_file, lean_items)

            if issues:
                print("⚠️  Validation warnings:")
                for issue in issues:
                    print(f"  {issue}")
            else:
                print("✅ All updates validated successfully")
        else:
            print("ℹ️  No updates were needed")

    def rollback_changes(self) -> None:
        """Rollback any changes made"""
        print("🔄 Rolling back changes...")
        self.updater.rollback_changes()
        print("✅ Changes rolled back")

    def run_full_pipeline(self, dry_run: bool = False, show_diff: bool = False,
                         generate_report: bool = True) -> None:
        """Run the complete pipeline: analysis → matching → updates"""
        try:
            # Step 1: Analysis
            lean_items = self.run_analysis()

            # Step 2: Matching
            matches = self.run_matching(lean_items)

            # Step 3: Report (optional)
            if generate_report:
                self.generate_report(matches)

            # Step 4: Apply updates
            self.apply_updates(matches, dry_run=dry_run, show_diff=show_diff)

        except Exception as e:
            print(f"❌ Error during pipeline execution: {e}")
            import traceback
            traceback.print_exc()


def main():
    """Main entry point"""
    parser = argparse.ArgumentParser(
        description="Automate Lean-LaTeX code linking",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Analyze files and show report
  python lean_latex_linker.py --analyze

  # Dry run to see proposed changes
  python lean_latex_linker.py --dry-run

  # Show diff of changes to be made
  python lean_latex_linker.py --diff

  # Apply updates
  python lean_latex_linker.py --update

  # Full pipeline (analyze, match, report, update)
  python lean_latex_linker.py --full
        """
    )

    parser.add_argument('--lean-dir', default='lean',
                       help='Directory containing Lean files (default: lean)')
    parser.add_argument('--tex-file', default='tex/report.tex',
                       help='LaTeX file to update (default: tex/report.tex)')

    # Action modes
    parser.add_argument('--analyze', action='store_true',
                       help='Only analyze files and show statistics')
    parser.add_argument('--match', action='store_true',
                       help='Analyze and match references (shows report)')
    parser.add_argument('--dry-run', action='store_true',
                       help='Show what changes would be made without applying them')
    parser.add_argument('--diff', action='store_true',
                       help='Show diff of changes to be made')
    parser.add_argument('--update', action='store_true',
                       help='Apply updates to LaTeX file')
    parser.add_argument('--full', action='store_true',
                       help='Run complete pipeline: analyze → match → report → update')
    parser.add_argument('--rollback', action='store_true',
                       help='Rollback previous changes')

    # Options
    parser.add_argument('--no-report', action='store_true',
                       help='Skip generating match report in full mode')

    args = parser.parse_args()

    # Validate arguments
    actions = [args.analyze, args.match, args.dry_run, args.diff, args.update, args.full, args.rollback]
    if sum(actions) == 0:
        parser.print_help()
        return

    if sum(actions) > 1:
        print("❌ Please specify only one action mode")
        return

    # Initialize linker
    linker = LeanLaTeXLinker(args.lean_dir, args.tex_file)

    try:
        if args.rollback:
            linker.rollback_changes()

        elif args.analyze:
            lean_items = linker.run_analysis()
            print(f"\nLean items by file:")
            for file_path, items in lean_items.items():
                print(f"  {file_path}: {len(items)} items")
                for item in items[:3]:  # Show first 3
                    print(f"    {item.item_type} {item.name}: lines {item.start_line}-{item.end_line}")
                if len(items) > 3:
                    print(f"    ... and {len(items) - 3} more")

        elif args.match:
            lean_items = linker.run_analysis()
            matches = linker.run_matching(lean_items)
            linker.generate_report(matches)

        elif args.dry_run:
            lean_items = linker.run_analysis()
            matches = linker.run_matching(lean_items)
            linker.apply_updates(matches, dry_run=True)

        elif args.diff:
            lean_items = linker.run_analysis()
            matches = linker.run_matching(lean_items)
            linker.apply_updates(matches, show_diff=True)

        elif args.update:
            lean_items = linker.run_analysis()
            matches = linker.run_matching(lean_items)
            linker.apply_updates(matches, dry_run=False)

        elif args.full:
            generate_report = not args.no_report
            linker.run_full_pipeline(generate_report=generate_report)

    except KeyboardInterrupt:
        print("\n⚠️  Interrupted by user")
    except Exception as e:
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)


if __name__ == '__main__':
    main()