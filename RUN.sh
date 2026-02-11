#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$ROOT_DIR/build"

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "Este script foi pensado para macOS (Darwin)."
  exit 1
fi

CPU_COUNT="$(sysctl -n hw.ncpu 2>/dev/null || echo 4)"

echo "==> Configurando CMake..."
cmake -S "$ROOT_DIR" -B "$BUILD_DIR"

echo "==> Compilando (jobs=$CPU_COUNT)..."
cmake --build "$BUILD_DIR" -j"$CPU_COUNT"

APP_CANDIDATES=(
  "$BUILD_DIR/apps/desktop/SofaStudio.app/Contents/MacOS/SofaStudio"
  "$BUILD_DIR/apps/desktop/sofa-studio"
  "$BUILD_DIR/apps/desktop/SofaStudio"
)

for app in "${APP_CANDIDATES[@]}"; do
  if [[ -x "$app" ]]; then
    echo "==> Executando: $app"
    exec "$app" "$@"
  fi
done

echo "Nao encontrei o executavel apos o build."
echo "Caminhos verificados:"
for app in "${APP_CANDIDATES[@]}"; do
  echo " - $app"
done
exit 1
