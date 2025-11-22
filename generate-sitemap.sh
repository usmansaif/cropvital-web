#!/bin/bash

# Local site URL
LOCAL_URL="http://grainvita.local"

# Live site URL (for sitemap)
LIVE_URL="https://grainvita.com"

# Temporary files
URLS_FILE="urls.txt"
UNIQUE_URLS_FILE="urls_unique.txt"
SITEMAP_FILE="sitemap.xml"

# Step 1: Crawl site and list all URLs
echo "🔹 Crawling $LOCAL_URL to list URLs..."
wget --mirror --spider --no-verbose --output-file="$URLS_FILE" "$LOCAL_URL"

# Step 2: Extract unique page URLs (exclude assets)
echo "🔹 Extracting unique URLs (excluding assets)..."
grep -Eo "$LOCAL_URL[^ ]+" "$URLS_FILE" | \
    sed 's/[:;,]$//' | \
    grep -Ev "\.(css|js|woff|woff2|ttf|eot|png|jpg|jpeg|gif|svg|ico|pdf|zip|webmanifest)$" | \
    sort | uniq > "$UNIQUE_URLS_FILE"

# Step 3: Generate sitemap.xml with dynamic images
echo "🔹 Generating sitemap.xml..."
echo '<?xml version="1.0" encoding="UTF-8"?>' > "$SITEMAP_FILE"
echo '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" xmlns:image="http://www.google.com/schemas/sitemap-image/1.1">' >> "$SITEMAP_FILE"

while read url; do
    echo "  <url>" >> "$SITEMAP_FILE"
    echo "    <loc>${url/$LOCAL_URL/$LIVE_URL}</loc>" >> "$SITEMAP_FILE"
    echo "    <changefreq>weekly</changefreq>" >> "$SITEMAP_FILE"
    echo "    <priority>0.8</priority>" >> "$SITEMAP_FILE"

    # Determine local path of page
    PAGE_PATH=$(echo "$url" | sed "s|$LOCAL_URL||")
    if [[ -z "$PAGE_PATH" || "$PAGE_PATH" == "/" ]]; then
        PAGE_PATH="/index.html"
    fi

    # Only proceed if page file exists
    if [[ -f "./public$PAGE_PATH" ]]; then
        # Extract <img> src attributes
        grep -Eo '<img [^>]*src=["'"'"'][^"'"'"']+["'"'"']' "./public$PAGE_PATH" | \
        sed -E 's/.*src=["'"'"']([^"'"'"']+)["'"'"'].*/\1/' | \
        grep -Ev "(favicon|icon|logo-small|sprite|background|bg-)" | \
        while read img; do
            # Make URL absolute if relative
            if [[ "$img" == /* ]]; then
                IMG_URL="$LIVE_URL$img"
            elif [[ "$img" == http* ]]; then
                IMG_URL="$img"
            else
                # relative to page directory
                DIR_PATH=$(dirname "$PAGE_PATH")
                IMG_URL="$LIVE_URL/$DIR_PATH/$img"
            fi
            echo "    <image:image>" >> "$SITEMAP_FILE"
            echo "      <image:loc>$IMG_URL</image:loc>" >> "$SITEMAP_FILE"
            echo "    </image:image>" >> "$SITEMAP_FILE"
        done
    fi

    echo "  </url>" >> "$SITEMAP_FILE"
done < "$UNIQUE_URLS_FILE"

echo '</urlset>' >> "$SITEMAP_FILE"

# Step 4: Clean up temporary files
rm "$URLS_FILE" "$UNIQUE_URLS_FILE"

echo "✅ sitemap.xml with dynamic image support generated successfully!"
