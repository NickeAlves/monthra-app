#!/usr/bin/env bash
# Copies the goldens CI rendered for this branch into test/.
#
#   scripts/pull-goldens.sh [run-id]
#
# Goldens are rendered and compared on Linux only (font rasterization
# differs on macOS), so CI is the reference: when its test job fails, it
# renders the goldens again and uploads them as the "goldens" artifact,
# with the diff images of the failures. Without a run id, the latest run
# of the ci workflow on the current branch is used. Look at every image
# before committing it.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root"

run="${1:-}"
if [ -z "$run" ]; then
  branch="$(git rev-parse --abbrev-ref HEAD)"
  run="$(gh run list --workflow ci.yml --branch "$branch" --limit 1 \
    --json databaseId --jq '.[0].databaseId')"
  [ -n "$run" ] || { echo "no ci run on $branch" >&2; exit 1; }
fi

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
gh run download "$run" --name goldens --dir "$work"

count=0
while IFS= read -r file; do
  mkdir -p "$(dirname "$file")"
  cp "$work/$file" "$file"
  count=$((count + 1))
done < <(cd "$work" && find test -path '*/goldens/*.png' | sort)
echo "copied $count goldens from run $run"

failures="$(cd "$work" && find test -path '*/failures/*.png' | sort)"
if [ -n "$failures" ]; then
  echo "diff images of the failed comparisons (in the artifact):"
  echo "$failures"
fi
git status --short -- test
