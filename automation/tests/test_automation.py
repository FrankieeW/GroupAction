# Lean-LaTeX Link Automation Tests

import unittest
from pathlib import Path
import tempfile
import os
import sys

sys.path.insert(0, str(Path(__file__).parent.parent))

from lean_parser import LeanParser, LeanItem
from latex_parser import LaTeXParser, LaTeXCodeRef
from matcher import Matcher
from updater import Updater


class TestLeanParser(unittest.TestCase):
    """Test the Lean parser functionality"""

    def setUp(self):
        self.parser = LeanParser()

    def test_parse_simple_def(self):
        """Test parsing a simple definition"""
        lean_code = """
def myFunction (x : Nat) : Nat :=
  x + 1
"""
        with tempfile.NamedTemporaryFile(mode='w', suffix='.lean', delete=False) as f:
            f.write(lean_code)
            temp_file = Path(f.name)

        try:
            items = self.parser.parse_file(temp_file)
            self.assertEqual(len(items), 1)
            item = items[0]
            self.assertEqual(item.name, "myFunction")
            self.assertEqual(item.item_type, "def")
            self.assertEqual(item.start_line, 2)
            self.assertEqual(item.end_line, 3)
        finally:
            temp_file.unlink()

    def test_parse_with_comments(self):
        """Test parsing with surrounding comments"""
        lean_code = """
/-! This is a theorem about addition -/
theorem add_comm (a b : Nat) : a + b = b + a := by
  sorry
/- End of theorem -/
"""
        with tempfile.NamedTemporaryFile(mode='w', suffix='.lean', delete=False) as f:
            f.write(lean_code)
            temp_file = Path(f.name)

        try:
            items = self.parser.parse_file(temp_file)
            self.assertEqual(len(items), 1)
            item = items[0]
            self.assertEqual(item.name, "add_comm")
            self.assertEqual(item.item_type, "theorem")
            self.assertIn("This is a theorem about addition", item.comments_above)
            self.assertIn("End of theorem", item.comments_below)
        finally:
            temp_file.unlink()


class TestLaTeXParser(unittest.TestCase):
    """Test the LaTeX parser functionality"""

    def setUp(self):
        self.parser = LaTeXParser()

    def test_parse_leancodefile(self):
        """Test parsing a leancodefile call"""
        latex_code = r"""
\leancodefile[firstline=10,lastline=20,firstnumber=10]{../lean/Test.lean}{https://github.com/user/repo/blob/main/lean/Test.lean}
"""
        with tempfile.NamedTemporaryFile(mode='w', suffix='.tex', delete=False) as f:
            f.write(latex_code)
            temp_file = Path(f.name)

        try:
            refs = self.parser.parse_file(temp_file)
            self.assertEqual(len(refs), 1)
            ref = refs[0]
            self.assertEqual(ref.lean_file, "../lean/Test.lean")
            self.assertEqual(ref.first_line, 10)
            self.assertEqual(ref.last_line, 20)
            self.assertEqual(ref.first_number, 10)
        finally:
            temp_file.unlink()


class TestMatcher(unittest.TestCase):
    """Test the matcher functionality"""

    def setUp(self):
        # Create mock data
        self.lean_items = {
            "lean/Test.lean": [
                LeanItem("myDef", "def", 10, 15, "lean/Test.lean", [], []),
                LeanItem("myTheorem", "theorem", 20, 25, "lean/Test.lean", [], [])
            ]
        }
        self.matcher = Matcher(self.lean_items)

    def test_calculate_match_score(self):
        """Test match score calculation"""
        ref = LaTeXCodeRef("test.tex", 1, "lean/Test.lean", 10, 15, 10, "url", "")
        item = self.lean_items["lean/Test.lean"][0]

        score = self.matcher._calculate_match_score(ref, item)
        self.assertGreater(score, 0.5)  # Should be a good match


class TestUpdater(unittest.TestCase):
    """Test the updater functionality"""

    def setUp(self):
        self.updater = Updater()

    def test_build_leancodefile_call(self):
        """Test building updated leancodefile calls"""
        ref = LaTeXCodeRef("test.tex", 1, "lean/Test.lean", 10, 15, 10, "https://github.com/user/repo/blob/main/lean/Test.lean", "")

        call = self.updater._build_leancodefile_call(ref, 8, 18)
        expected = r"\leancodefile[firstline=8,lastline=18,firstnumber=8]{lean/Test.lean}{https://github.com/user/repo/blob/main/lean/Test.lean}"
        self.assertEqual(call, expected)


if __name__ == '__main__':
    unittest.main()