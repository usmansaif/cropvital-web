#!/bin/bash

# === Configuration ===
LOCAL_SITE="http://grainvita.local"
LIVE_SITE="https://grainvita.com"
GIT_REPO="https://github.com/usmansaif/grainvita-web.git"
TEMP_DIR="./_site_tmp"

# === Extra pages to include (unlinked or standalone) ===
EXTRA_PAGES=(
  "$LOCAL_SITE/thanks"
)

# === Step 1: Remove previous temp folder ===
rm -rf "$TEMP_DIR"

# === Step 2: Mirror the local site and extra pages ===
wget \
  --mirror \
  --convert-links \
  --adjust-extension \
  --page-requisites \
  --no-parent \
  --recursive \
  --level=inf \
  --domains=grainvita.local \
  --restrict-file-names=windows \
  -P "$TEMP_DIR" \
  "$LOCAL_SITE" \
  "${EXTRA_PAGES[@]}"

# === Step 3: Copy mirrored content into current directory ===
cp -r "$TEMP_DIR"/grainvita.local/* ./
rm -rf "$TEMP_DIR"

# === Step 4: Replace all local URLs with live site URL ===
find . -type f \( -name "*.html" -o -name "*.css" -o -name "*.js" \) | while read file; do
    sed -i "s|$LOCAL_SITE|$LIVE_SITE|g" "$file"
done

# === Step 5: Ensure .gitignore excludes this script ===
grep -qxF "deploy-grainvita.sh" .gitignore || echo "deploy-grainvita.sh" >> .gitignore

# === Step 6: Initialize Git if needed ===
if [ ! -d ".git" ]; then
  git init
  git remote add origin "$GIT_REPO"
fi

# === Step 7: Commit and push (optional) ===
# git add .
# git commit -m "Mirror local site and replace URLs"
# git branch -M master
# git push -u origin master --force

echo "✅ Site mirrored from grainvita.local and URLs replaced with grainvita.com"
echo "   Included extra pages: ${EXTRA_PAGES[*]}"

