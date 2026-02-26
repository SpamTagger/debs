# <img src="https://raw.githubusercontent.com/SpamTagger/debs/refs/heads/main/spamtagger-debs.svg" alt="SpamTagger Debian Repository Logo" style="height:2em; vertical-align:middle;"> SpamTagger Debian Packages

## 🧪 About 🧪

This repository is used to host SpamTagger's custom Debian packages via GitHub Pages. Note that this repository does not build any packages, it merely sets up a repository to host them. The packages are built, bundled, signed and uploaded to the GitHub Packages page of their respective repositories.

This projects is heavily reliant on GitHub Actions to assemble the repository, stage new packages, promote them to stable, rollback snapshots and maintain a web index of the files for easy browsing.

New repository builds can be initialized in a few ways:

* Automatically by one of the package repositories. Repositories such as `st-exim` trigger a build any time they successfully upload a new release.
* Manually by a repository owner. The ability to trigger the workflow is available from the Actions tab.
* Weekly on Mondays. Regardless of whether new packages are available, it will rebuild every Monday just to ensure that it heals if broken or if a necessary trigger failed to happen.

## ✔️ Usage ✔️

If you are an ordinary SpamTagger user, you don't need to use this repository at all. You should be using SpamTagger via one of the supported [SpamTagger-Bootc](https://github.com/SpamTagger/SpamTagger-Bootc) images. That project will automatically install the latest available stable package relevant to the given release and architecture and bundle them in to the read-only filesystem layer. To get new versions of packages, you will just upgrade to the latest filesystem image via a `bootc upgrade`.

## 🔧 Manual Usage 🔧

If you are interested in using these packages outside of an officially supported Bootc environment, you can do so. Note that this is not recommeneded unless you are assisting with the development of SpamTagger. The latest packages may not be fully tested until a SpamTagger-Bootc build including them has been released, even if they are in the `stable` distribution.

You can use these packages follows (running as a regular user is assumed, you can drop all usages of `sudo` if you are running as `root`):

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

Note that because these packages are intended for use in a SpamTagger-Bootc environment, a generic system may be missing some prerequisites for. For example, `st-exim` currently does not create a `spamtagger` user since one would be automatically created during the build of SpamTagger-Bootc. If you use the generic SpamTagger build instructions, this user should also be created, but use caution otherwise.

## ✨ Features ✨

* Should be nearly totally automated via GitHub actions and remote triggers.
* Latest packages available from the web via [GitHub Pages](https://debs.spamtagger.org).
* New packages added to as staging releases.
* Staged packages promoted via the `promote.yml` workflow, triggered by the owner.
* Automatic snapshots of current state during `promote.yml`
* Restoring of previous snapshot with `rollback.yml` workflow, triggered by the owner.
