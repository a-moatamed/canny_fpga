#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2026 ARH Laboratory
# Author: Abdelrahman Abomosa

set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <pynq-host> [remote_dir] [python_script]"
  exit 1
fi

HOST="$1"
REMOTE_DIR="${2:-/home/xilinx/jupyter_notebooks/canny_edge_detector}"
PY_SCRIPT="${3:-canny_edge_detector.py}"

if [[ "${HOST}" == *"@"* ]]; then
  echo "Error: pass only IP/DNS host. User is fixed to 'xilinx'."
  exit 1
fi

TARGET="xilinx@${HOST}"

REMOTE_CMD="source /etc/profile.d/pynq_venv.sh && source /etc/profile.d/xrt_setup.sh && cd \"${REMOTE_DIR}\" && python \"${PY_SCRIPT}\""

ssh -t "${TARGET}" "sudo -i bash -lc '${REMOTE_CMD}'"
