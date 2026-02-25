#!/usr/bin/env bash

set -e

# Landing page with all stable packages
# TODO: Format into table for different releases/architectures

echo "<h1>SpamTagger APT Repo Packages</h1>" > index.html

echo "<table><tr><th>Package</th><th>Debian Release</th><th>Version</th><th>Architecture</th><th>Download</th><th>Checksum</th></tr>" >> index.html
for deb in pool/main/*.deb; do
  name=$(echo $deb | sed -r 's/.*\/([^_]*).*/\1/')
  ver=$(echo $deb | sed -r 's/[^_]*_([^\+]*)\+.*/\1/')
  rel=$(echo $deb | sed -r 's/[^+]*\+([^_]*)_.*/\1/')
  arch=$(echo $deb | sed -r 's/.*_([^\.]*).deb/\1/')
  echo "<tr><td>$name</td><td>$rel</td><td>$ver</td><td>$arch</td><td><a href='https://debs.spamtagger.org/$deb'>download</a></td><td><a href='https://debs.spamtagger.org/$deb.sha256'>sha256</a></td></tr>" >> index.html
done

echo "</tr></table><p>Browse <a href='/dists.html'>current packages</a>, or <a href='/snapshots.html'>previous snapshots</a>" >> index.html

echo "<ul><li><a href='/index.html'>..</a><li>" > dists.html
for dist in $(find dists -mindepth 1 -maxdepth 1 -type d); do
  next=$(echo $dist | cut -d '/' -f 2)
  echo "<li><a href='${dist}.html'>$next/</a></li>" >> dists.html
  echo "<ul><li><a href='/dists.html'>..</a><li>" > ${dist}.html
  for pkg in $(find $dist -mindepth 1 -maxdepth 1 -type f); do
    file=$(echo $pkg | cut -d '/' -f 3)
    echo "<li><a href='${dist}/$file'>$file/</a></li>" >> ${dist}.html
  done
  echo "</ul>" >> ${dist}.html
done
echo "</ul>" >> dists.html

echo "<ul><li><a href='/index.html'>..</a><li>" > snapshots.html
if [ -e snapshots ]; then
  for snapshot in $(find snapshots -mindepth 1 -maxdepth 1 -type d); do
    next=$(echo $snapshot | cut -d '/' -f 2)
    echo "<li><a href='${snapshot}.html'>$snapshot/</a></li>" >> snapshots.html
    echo "<ul><li><a href='/snapshots.html'>..</a><li>" > ${snapshot}.html
    for dist in $(find $snapshot -mindepth 1 -maxdepth 1 -type d); do
      next=$(echo $dist | cut -d '/' -f 3)
      echo "<li><a href='${dist}.html'>$next/</a></li>" >> ${snapshot}.html
      echo "<ul><li><a href='/dists.html'>..</a><li>" > ${dist}.html
      for pkg in $(find $dist -mindepth 1 -maxdepth 1 -type f); do
        file=$(echo $pkg | cut -d '/' -f 4)
        echo "<li><a href='${dist}/$file'>$file/</a></li>" >> ${dist}.html
      done
      echo "</ul>" >> ${dist}.html
    done
    echo "</ul>" >> ${snapshot}.html
  done
fi
echo "</ul>" >> snapshots.html

