#!/usr/bin/env bash

set -e

################################################################################
# Basic HTML page setup
################################################################################

HTML_HEAD='
<html>
  <head>
    <title>SpamTagger APT Repository</title>
    <meta charset="utf-8">
    <link href="/style.css" rel="stylesheet">
    <link href="/spamtagger-debs.svg" rel="image/svg+xml">
  </head>
  <body>
'

################################################################################
# Recursive building of all directories under /dist, /pool, and /snapshots
################################################################################

function recursive_directory() {
  local path=$1
  last=$(echo $path | sed -r 's/(.*)\/[^\/]*/\1/')
  cat >${path}.html <<EOF
$HTML_HEAD
<h1>Index of $path</h1>
<table>
  <tr><th>Name</th><th>Last modified</th><th>size</th></tr>
EOF
  modified=''
  size='-'
  [[ ! -d $last ]] && mkdir -p $last
  if grep -qv "/" <<<$(echo $path); then
    echo "<tr><td>📂<a href='/browse.html'>..</a></td><td>$modified</td><td>$size</td></tr>" >> ${path}.html
  else
    echo "<tr><td>📂<a href='/${last}.html'>..</a></td><td>$modified</td><td>$size</td></tr>" >> ${path}.html
  fi
  for item in $(find $path -mindepth 1 -maxdepth 1 -type d); do
    modified=$(stat $item --format=%y | cut -d'.' -f 1)
    next=$(echo $item | sed -r 's/.*\/([^\/]*)/\1/')
    [[ "$next" == "." ]] || [[ "$next" == ".." ]] || [[ "$next" =~ ".html$" ]] && continue
    echo "<tr><td>📁<a href='/${item}.html'>$next/</a></td><td>$modified</td><td>$size</td></tr>" >> ${path}.html
    recursive_directory $item
  done
  for pkg in $(find $path -mindepth 1 -maxdepth 1 -type f); do
    [[ "$pkg" =~ .html$ ]] && continue
    modified=$(stat $pkg --format=%y | cut -d'.' -f 1)
    size=$(stat $pkg --format=%s | numfmt --to=iec)
    file=$(echo $pkg | sed -r 's/.*\/([^\/]*)/\1/')
    icon="📄"
    [[ "$file" =~ .deb$ ]] && icon="📦"
    [[ "$file" =~ .gpg$ ]] && icon="🔑"
    [[ "$file" =~ .gz$ ]] && icon="🗄️"
    echo "<tr><td>$icon<a href='/$pkg'>$file</a></td><td>$modified</td><td>$size</td></tr>" >> ${path}.html
  done
  echo "</table></body>" >> ${path}.html
}

################################################################################
# Main index.html page
################################################################################

cat >index.html <<EOF
$HTML_HEAD
<h1>SpamTagger APT Repo - Latest Packages</h1>
EOF

declare -A latest

for deb in pool/main/*.deb; do
  name=$(echo $deb | sed -r 's/.*\/([^_]*).*/\1/')
  ver=$(echo $deb | sed -r 's/[^_]*_([^\+]*)\+.*/\1/')
  rel=$(echo $deb | sed -r 's/[^+]*\+([^_]*)_.*/\1/')
  key="$name|$rel"
  if [[ -z ${latest[$key]} ]] ||
    dpkg --compare-versions "$ver" gt "${latest[$key]}"; then
    latest[$key]=$ver
  fi
done

echo "<table><tr><th>Package</th><th>Debian Release</th><th>Version</th><th>Architecture</th><th>Download</th></tr>" >> index.html
for deb in pool/main/*.deb; do
  name=$(echo $deb | sed -r 's/.*\/([^_]*).*/\1/')
  ver=$(echo $deb | sed -r 's/[^_]*_([^\+]*)\+.*/\1/')
  rel=$(echo $deb | sed -r 's/[^+]*\+([^_]*)_.*/\1/')
  arch=$(echo $deb | sed -r 's/.*_([^\.]*).deb/\1/')
  key="$name|$rel"
  if [[ "$ver" == "${latest[$key]}" ]]; then
    echo "<tr><td>$name</td><td>$rel</td><td>$ver</td><td>$arch</td><td><a href='https://debs.spamtagger.org/$deb'>download</a></td></tr>" >> index.html
  fi
done
echo "</tr></table><p><a href='/browse.html'>Browse</a> full APT repository for all package versions and snapshots.</p></body>" >> index.html

################################################################################
# Top-level browse.html page
################################################################################

cat >browse.html <<EOF
$HTML_HEAD
<h1>SpamTagger APT Repo Index</h1>
<table>
  <tr><th>Name</th><th>Last modified</th><th>size</th></tr>
  <tr><td>📂<a href='/index.html'>..</a></td><td></td><td>-</td></tr>
EOF

for i in dists pool snapshots; do
  modified=$(stat $item --format=%y | cut -d'.' -f 1)
  echo "<tr><td>📁<a href='/${i}.html'>$i/</a></td><td>$modified</td><td>-</td></tr>" >> browse.html
  # All recursive pages generated here
  recursive_directory $i
done
echo "</table></body>" >> browse.html
