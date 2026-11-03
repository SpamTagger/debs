#!/bin/bash

# Only snapshot if the newest package is older than today
# This will prevent us from unnecessarily snapshotting after each individual upload
today="$(date +%F)"

# Download current GitHub Pages content
mkdir -p current-pages
wget --recursive --no-parent --no-host-directories --cut-dirs=0 --directory-prefix=current-pages \
  https://debs.spamtagger.org/

# Find the newest modification date among published packages.
latest_package="$(
  find current-pages/pool -type f -name '*.deb' -printf '%T@ %p\n' 2>/dev/null \
    | sort -nr \
    | head -n1
)"

if [[ -n "$latest_package" ]]; then
  latest_timestamp="${latest_package%% *}"
  snapshot_date="$(date -d "@${latest_timestamp%.*}" +%F)"

  if [[ -d current-pages/snapshots ]]; then
    echo "Copying previous snapshots..."
    cp -r current-pages/snapshots snapshots
  else
    echo "Initializing snapshots directory..."
    mkdir snapshots
  fi

  if [[ "$snapshot_date" < "$today" ]]; then
    snapshot_dir="snapshots/$snapshot_date"

    if [[ ! -d "$snapshot_dir" ]]; then
      echo "Creating repository snapshot: $snapshot_dir"

      mkdir -p "$snapshot_dir"
      cp -a current-pages/dists current-pages/pool "$snapshot_dir/"
    else
      echo "Snapshot already exists: $snapshot_dir"
    fi
  else
    echo "Latest package modification date is today; skipping snapshot."
  fi
else
  echo "No existing packages found; skipping snapshot."
fi
