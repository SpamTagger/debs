#!/usr/bin/env bash

set -e

# Landing page with all stable packages
# TODO: Format into table for different releases/architectures

echo "<h1>SpamTagger APT Repo Packages</h1>" > index.html

echo "<table><tr><th>Package</th><th>Debian Release</th><th>Version</th><th>Architecture</th><th>Download</th></tr>" >> index.html
for deb in pool/main/*.deb; do
  name=$(echo $deb | sed -r 's/.*\/([^_]*).*/\1/')
  ver=$(echo $deb | sed -r 's/[^_]*_([^\+]*)\+.*/\1/')
  rel=$(echo $deb | sed -r 's/[^+]*\+([^_]*)_.*/\1/')
  arch=$(echo $deb | sed -r 's/.*_([^\.]*).deb/\1/')
  echo "<tr><td>$name</td><td>$rel</td><td>$ver</td><td>$arch</td><td><a href='https://debs.spamtagger.org/$deb'>download</a></td></tr>" >> index.html
done

# TODO: Generate browseable index pages for stable, staging (if it exists) and snapshots
echo "</tr></table><p>Browse <a href='/dists.html'>current packages</a>, <a href='/staging.html'>staging packages</a>, or <a href='/snapshots.html'>previous snapshots</a>" >> index.html
