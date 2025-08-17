#!/bin/bash

# Website URL
SITE_URL="http://cropvital.local/"

# GitHub Repo
GIT_REPO="https://github.com/usmansaif/cropvital-web.git"

# Step 1: Mirror the site into current directory
wget \
  --mirror \
  --convert-links \
  --adjust-extension \
  --page-requisites \
  --no-parent \
  -P ./ \
  "$SITE_URL"

# Step 2: Initialize Git (if not already)
if [ ! -d ".git" ]; then
  git init
  git remote add origin "$GIT_REPO"
fi

# Step 3: Add and commit changes
git add .
git commit -m "Update site mirror from $SITE_URL"

# Step 4: Push to GitHub (main branch)
git branch -M main
git push -u origin main --force

echo "✅ Site mirrored and pushed to GitHub: $GIT_REPO"

