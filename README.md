# <img src="https://raw.githubusercontent.com/SpamTagger/debs/refs/heads/main/spamtagger-debs.svg" alt="SpamTagger Debian Repository Logo" style="height:2em; vertical-align:middle;"> SpamTagger Debian Packages

## 🧪 About 🧪

This is an experimental repository intended host custom Debian packages. The packages are built, bundled and uploaded to the GitHub Packages page of their respective repositories. This projects merely downloads, signs and and serves the packages with an APT-compliant GitHub Pages instance.

Packages from the APT repository will be used to build SpamTagger images using the [SpamTagger-Bootc](https://github.com/SpamTagger/SpamTagger-Bootc) project, and the latest version of each package will be available via a `bootc upgrade` to the latest image. Unless you are trying to run to manually install SpamTagger in an unsupported environment, you should need to know anything about this project.

## 🔧 Manual Usage 🔧

If you are interested in using these packages outside of an officially suppored Bootc environment, you can do so as follows (running as a regular user is assumed, you can drop all usages of `sudo` if you are running as `root`):

Download and install the public GPG key:

```
curl -fsSL http://spamtagger.github.io/debs/spamtagger.key | \
sudo gpg --dearmor -o /etc/apt/keyrings/spamtagger.gpg
```

Add this repository as a source to your Debian system at `/etc/apt/sources.list.d/spamtagger.sources`:

```
Types: deb
URIs: http://spamtagger.github.io/debs
Suites: stable
Components: main
Signed-By: /etc/apt/keyrings/spamtagger.gpg
```

Run an `apt-get update` to refresh your repository package listings:

```
sudo apt-get update
```

Install a package:

```
sudo apt-get install st-exim
```
