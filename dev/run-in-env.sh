#!/usr/bin/env bash
set -euo pipefail
set +H

# Unified wrapper: selects r-core/r-bayes per repo, handles HPC/cloud/desktop.

# Repo root
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || realpath "$(dirname "$0")/..")"

# Optional helper: locate a binary inside the env
if [[ "${1:-}" == "--which" ]]; then
  [[ $# -ge 2 ]] || { echo "Usage: $0 --which <binary>" >&2; exit 2; }
  WHICH_BIN="$2"; shift 2
  set -- bash -lc "command -v \"${WHICH_BIN}\""
fi

# Choose env family by repo flag, default to core
STACK_FILE="$REPO_ROOT/env/STACK"
STACK="$( [ -f "$STACK_FILE" ] && tr -d '\n\r ' < "$STACK_FILE" || echo core )"
case "$STACK" in
  bayes) ENV_FAMILY="r-bayes" ;;
  core|*) ENV_FAMILY="r-core" ;;
esac

# Allow explicit override
ENV_NAME="${RUN_ENV_NAME:-$ENV_FAMILY}"

# Compute context (explicit beats auto)
CTX="${COMPUTE_CONTEXT:-auto}"
uname_s="$(uname -s 2>/dev/null || echo Unknown)"
case "$CTX" in
  auto)
    if [[ -n "${SLURM_JOB_ID:-}" ]]; then CTX=hpc
    elif [[ -f "/.dockerenv" || -f "/run/.containerenv" ]]; then CTX=cloud
    elif [[ "$uname_s" == MINGW* || "$uname_s" == MSYS* || "$uname_s" == CYGWIN* ]]; then CTX=windows
    else CTX=desktop
    fi
    ;;
  hpc|cloud|desktop|windows) : ;;
  *) echo "Unknown COMPUTE_CONTEXT=$CTX" >&2; exit 2;;
esac

# Prefix and caches per context
case "$CTX" in
  hpc)
    # Use shared HPC root; keep caches local to node when possible
    export MAMBA_ROOT_PREFIX="/extra/484251/mamba"
    _tmp="${TMPDIR:-/local/conda-pkgs}"; mkdir -p "$_tmp" 2>/dev/null || true
    mkdir -p "/extra/484251/mamba/pkgs" 2>/dev/null || true
    export CONDA_PKGS_DIRS="${_tmp}:/extra/484251/mamba/pkgs"
    ;;
  cloud)
    # Explicit root prefix avoids micromamba default-root checks on /root/.local/share/mamba
    export MAMBA_ROOT_PREFIX="${MAMBA_ROOT_PREFIX:-$HOME/.local/share/mamba}"
    mkdir -p "$MAMBA_ROOT_PREFIX" 2>/dev/null || true
    export CONDA_PKGS_DIRS="${CONDA_PKGS_DIRS:-/tmp/conda-pkgs}"
    mkdir -p "$CONDA_PKGS_DIRS" 2>/dev/null || true
    ;;
  desktop|windows)
    # Default to user local prefix unless overridden
    export MAMBA_ROOT_PREFIX="${MAMBA_ROOT_PREFIX:-$HOME/.local/share/mamba}"
    mkdir -p "$MAMBA_ROOT_PREFIX" 2>/dev/null || true
    ;;
esac

# Canonical specs (environment.yml is authoritative; env/r-core.yml kept for compatibility)
BASE_SPEC="$REPO_ROOT/environment.yml"
LEGACY_CORE_SPEC="$REPO_ROOT/env/r-core.yml"
EXTRAS_SPEC="$REPO_ROOT/env/r-bayes-extras.yml"
LOCK_SPEC="$REPO_ROOT/env/lock-linux-64.txt"

if [[ ! -f "$BASE_SPEC" && -f "$LEGACY_CORE_SPEC" ]]; then
  BASE_SPEC="$LEGACY_CORE_SPEC"
fi

# Optional dry-run: print plan and exit
if [[ "${1:-}" == "--dry-run" || "${DRY_RUN:-0}" == "1" ]]; then
  echo "stack=$STACK env_family=$ENV_FAMILY env_name=$ENV_NAME context=$CTX"
  if [[ -n "${MAMBA_ROOT_PREFIX:-}" ]]; then
    echo "root_prefix=$MAMBA_ROOT_PREFIX"
    echo "planned_env_path=${MAMBA_ROOT_PREFIX}/envs/${ENV_NAME}"
  else
    echo "root_prefix=(user default)"
    echo "planned_env_path=$HOME/.local/share/mamba/envs/${ENV_NAME}"
  fi
  echo "base_spec=$BASE_SPEC"
  if [[ "$ENV_FAMILY" == "r-bayes" ]]; then
    echo "extras_spec=$EXTRAS_SPEC"
  fi
  if [[ "$CTX" == cloud ]]; then
    echo "ephemeral_path=/tmp/${ENV_NAME}-$$"
  fi
  exit 0
fi

# Micromamba detection (no auto-download on HPC)
if ! command -v micromamba >/dev/null 2>&1; then
  SCRIPT_DIR="$(dirname "$0")"
  if [[ -x "${SCRIPT_DIR}/micromamba/bin/micromamba" ]]; then
    export PATH="${SCRIPT_DIR}/micromamba/bin:$PATH"
  else
    if [[ "$CTX" == hpc ]]; then
      echo "micromamba not found on HPC. Load a module or place it at dev/micromamba/bin." >&2
      exit 1
    fi
    echo "Downloading micromamba to dev/micromamba/bin ..." >&2
    uname_m="$(uname -m)" || uname_m=""
    case "${uname_s}:${uname_m}" in
      Linux:x86_64|Linux:amd64) MM_PLAT="linux-64" ;;
      Linux:aarch64|Linux:arm64) MM_PLAT="linux-aarch64" ;;
      Darwin:x86_64) MM_PLAT="osx-64" ;;
      Darwin:arm64) MM_PLAT="osx-arm64" ;;
      *) echo "Unsupported platform for micromamba bootstrap: ${uname_s}/${uname_m}" >&2; exit 1 ;;
    esac
    MM_URL="https://micro.mamba.pm/api/micromamba/${MM_PLAT}/latest"
    TMPDIR_MM="$(mktemp -d)"; mkdir -p "${SCRIPT_DIR}/micromamba/bin"
    curl -fsSL "$MM_URL" -o "${TMPDIR_MM}/micromamba.tar.bz2"
    tar -xjf "${TMPDIR_MM}/micromamba.tar.bz2" -C "${TMPDIR_MM}" bin/micromamba
    mv "${TMPDIR_MM}/bin/micromamba" "${SCRIPT_DIR}/micromamba/bin/micromamba"
    chmod +x "${SCRIPT_DIR}/micromamba/bin/micromamba"; rm -rf "$TMPDIR_MM"
    export PATH="${SCRIPT_DIR}/micromamba/bin:$PATH"
  fi
fi

# Speed knobs
export MAMBA_DOWNLOAD_THREADS=10
_NPROC=$( (command -v nproc >/dev/null 2>&1 && nproc) || getconf _NPROCESSORS_ONLN 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 1 )
export MAKEFLAGS="-j${_NPROC}"

# Idempotency: if already inside the requested env, bypass micromamba
ACTIVE_ENV="${MAMBA_DEFAULT_ENV:-${CONDA_DEFAULT_ENV:-}}"
if [[ -n "${ACTIVE_ENV}" && "${ACTIVE_ENV}" == "${ENV_NAME}" ]]; then
  exec "$@"
fi

ENV_PATH=""

if [[ "$CTX" == cloud ]]; then
  ENV_PATH="/tmp/${ENV_NAME}-$$"
  if [[ ! -d "$ENV_PATH" ]]; then
    if [[ "$ENV_NAME" == "r-core" ]]; then
      SPEC_FILE="${LOCK_SPEC}"
      [[ -f "$SPEC_FILE" ]] || SPEC_FILE="$BASE_SPEC"
      echo "Creating cloud env at $ENV_PATH from $SPEC_FILE"
      micromamba create -y -p "$ENV_PATH" -f "$SPEC_FILE"
    else
      SPEC_FILE="$BASE_SPEC"
      echo "Creating cloud env at $ENV_PATH from $SPEC_FILE + bayes extras"
      micromamba create -y -p "$ENV_PATH" -f "$SPEC_FILE"
      [[ -f "$EXTRAS_SPEC" ]] && micromamba install -y -p "$ENV_PATH" -f "$EXTRAS_SPEC"
    fi
  fi
else
  # Persistent envs (HPC/desktop/windows)
  if [[ -n "${MAMBA_ROOT_PREFIX:-}" && -d "${MAMBA_ROOT_PREFIX}/envs/${ENV_NAME}" ]]; then
    ENV_PATH="${MAMBA_ROOT_PREFIX}/envs/${ENV_NAME}"
  elif [[ -d "$HOME/.local/share/mamba/envs/${ENV_NAME}" ]]; then
    ENV_PATH="$HOME/.local/share/mamba/envs/${ENV_NAME}"
  else
    # Fallback: try to discover via "micromamba env list"
    ENV_PATH=$(micromamba env list | awk '{print $NF}' | grep -E "/${ENV_NAME}$" | head -1 || true)
  fi

  if [[ -z "$ENV_PATH" ]]; then
    target_root="${MAMBA_ROOT_PREFIX:-$HOME/.local/share/mamba}"
    mkdir -p "$target_root" 2>/dev/null || true
    ENV_PATH="${target_root}/envs/${ENV_NAME}"
    if [[ "$ENV_NAME" == "r-core" ]]; then
      SPEC_FILE="$BASE_SPEC"
      if [[ "$uname_s" == Linux* && -f "$LOCK_SPEC" ]]; then
        SPEC_FILE="$LOCK_SPEC"
      fi
      echo "Creating env '${ENV_NAME}' in ${target_root} from ${SPEC_FILE}"
      micromamba create -y -p "$ENV_PATH" -f "$SPEC_FILE"
    else
      echo "Creating env '${ENV_NAME}' in ${target_root} from ${BASE_SPEC} + bayes extras"
      micromamba create -y -p "$ENV_PATH" -f "$BASE_SPEC"
      [[ -f "$EXTRAS_SPEC" ]] && micromamba install -y -p "$ENV_PATH" -f "$EXTRAS_SPEC"
    fi
  fi
fi

# Ensure env bin is preferred to stabilize PATH on some clusters
export PATH="${ENV_PATH}/bin:${PATH}"

# Quarto adjustments for conda packaging (ensure deno/share paths)
if [[ -x "${ENV_PATH}/bin/quarto" ]]; then
  if [[ -z "${QUARTO_DENO:-}" && -x "${ENV_PATH}/bin/deno" && ! -x "${ENV_PATH}/bin/tools/x86_64/deno" && ! -x "${ENV_PATH}/bin/tools/aarch64/deno" ]]; then
    export QUARTO_DENO="${ENV_PATH}/bin/deno"
  fi
  if [[ -z "${QUARTO_SHARE_PATH:-}" && -d "${ENV_PATH}/share/quarto" ]]; then
    export QUARTO_SHARE_PATH="${ENV_PATH}/share/quarto"
  fi
fi
# Ensure Quarto uses env R
if [[ -x "${ENV_PATH}/bin/R" ]]; then export QUARTO_R="${ENV_PATH}/bin/R"; fi


echo "Running in '${ENV_NAME}' at ${ENV_PATH}"
exec micromamba run -p "${ENV_PATH}" "$@"
