#!/usr/bin/env bash
# qmllint over the shell. Quickshell resolves `import qs.X` at runtime by
# generating qmldirs; mirror that on a temp copy so qmllint can follow them.
# Needs qmllint on PATH (nix: qt6.qtdeclarative) and these env vars:
#   QS_QML   Quickshell's lib/qt-6/qml        (${pkgs.quickshell}/lib/qt-6/qml)
#   QT_QML   Qt's own QML modules, space-separated -I dirs (qtdeclarative, qtbase)
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
mkdir "$tmp/qs"
cp -r "$here/Common" "$here/Widgets" "$here/Services" "$here/Modules" "$here/shell.qml" "$tmp/qs/"
cd "$tmp/qs"
find Common Widgets Services Modules -type d | while read -r dir; do
  {
    echo "module qs.${dir//\//.}"
    for f in "$dir"/*.qml; do
      [ -e "$f" ] || continue
      n=$(basename "$f" .qml)
      if grep -q '^pragma Singleton' "$f"; then echo "singleton $n 1.0 $n.qml"; else echo "$n 1.0 $n.qml"; fi
    done
  } > "$dir/qmldir"
done
args=(-I "$tmp" -I "${QS_QML:?set QS_QML}")
for p in ${QT_QML:-}; do args+=(-I "$p"); done
if [ -f "$here/.qmllint.ini" ]; then cp "$here/.qmllint.ini" .; fi
# qmllint exits 0 on warnings; fail on any so CI is meaningful.
out=$(qmllint "${args[@]}" "$@" $(find "$PWD" -name '*.qml' | sort) 2>&1) || true
if [ -n "$out" ]; then
  echo "${out//$tmp\/qs\//}"
  exit 1
fi
echo "qmllint: clean"
