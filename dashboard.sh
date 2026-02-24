echo "<h1>SpamTagger APT Repo Packages</h1>" > index.html

for deb in pool/main/*.deb; do
  name=$(dpkg-deb -f "$deb" Package)
  ver=$(dpkg-deb -f "$deb" Version)
  arch=$(dpkg-deb -f "$deb" Architecture)

  echo "<a href='https://debs.spamtagger.io/dists/$ver/main/$deb'><p>$name $ver ($arch)</p></a>" >> index.html
done
