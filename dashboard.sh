#!/usr/bin/env bash

set -e

function recursive_directory() {
  local path=$1
  echo "Starting $path"
  last=$(echo $path | sed -r 's/(.*)\/[^\/]*/\1/')
  cat >${path}.html <<EOF
$HTML_HEAD
<h1>Index of $path</h1>
EOF
  [[ ! -d $last ]] && mkdir -p $last
  if grep -qv "/" <<<$(echo $path); then
    echo "Adding parent: <ul><li><a href='/browse.html'>..</a><li> >> ${path}.html"
    echo "<ul><li><a href='/browse.html'>..</a><li>" >> ${path}.html
  else
    echo "Adding parent: <ul><li><a href='/${last}.html'>..</a><li> >> ${path}.html"
    echo "<ul><li><a href='/${last}.html'>..</a><li>" >> ${path}.html
  fi
  for item in $(find $path -mindepth 1 -maxdepth 1 -type d); do
    next=$(echo $item | sed -r 's/.*\/([^\/]*)/\1/')
    [[ "$next" == "." ]] || [[ "$next" == ".." ]] || [[ "$next" =~ ".html$" ]] && continue
    echo "Adding directory: <li><a href='/${item}.html'>$next/</a></li> >> ${path}.html"
    echo "<li><a href='/${item}.html'>$next/</a></li>" >> ${item}.html
    recursive_directory $item
  done
  for pkg in $(find $path -mindepth 1 -maxdepth 1 -type f); do
    [[ "$pkg" =~ .html$ ]] && continue
    file=$(echo $pkg | sed -r 's/.*\/([^\/]*)/\1/')
    echo "Adding file: <li><a href='/$pkg'>$file</a></li> >> ${path}.html"
    echo "<li><a href='/$pkg'>$file</a></li>" >> ${path}.html
  done
  echo "</ul></body>" >> ${path}.html
  echo "Ending $path"
}

# Landing page with all stable packages
# TODO: Format into table for different releases/architectures

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
cat >index.html <<EOF
$HTML_HEAD
<h1>SpamTagger APT Repo Packages</h1>
EOF

echo "<table><tr><th>Package</th><th>Debian Release</th><th>Version</th><th>Architecture</th><th>Download</th><th>Checksum</th></tr>" >> index.html
for deb in pool/main/*.deb; do
  name=$(echo $deb | sed -r 's/.*\/([^_]*).*/\1/')
  ver=$(echo $deb | sed -r 's/[^_]*_([^\+]*)\+.*/\1/')
  rel=$(echo $deb | sed -r 's/[^+]*\+([^_]*)_.*/\1/')
  arch=$(echo $deb | sed -r 's/.*_([^\.]*).deb/\1/')
  echo "<tr><td>$name</td><td>$rel</td><td>$ver</td><td>$arch</td><td><a href='https://debs.spamtagger.org/$deb'>download</a></td><td><a href='https://debs.spamtagger.org/$deb.sha256'>sha256</a></td></tr>" >> index.html
done
echo "</tr></table><p><a href='/browse.html'>Browse</a> full APT repository for all package versions and snapshots.</p></body>" >> index.html

echo "<h1>SpamTagger APT Repo Index</h1>" > browse.html
echo "<ul><li><a href='/index.html'>..</a><li>" >> browse.html
for i in dists pool snapshots; do
  echo "<li><a href='/$i.html'>$i/</a><li>" >> browse.html
  recursive_directory $i
done
echo "</ul></body>" >> browse.html
