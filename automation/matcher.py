#!/usr/bin/env python3
"""
Matcher Module

Matches LaTeX references to Lean items based on various criteria.
"""

import re
from pathlib import Path
from typing import List, Dict, Tuple, Optional
from difflib import SequenceMatcher
from lean_parser import LeanItem
from latex_parser import LaTeXCodeRef


class Matcher:
    """Matches LaTeX references to Lean items"""

    def __init__(self, lean_items: Dict[str, List[LeanItem]]):
        self.lean_items = lean_items
        self.matches: Dict[str, List[Tuple[LaTeXCodeRef, LeanItem]]] = {}

    def match_all(self, latex_refs: List[LaTeXCodeRef]) -> Dict[str, List[Tuple[LaTeXCodeRef, LeanItem]]]:
        """Match all LaTeX references to Lean items"""
        matches = {}

        for ref in latex_refs:
            if ref.lean_file.startswith("TODO:"):
                # Handle TODO markers
                lean_name = ref.lean_file[5:]  # Remove "TODO:" prefix
                matched_items = self._match_todo_marker(lean_name)
                if matched_items:
                    matches[ref.lean_file] = matched_items
            else:
                # Handle regular \leancodefile calls
                matched_items = self._match_single_ref(ref)
                if matched_items:
                    matches[ref.lean_file] = matched_items

        self.matches = matches
        return matches

    def _match_todo_marker(self, lean_name: str) -> List[Tuple[LaTeXCodeRef, LeanItem]]:
        """Match a TODO marker to a Lean item by name"""
        candidates = []

        # Search through all Lean items for name match (exact or suffix match)
        for file_path, items in self.lean_items.items():
            for item in items:
                # Check for exact match or if lean_name is a suffix of item.name
                if item.name == lean_name or item.name.endswith('.' + lean_name):
                    # Create a placeholder LaTeX reference for the TODO marker
                    placeholder_ref = LaTeXCodeRef(
                        file_path="",  # Not needed for matching
                        line_number=0,  # Not needed for matching
                        lean_file=f"TODO:{lean_name}",  # Special marker
                        github_url="",
                        first_line=None,
                        last_line=None,
                        first_number=None,
                        options=""
                    )
                    candidates.append((placeholder_ref, item))
                    break

        return candidates

    def _match_single_ref(self, ref: LaTeXCodeRef) -> List[Tuple[LaTeXCodeRef, LeanItem]]:
        """Match a single LaTeX reference to Lean items"""
        candidates = []

        # Normalize the LaTeX reference path
        normalized_lean_file = self._normalize_path(ref.lean_file)

        # Find items in the same file
        if normalized_lean_file in self.lean_items:
            file_items = self.lean_items[normalized_lean_file]

            for item in file_items:
                score = self._calculate_match_score(ref, item)
                if score > 0.3:  # Lower threshold for considering a match
                    candidates.append((ref, item))

        # Sort by score (highest first)
        candidates.sort(key=lambda x: self._calculate_match_score(x[0], x[1]), reverse=True)

        return candidates[:3]  # Return top 3 matches

    def _normalize_path(self, path: str) -> str:
        """Normalize a file path to match the Lean items keys"""
        # Remove leading ../ and normalize separators
        normalized = path.replace('../', '').replace('\\', '/')
        return normalized

    def _calculate_match_score(self, ref: LaTeXCodeRef, item: LeanItem) -> float:
        """Calculate how well a LaTeX reference matches a Lean item"""
        score = 0.0

        # File name match (exact)
        if ref.lean_file == item.file_path:
            score += 0.3

        # Name similarity
        name_similarity = SequenceMatcher(None, ref.lean_file, item.file_path).ratio()
        score += name_similarity * 0.2

        # Line range proximity
        if ref.first_line and ref.last_line:
            item_center = (item.start_line + item.end_line) / 2
            ref_center = (ref.first_line + ref.last_line) / 2
            range_overlap = self._calculate_range_overlap(
                ref.first_line, ref.last_line,
                item.start_line, item.end_line
            )
            score += range_overlap * 0.3

        # URL contains item name
        if item.name.lower() in ref.github_url.lower():
            score += 0.2

        return min(score, 1.0)  # Cap at 1.0

    def _calculate_range_overlap(self, start1: int, end1: int, start2: int, end2: int) -> float:
        """Calculate overlap between two line ranges [0,1]"""
        overlap_start = max(start1, start2)
        overlap_end = min(end1, end2)

        if overlap_start >= overlap_end:
            return 0.0

        overlap_length = overlap_end - overlap_start
        range1_length = end1 - start1
        range2_length = end2 - start2

        # Use Jaccard similarity
        union_length = range1_length + range2_length - overlap_length
        return overlap_length / union_length if union_length > 0 else 0.0

    def get_best_matches(self) -> Dict[str, Tuple[LaTeXCodeRef, LeanItem]]:
        """Get the best match for each LaTeX reference"""
        best_matches = {}

        for file_path, match_list in self.matches.items():
            if match_list:
                # Take the highest scoring match
                best_matches[file_path] = match_list[0]

        return best_matches

    def get_conflicts(self) -> List[Tuple[LaTeXCodeRef, List[LeanItem]]]:
        """Find references with multiple high-confidence matches"""
        conflicts = []

        for file_path, match_list in self.matches.items():
            if len(match_list) > 1:
                ref, first_item = match_list[0]
                _, second_item = match_list[1]

                # If the top two matches have similar scores, it's a conflict
                first_score = self._calculate_match_score(ref, first_item)
                second_score = self._calculate_match_score(ref, second_item)

                if first_score - second_score < 0.1:  # Within 10% of each other
                    conflicts.append((ref, [item for _, item in match_list]))

        return conflicts

    def apply_manual_matches(self, manual_matches: Dict[str, str]) -> None:
        """Apply manual match overrides"""
        for ref_key, item_name in manual_matches.items():
            # Find the reference and item, then update matches
            # This is a simplified implementation
            pass

    def generate_match_report(self) -> str:
        """Generate a human-readable report of matches"""
        report_lines = []
        report_lines.append("Lean-LaTeX Matching Report")
        report_lines.append("=" * 40)

        total_refs = sum(len(matches) for matches in self.matches.values())
        report_lines.append(f"Total matched references: {total_refs}")

        best_matches = self.get_best_matches()
        report_lines.append(f"Best matches found: {len(best_matches)}")

        conflicts = self.get_conflicts()
        report_lines.append(f"Potential conflicts: {len(conflicts)}")

        if best_matches:
            report_lines.append("\nBest Matches:")
            for file_path, (ref, item) in best_matches.items():
                report_lines.append(f"  {file_path}:")
                report_lines.append(f"    LaTeX: lines {ref.first_line}-{ref.last_line}")
                report_lines.append(f"    Lean: {item.item_type} {item.name} (lines {item.start_line}-{item.end_line})")
                score = self._calculate_match_score(ref, item)
                report_lines.append(".2f")

        if conflicts:
            report_lines.append("\nConflicts (multiple good matches):")
            for ref, items in conflicts:
                report_lines.append(f"  {ref.lean_file} lines {ref.first_line}-{ref.last_line}:")
                for item in items[:3]:  # Show top 3
                    score = self._calculate_match_score(ref, item)
                    report_lines.append(".2f")

        return "\n".join(report_lines)


def main():
    """Command-line interface for testing the matcher"""
    import argparse
    import json
    from automation.lean_parser import LeanParser
    from automation.latex_parser import LaTeXParser

    parser = argparse.ArgumentParser(description="Match LaTeX references to Lean items")
    parser.add_argument('--lean-dir', default='lean', help='Lean source directory')
    parser.add_argument('--latex-file', default='tex/report.tex', help='LaTeX file to analyze')
    parser.add_argument('--report', action='store_true', help='Generate match report')

    args = parser.parse_args()

    # Parse Lean files
    lean_parser = LeanParser()
    lean_items = lean_parser.parse_directory(Path(args.lean_dir))

    # Parse LaTeX file
    latex_parser = LaTeXParser()
    latex_refs = latex_parser.parse_file(Path(args.latex_file))

    # Match them
    matcher = Matcher(lean_items)
    matches = matcher.match_all(latex_refs)

    if args.report:
        report = matcher.generate_match_report()
        print(report)
    else:
        print(f"Found {len(matches)} matched files")
        for file_path, match_list in matches.items():
            print(f"{file_path}: {len(match_list)} matches")


if __name__ == '__main__':
    main()