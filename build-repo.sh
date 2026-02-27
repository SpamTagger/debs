#!/usr/bin/env bash
set -euo pipefail
source repo.conf

rm -rf dists
mkdir -p dists

declare -A suites=(
  [stable]=$STABLE
  [testing]=$TESTING
  [oldstable]=$OLDSTABLE
)

for suite in "${!suites[@]}"; do
  codename="${suites[$suite]}"
  [[ -z "$codename" ]] && continue

  for arch in $ARCHES; do
    dir="dists/$codename/main/binary-$arch"
    mkdir -p "$dir"

    dpkg-scanpackages -a "$arch" pool /dev/null > "$dir/Packages"

    gzip -9c "$dir/Packages" > "$dir/Packages.gz"
  done

  cd dists/$codename

  apt-ftparchive \
    -o APT::FTPArchive::Release::Suite=$suite \
    -o APT::FTPArchive::Release::Codename=$codename \
    -o APT::FTPArchive::Release::Components=main \
    -o APT::FTPArchive::Release::Architectures="$ARCHES" \
    release . > Release

  gpg --batch --yes --pinentry-mode loopback \
    --passphrase "$GPG_PASSPHRASE" \
    -abs -o Release.gpg Release
  gpg --batch --yes --pinentry-mode loopback \
    --passphrase "$GPG_PASSPHRASE" \
    --clearsign -o InRelease Release

  cd - >/dev/null
done
