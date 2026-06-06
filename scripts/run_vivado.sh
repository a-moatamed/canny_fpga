#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2026 ARH Laboratory
# Author: Abdelrahman Abomosa

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJ_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

PROJECT_NAME="${PROJECT_NAME:-canny}"
PART_NAME="${PART_NAME:-xc7z020clg400-1}"
HLS_IP_REPO="${HLS_IP_REPO:-${PROJ_DIR}/hls/build/export}"
BOARD_PART="${BOARD_PART:-}"
DEFAULT_HLS_IP_ZIP="${PROJ_DIR}/hls/build/export.zip"
UNPACK_DIR="${PROJ_DIR}/hls/build/export_ip"
VIVADO_LOG="${PROJ_DIR}/vivado/build/vivado.log"

if ! command -v vivado >/dev/null 2>&1; then
  echo "Error: vivado not found in PATH."
  exit 1
fi

mkdir -p "${PROJ_DIR}/vivado/build"

RESOLVED_HLS_IP_REPO="${HLS_IP_REPO}"
if [[ -d "${HLS_IP_REPO}" ]]; then
  :
elif [[ -f "${HLS_IP_REPO}" && "${HLS_IP_REPO}" == *.zip ]]; then
  if ! command -v unzip >/dev/null 2>&1; then
    echo "Error: unzip not found in PATH; cannot unpack ${HLS_IP_REPO}."
    exit 1
  fi
  rm -rf "${UNPACK_DIR}"
  mkdir -p "${UNPACK_DIR}"
  unzip -q -o "${HLS_IP_REPO}" -d "${UNPACK_DIR}"
  RESOLVED_HLS_IP_REPO="${UNPACK_DIR}"
  echo "Unpacked HLS IP archive ${HLS_IP_REPO} -> ${UNPACK_DIR}"
elif [[ "${HLS_IP_REPO}" == "${PROJ_DIR}/hls/build/export" && -f "${DEFAULT_HLS_IP_ZIP}" ]]; then
  if ! command -v unzip >/dev/null 2>&1; then
    echo "Error: unzip not found in PATH; cannot unpack ${DEFAULT_HLS_IP_ZIP}."
    exit 1
  fi
  rm -rf "${UNPACK_DIR}"
  mkdir -p "${UNPACK_DIR}"
  unzip -q -o "${DEFAULT_HLS_IP_ZIP}" -d "${UNPACK_DIR}"
  RESOLVED_HLS_IP_REPO="${UNPACK_DIR}"
  echo "Unpacked HLS IP archive ${DEFAULT_HLS_IP_ZIP} -> ${UNPACK_DIR}"
else
  echo "Error: HLS IP repo not found at ${HLS_IP_REPO}"
  echo "Expected either:"
  echo "  - directory: ${PROJ_DIR}/hls/build/export"
  echo "  - archive:   ${PROJ_DIR}/hls/build/export.zip"
  echo "Run ./scripts/run_hls.sh export first or set HLS_IP_REPO."
  exit 1
fi

set -x
if [[ -n "${BOARD_PART}" ]]; then
  vivado -mode batch -source "${PROJ_DIR}/vivado/build_overlay.tcl" \
    -log "${VIVADO_LOG}" -nojournal \
    -tclargs "${PROJECT_NAME}" "${PART_NAME}" "${RESOLVED_HLS_IP_REPO}" "${BOARD_PART}"
else
  vivado -mode batch -source "${PROJ_DIR}/vivado/build_overlay.tcl" \
    -log "${VIVADO_LOG}" -nojournal \
    -tclargs "${PROJECT_NAME}" "${PART_NAME}" "${RESOLVED_HLS_IP_REPO}"
fi
set +x
