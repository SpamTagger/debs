#!/usr/bin/env bash
set -euo pipefail

# Load expected packages, architectures, releases
source repo.conf
ARCH=$(echo $ARCHES | sed 's/ /|/g')

mkdir -p pool/main
for entry in "${PACKAGES[@]}"; do
  NAME="${entry%%|*}"
  REPO="${entry##*|}"

  echo "Fetching $NAME from $REPO"

  releases=$(curl -s https://api.github.com/repos/$REPO/releases)

  echo "$releases" \
    | jq -r '.[].assets[].browser_download_url' \
    | grep '\.deb$' \
    | while read -r url; do

        file=$(basename "$url")

        arch=$(echo "$file" | grep -oE "($ARCH)" || true)

        if [[ -z "$arch" ]]; then
          echo "Skipping unknown arch: $file"
          continue
        fi

        if grep -q "$NAME:$arch" <(printf "%s\n" "${OPTIONAL[@]}"); then
          wget -q -nc "$url" -P pool/main || true
        else
          wget -q -nc "$url" -P pool/main
        fi
    done
done
