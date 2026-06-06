#!/usr/bin/env python3
# SPDX-License-Identifier: MIT
# Copyright (c) 2026 ARH Laboratory
# Author: Abdelrahman Abomosa

"""
Canny Edge Detector validation script for PYNQ.

Run on the PYNQ board after placing:
  - canny.bit
  - canny.hwh
in the same directory as this script.
"""

from pathlib import Path
from time import perf_counter

from pynq import Overlay

BIT_NAME = "canny.bit"
HWH_NAME = "canny.hwh"

if not Path(BIT_NAME).exists() or not Path(HWH_NAME).exists():
    raise FileNotFoundError("Expected canny.bit and canny.hwh in current directory")

ol = Overlay(BIT_NAME)
ip = ol.canny_edge_detector_0

CTRL = 0x00
X_REG = 0x10
Y_REG = 0x18


def run_once(x: int) -> int:
    ip.write(X_REG, x)
    ip.write(CTRL, 0x01)  # ap_start
    while (ip.read(CTRL) & 0x2) == 0:  # ap_done
        pass
    return ip.read(Y_REG)


def main() -> None:
    vectors = list(range(16))
    t0 = perf_counter()
    outputs = [run_once(v) for v in vectors]
    t1 = perf_counter()

    expected = [(2 * v) + 1 for v in vectors]
    if outputs != expected:
        raise RuntimeError(f"Mismatch\noutputs={outputs}\nexpected={expected}")

    print("PASS: canny_edge_detector outputs match expected values")
    print(f"Processed {len(vectors)} samples in {(t1 - t0) * 1e3:.3f} ms")


if __name__ == "__main__":
    main()
