#!/bin/bash

# Website URL
SITE_URL="https://grainvita.com/"

# GitHub Repo
GIT_REPO="https://github.com/usmansaif/grainvita-web.git"

# Step 1: Mirror the site into a temp folder
TEMP_DIR="./_site_tmp"

rm -rf "$TEMP_DIR"
wget \
  --mirror \
  --convert-links \
  --adjust-extension \
  --page-requisites \
  --no-parent \
  --domains=grainvita.local \
  --restrict-file-names=windows \
  -P "$TEMP_DIR" \
  "$SITE_URL"

# Step 2: Copy mirrored content (inside grainvita.local/) into current directory
cp -r "$TEMP_DIR"/grainvita.local/* ./
rm -rf "$TEMP_DIR"

# Step 3: Ensure .gitignore excludes this script
echo "deploy-grainvita.sh" >> .gitignore

# Step 4: Initialize Git if needed
if [ ! -d ".git" ]; then
  git init
  git remote add origin "$GIT_REPO"
fi

# Step 5: Commit and push to master branch
git add .
git commit -m "Update mirror site"
git branch -M master
git push -u origin master --force

echo "✅ Site mirrored (without cropvital.local folder) and pushed to GitHub (master branch): $GIT_REPO"

