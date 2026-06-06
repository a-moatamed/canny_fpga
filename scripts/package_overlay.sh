#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2026 ARH Laboratory
# Author: Abdelrahman Abomosa

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJ_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

PROJECT_NAME="${PROJECT_NAME:-canny}"
BUILD_DIR="${BUILD_DIR:-${PROJ_DIR}/vivado/build/${PROJECT_NAME}}"
OVERLAY_DIR="${OVERLAY_DIR:-${PROJ_DIR}/overlay}"

mkdir -p "${OVERLAY_DIR}"

BIT_FILE="$(find "${BUILD_DIR}" -type f -path "*/impl_1/*.bit" | head -n 1 || true)"
HWH_FILE="$(find "${BUILD_DIR}" -type f -name "*.hwh" | head -n 1 || true)"

if [[ -z "${BIT_FILE}" || -z "${HWH_FILE}" ]]; then
  echo "Error: Could not locate .bit/.hwh in ${BUILD_DIR}"
  echo "Run ./scripts/run_vivado.sh first."
  exit 1
fi

cp "${BIT_FILE}" "${OVERLAY_DIR}/${PROJECT_NAME}.bit"
cp "${HWH_FILE}" "${OVERLAY_DIR}/${PROJECT_NAME}.hwh"

echo "Packaged overlay:"
echo "  ${OVERLAY_DIR}/${PROJECT_NAME}.bit"
echo "  ${OVERLAY_DIR}/${PROJECT_NAME}.hwh"
