#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2026 ARH Laboratory
# Author: Abdelrahman Abomosa

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJ_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

PROJECT_NAME="${PROJECT_NAME:-canny}"
VIEW="${1:-bd}"
VIVADO_LOG="${PROJ_DIR}/vivado/build/vivado.log"

case "${VIEW}" in
  bd|impl|project) ;;
  *)
    echo "Usage: $0 [bd|impl|project]"
    exit 1
    ;;
esac

if ! command -v vivado >/dev/null 2>&1; then
  echo "Error: vivado not found in PATH."
  exit 1
fi

mkdir -p "${PROJ_DIR}/vivado/build"

XPR_PATH="${PROJ_DIR}/vivado/build/${PROJECT_NAME}/${PROJECT_NAME}.xpr"
if [[ ! -f "${XPR_PATH}" ]]; then
  echo "Error: Vivado project not found at ${XPR_PATH}"
  echo "Run ./scripts/run_vivado.sh first."
  exit 1
fi

echo "Launching Vivado (${VIEW} view) for project ${PROJECT_NAME}..."
vivado -mode tcl -source "${PROJ_DIR}/vivado/view_overlay.tcl" \
  -log "${VIVADO_LOG}" -nojournal \
  -tclargs "${PROJECT_NAME}" "${VIEW}"
