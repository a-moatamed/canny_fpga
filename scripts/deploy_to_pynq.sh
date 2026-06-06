#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2026 ARH Laboratory
# Author: Abdelrahman Abomosa

set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <pynq-host> [remote_dir]"
  exit 1
fi

HOST="$1"
REMOTE_DIR="${2:-/home/xilinx/jupyter_notebooks/canny_edge_detector}"

if [[ "${HOST}" == *"@"* ]]; then
  echo "Error: pass only IP/DNS host. User is fixed to 'xilinx'."
  exit 1
fi

TARGET="xilinx@${HOST}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJ_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

PROJECT_NAME="${PROJECT_NAME:-canny}"
BIT_FILE="${PROJ_DIR}/overlay/${PROJECT_NAME}.bit"
HWH_FILE="${PROJ_DIR}/overlay/${PROJECT_NAME}.hwh"
NOTEBOOK_SCRIPT="${PROJ_DIR}/notebook/run_canny.py"

if [[ ! -f "${BIT_FILE}" || ! -f "${HWH_FILE}" ]]; then
  echo "Error: overlay files are missing in ${PROJ_DIR}/overlay"
  echo "Run ./scripts/package_overlay.sh first."
  exit 1
fi

# Reuse one SSH connection so password is requested once.
CONTROL_PATH="/tmp/pynq_mux_${USER}_$(echo "${TARGET}" | tr '@:./' '_')"
SSH_COMMON_OPTS=(-o ControlMaster=auto -o "ControlPath=${CONTROL_PATH}" -o ControlPersist=120)

cleanup() {
  ssh -o "ControlPath=${CONTROL_PATH}" -O exit "${TARGET}" >/dev/null 2>&1 || true
}
trap cleanup EXIT

ssh "${SSH_COMMON_OPTS[@]}" -MNf "${TARGET}"
ssh "${SSH_COMMON_OPTS[@]}" "${TARGET}" "mkdir -p '${REMOTE_DIR}'"
scp "${SSH_COMMON_OPTS[@]}" "${BIT_FILE}" "${HWH_FILE}" "${NOTEBOOK_SCRIPT}" "${TARGET}:${REMOTE_DIR}/"

echo "Deployed to ${TARGET}:${REMOTE_DIR}"
