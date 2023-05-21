#!/usr/bin/env sh

# abort on errors
set -e

# build
flutter build web --release --base-href '/dispute/'

# navigate into the build output directory
cd build/web

git init
git add -A
git commit -m 'deploy'

# if you are deploying to https://<USERNAME>.github.io/<REPO>
git push -f git@github.com:ethicnology/dispute.git master:gh-pages #main or master

cd -