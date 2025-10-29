#!/usr/bin/env bash
set -euo pipefail
# Execute an R script inside the project environment managed by dev/run-in-env.sh.
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || realpath "$(dirname "$0")/..")"
exec "${REPO_ROOT}/dev/run-in-env.sh" Rscript "$@"
