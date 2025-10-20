#!/bin/bash

# Local site URL
LOCAL_URL="https://grainvita.com"

# Live site URL (for sitemap)
LIVE_URL="https://grainvita.com"

# Temporary files
URLS_FILE="urls.txt"
UNIQUE_URLS_FILE="urls_unique.txt"
SITEMAP_FILE="sitemap.xml"

# Step 1: Crawl site and list all URLs
echo "🔹 Crawling $LOCAL_URL to list URLs..."
wget --mirror --spider --no-verbose --output-file="$URLS_FILE" "$LOCAL_URL"

# Step 2: Extract unique URLs
echo "🔹 Extracting unique URLs..."
grep -Eo "$LOCAL_URL[^ ]+" "$URLS_FILE" | sort | uniq > "$UNIQUE_URLS_FILE"

# Step 3: Generate sitemap.xml
echo "🔹 Generating sitemap.xml..."
echo '<?xml version="1.0" encoding="UTF-8"?>' > "$SITEMAP_FILE"
echo '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">' >> "$SITEMAP_FILE"

while read url; do
    echo "  <url>" >> "$SITEMAP_FILE"
    echo "    <loc>${url/$LOCAL_URL/$LIVE_URL}</loc>" >> "$SITEMAP_FILE"
    echo "    <changefreq>weekly</changefreq>" >> "$SITEMAP_FILE"
    echo "    <priority>0.8</priority>" >> "$SITEMAP_FILE"
    echo "  </url>" >> "$SITEMAP_FILE"
done < "$UNIQUE_URLS_FILE"

echo '</urlset>' >> "$SITEMAP_FILE"

# Step 4: Clean up temporary files
rm "$URLS_FILE" "$UNIQUE_URLS_FILE"

echo "✅ sitemap.xml generated successfully!"
