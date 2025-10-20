#!/bin/bash

# Local dev site URL
LOCAL_SITE="http://grainvita.local"

# Live site URL
LIVE_SITE="https://grainvita.com"

# GitHub Repo
GIT_REPO="https://github.com/usmansaif/grainvita-web.git"

# Temp directory for mirrored site
TEMP_DIR="./_site_tmp"

# Remove previous temp folder
rm -rf "$TEMP_DIR"

# Step 1: Mirror the local site
wget \
  --mirror \
  --convert-links \
  --adjust-extension \
  --page-requisites \
  --no-parent \
  --domains=grainvita.local \
  --restrict-file-names=windows \
  -P "$TEMP_DIR" \
  "$LOCAL_SITE"

# Step 2: Copy mirrored content into current directory
cp -r "$TEMP_DIR"/grainvita.local/* ./
rm -rf "$TEMP_DIR"

# Step 3: Replace all local URLs with live site URL
find . -type f \( -name "*.html" -o -name "*.css" -o -name "*.js" \) | while read file; do
    sed -i "s|http://grainvita.local|$LIVE_SITE|g" "$file"
done

# Step 4: Ensure .gitignore excludes this script
grep -qxF "deploy-grainvita.sh" .gitignore || echo "deploy-grainvita.sh" >> .gitignore

# Step 5: Initialize Git if needed
if [ ! -d ".git" ]; then
  git init
  git remote add origin "$GIT_REPO"
fi

# Step 6: Commit and push (uncomment when ready)
# git add .
# git commit -m "Mirror local site and replace URLs"
# git branch -M master
# git push -u origin master --force

echo "✅ Site mirrored from grainvita.local and URLs replaced with grainvita.com"

