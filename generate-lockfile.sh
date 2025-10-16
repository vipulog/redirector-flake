# shellcheck shell=bash
set -euo pipefail

orig_dir=$(pwd)
temp_dir=$(mktemp -d)

lock_file="$orig_dir/Cargo.lock"
toml_file="$REDIRECTOR_SRC/Cargo.toml"

trap 'rm -rf "$temp_dir"' EXIT
cp -r "${REDIRECTOR_SRC}"/* "$temp_dir/"
chmod -R 700 "$temp_dir"

should_generate() {
  if [ ! -f "$lock_file" ]; then
    echo "Cargo.lock not found. Generating..."
    return 0
  fi

  local lock_version
  lock_version=$(awk -v RS='' '/name = "redirector"/ {match($0, /version = "([^"]+)"/, m); print m[1]; exit}' "$lock_file" || true)

  if [ -z "$lock_version" ]; then
    echo "Could not find redirector package in Cargo.lock. Regenerating..."
    return 0
  fi

  local toml_version
  toml_version=$(grep -E '^version\s*=\s*".*"' "$toml_file" | head -1 | sed -E 's/.*"([^"]+)".*/\1/' || true)

  local comparison
  comparison=$(semver compare "$toml_version" "$lock_version" || true)

  if [ -z "$comparison" ]; then
    echo "Error: semver-tool failed. Cannot compare versions '$toml_version' and '$lock_version'." >&2
    exit 1
  fi

  if [ "$comparison" -eq 1 ]; then
    echo "Cargo.toml version ($toml_version) is newer than Cargo.lock version ($lock_version). Regenerating..."
    return 0
  fi

  echo "Cargo.lock is up to date."
  return 1
}

if should_generate; then
  pushd "$temp_dir"
  cargo generate-lockfile
  popd
  cp "$temp_dir/Cargo.lock" "$orig_dir/Cargo.lock"
  echo "✓ cargo.lock generated successfully"
fi
