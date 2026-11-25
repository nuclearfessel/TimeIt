"""Tests for Shopped-matching TimeIt version bumps."""
from __future__ import annotations

import unittest

from bump_release_version import bump_pubspec_text, bump_semver


class BumpSemverTests(unittest.TestCase):
    def test_patch_sequence(self) -> None:
        self.assertEqual(bump_semver(1, 0, 0), (1, 0, 1))
        self.assertEqual(bump_semver(1, 0, 8), (1, 0, 9))
        self.assertEqual(bump_semver(1, 0, 9), (1, 1, 0))

    def test_minor_roll(self) -> None:
        self.assertEqual(bump_semver(1, 1, 9), (1, 2, 0))
        self.assertEqual(bump_semver(1, 9, 9), (2, 0, 0))

    def test_major_after_999(self) -> None:
        self.assertEqual(bump_semver(9, 9, 9), (10, 0, 0))

    def test_high_patch_snaps_onto_scheme(self) -> None:
        # Current TimeIt 1.0.20 → next valid Shopped-style is 1.1.0
        self.assertEqual(bump_semver(1, 0, 20), (1, 1, 0))


class BumpPubspecTests(unittest.TestCase):
    def test_rewrites_line_and_build(self) -> None:
        text = "name: timeit\nversion: 1.0.20+21\n"
        updated, name, code = bump_pubspec_text(text)
        self.assertEqual(name, "1.1.0")
        self.assertEqual(code, 22)
        self.assertIn("version: 1.1.0+22", updated)


if __name__ == "__main__":
    unittest.main()
