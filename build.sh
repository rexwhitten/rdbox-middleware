#!/bin/bash

if [ $# != 1 ]; then
  echo "Invalid Argment."
  echo "You need to specify the version number. (like 0.0.1)"
  exit 1
fi

version_no=$1
git checkout master
commit_id=$(git rev-parse HEAD)
git archive --format=tar.gz --prefix=rdbox/ -o ../rdbox_"${version_no}".orig.tar.gz "${commit_id}"

cd ../rdbox-middleware-deb/ || exit
git branch --delete dfsg_clean
git branch dfsg_clean upstream
git checkout master
git tag -d upstream/"${version_no}"
gbp import-orig --no-merge -u "${version_no}" --pristine-tar ../rdbox_"${version_no}".orig.tar.gz
git checkout dfsg_clean
git pull . upstream
git checkout master
git pull . dfsg_clean
rm -rf ../build-area/
gbp buildpackage --git-pristine-tar-commit --git-export-dir=../build-area -S -sd

# need sudo
sudo OS=raspbian DIST=buster ARCH=armhf pbuilder --build ../build-area/rdbox_"${version_no}".dsc