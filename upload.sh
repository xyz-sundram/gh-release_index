#!/bin/bash

# Authenticate with GitHub
gh auth login

# Get the ZIP filename
filename=$(ls *.zip)

# Extract version from filename
version=${filename%.zip}

# Create a Git tag and push it
git tag -a "$version" -m "Release $version"
git push origin "$version"

# Create a GitHub release
gh release create "$version" "$filename" -t "Release $version" -n "Release notes"

# Compute file size and MD5 hash
size=$(stat -c%s "$filename")
md5=$(md5sum "$filename" | awk '{ print $1 }')

# Get current date
date=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Define directory (modify as needed)
dir="/"

# Construct download URL
download_url="https://github.com/your-username/your-repo/releases/download/$version/$filename"

# Update JSON file
# Ensure you have a releases.json file initialized as an empty array: []
jq --arg name "$filename" \
   --arg date "$date" \
   --arg size "$size" \
   --arg md5 "$md5" \
   --arg dir "$dir" \
   --arg url "$download_url" \
   '. += [{"name": $name, "date": $date, "size": $size, "md5": $md5, "dir": $dir, "url": $url}]' releases.json > tmp.json && mv tmp.json releases.json
