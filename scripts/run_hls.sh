#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2026 ARH Laboratory
# Author: Abdelrahman Abomosa

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJ_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
HLS_DIR="${PROJ_DIR}/hls"
STAGE="${1:-all}"

case "${STAGE}" in
  csim|csynth|export|all) ;;
  *)
    echo "Usage: $0 [csim|csynth|export|all]"
    exit 1
    ;;
esac

if [[ -n "${HLS_BIN:-}" ]]; then
  :
elif command -v vitis_hls >/dev/null 2>&1; then
  HLS_BIN="vitis_hls"
elif command -v vivado_hls >/dev/null 2>&1; then
  HLS_BIN="vivado_hls"
else
  echo "Error: neither vitis_hls nor vivado_hls found in PATH."
  exit 1
fi

echo "Running HLS stage '${STAGE}' with ${HLS_BIN}..."
(
  cd "${HLS_DIR}"
  "${HLS_BIN}" -f run_hls.tcl -tclargs "${STAGE}"
)
if [[ "${STAGE}" == "export" || "${STAGE}" == "all" ]]; then
  echo "HLS stage '${STAGE}' complete."
  echo "Exported IP is typically at ${HLS_DIR}/build/export.zip (or ${HLS_DIR}/build/export on some versions)."
else
  echo "HLS stage '${STAGE}' complete."
fi
