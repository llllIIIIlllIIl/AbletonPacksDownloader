#!/bin/bash

# Function to download from URL if it doesn't exist
download_url() {
    local url="$1"
    local target_dir="$2"
    local filename=$(basename "$url")
    
    # Create target directory if it doesn't exist
    mkdir -p "$target_dir"
    
    # Check if the file already exists
    if [[ ! -e "$target_dir/$filename" ]]; then
        if [[ -f ./cookies.txt ]]; then
            wget --load-cookies ./cookies.txt --content-disposition -nc "$url" -P "$target_dir"
        else
            wget -nc "$url" -P "$target_dir"
        fi
    else
        echo "Skipping $filename. File already exists."
    fi
}

# Function to remove duplicate URLs based on filename (compatible with older bash)
remove_duplicate_files() {
    local input_file="$1"
    local temp_file="temp_unique_urls.txt"
    local seen_file="temp_seen_files.txt"
    
    > "$temp_file"  # Clear temp file
    > "$seen_file"  # Clear seen files tracking
    
    while IFS= read -r url; do
        [[ -z "$url" ]] && continue
        
        filename=$(basename "$url")
        
        # Check if we've seen this filename before
        if ! grep -Fxq "$filename" "$seen_file" 2>/dev/null; then
            echo "$filename" >> "$seen_file"
            echo "$url" >> "$temp_file"
        else
            echo "Removing duplicate: $url (duplicate filename: $filename)"
        fi
    done < "$input_file"
    
    # Replace original file with deduplicated version
    mv "$temp_file" "$input_file"
    rm -f "$seen_file"
}

# Function to capitalize first letter (compatible with older bash)
capitalize_first() {
    local word="$1"
    echo "$(echo ${word:0:1} | tr '[:lower:]' '[:upper:]')${word:1}"
}

# Function to generate Ableton download link
download_ableton() {
    clear
    echo -e "🎵 BONUS: Ableton Live Download Generator 🎵\n"
    
    # Operating System Selection
    echo "Select Operating System:"
    echo "  1 - Mac (DMG)"
    echo "  2 - Windows (ZIP)"
    echo ""
    read -p "Select OS (1-2): " os_choice
    
    case $os_choice in
        1) os_type="mac" ;;
        2) os_type="windows" ;;
        *) echo "Invalid choice"; sleep 2; return ;;
    esac
    
    # Edition Selection
    echo -e "\nAvailable editions:"
    echo "  1 - Suite"
    echo "  2 - Standard" 
    echo "  3 - Intro"
    echo "  4 - Lite"
    echo "  5 - Trial"
    echo ""
    read -p "Select edition (1-5): " edition_choice
    
    case $edition_choice in
        1) edition="suite"; edition_display="Suite" ;;
        2) edition="standard"; edition_display="Standard" ;;
        3) edition="intro"; edition_display="Intro" ;;
        4) edition="lite"; edition_display="Lite" ;;
        5) edition="trial"; edition_display="Trial" ;;
        *) echo "Invalid choice"; sleep 2; return ;;
    esac
    
    read -p "Enter version number (e.g., 12.1.1): " version
    
    if [[ -z "$version" ]]; then
        echo "Please enter a valid version number."
        sleep 2
        return
    fi
    
    # Parse version to determine architecture and file extension
    IFS='.' read -ra version_parts <<< "$version"
    major=${version_parts[0]}
    minor=${version_parts[1]:-0}
    
    if [[ "$os_type" == "mac" ]]; then
        # Mac DMG files
        architecture="64"  # Default for older versions
        file_extension="dmg"
        os_display="macOS"
        
        # If version is 11.1 or later, use "universal"
        if [[ $major -gt 11 ]] || [[ $major -eq 11 && $minor -ge 1 ]]; then
            architecture="universal"
        fi
    else
        # Windows ZIP files
        architecture="64"  # Windows always uses 64-bit
        file_extension="zip"
        os_display="Windows"
    fi
    
    # Construct the download URL
    download_url="https://cdn-downloads.ableton.com/channels/${version}/ableton_live_${edition}_${version}_${architecture}.${file_extension}"
    
    echo ""
    echo "Generated download link:"
    echo "$download_url"
    echo ""
    echo "File details:"
    echo "- OS: $os_display"
    echo "- Edition: $edition_display"
    echo "- Version: $version"
    echo "- Architecture: $architecture"
    echo "- File type: $(echo $file_extension | tr '[:lower:]' '[:upper:]')"
    echo ""
    
    read -p "Download now? (y/n): " download_choice
    
    if [[ "$download_choice" == "y" || "$download_choice" == "Y" ]]; then
        echo "Downloading Ableton Live $edition_display $version for $os_display..."
        wget "$download_url" -P "./downloads/"
        if [[ $? -eq 0 ]]; then
            echo "Download completed successfully!"
        else
            echo "Download failed. Please check the URL or your internet connection."
        fi
    else
        echo "Download link saved for manual use."
    fi
    
    sleep 2
    read -n 1 -s -r -p "Press any key to continue..."
}

while [ 1 ]
do
    clear
    echo -e "AbletonPacksDownloader: \n"
    echo "  Select an option by typing a number"
    echo "      1 - Remove down URLs from CDN URLs file"
    echo "      2 - View URLs files content"
    echo "      3 - Download every Ableton packs from CDN URLs"
    echo "      4 - Fetch and update Ableton URLs from account"
    echo "      5 - Do everything automatically (fetch URLs then download)"
    echo ""
    echo "  🎵 BONUS:"
    echo "      9 - Download Ableton Live (any version/edition/OS)"
    echo ""
    echo "      0 - Exit"
    echo ""
    read -p "Enter your choice: " choice
    case $choice in
      1)    echo -e "\nWorking...\n"
            if [[ ! -f ableton-cdn-urls.txt ]]; then
                echo "ableton-cdn-urls.txt not found!"
                sleep 2s
                read -n 1 -s -p "Press any key to continue..."
                continue
            fi
            
            echo "Removing duplicate files..."
            urls_before=$(wc -l < ableton-cdn-urls.txt)
            remove_duplicate_files ableton-cdn-urls.txt
            urls_after=$(wc -l < ableton-cdn-urls.txt)
            echo "Removed $((urls_before - urls_after)) duplicate files"
            
            echo "Checking URL availability..."
            total_urls=$(wc -l < ableton-cdn-urls.txt)
            current=0
            
            > tempurllist.txt  # Clear temp file
            while IFS= read -r url; do
                [[ -z "$url" ]] && continue
                current=$((current + 1))
                echo -ne "\rProgress: $current/$total_urls URLs checked"
                wget --spider -nv "$url" >> tempurllist.txt 2>&1
            done < ableton-cdn-urls.txt
            echo ""  # New line after progress
            
            cat tempurllist.txt | grep "OK" | grep -Eo "(http|https)://[a-zA-Z0-9./?=_%:-]*" | sort -u > temp_working_urls.txt
            rm ./tempurllist.txt
            
            working_urls=$(wc -l < temp_working_urls.txt)
            mv temp_working_urls.txt ableton-cdn-urls.txt
            
            echo -e "Done! CDN URLs list updated with $working_urls working URLs.\n"
            sleep 2s
            read -n 1 -s -p "Press any key to continue..."
            ;;
      2)    echo ""
            if [[ -f ableton-cdn-urls.txt ]]; then
                echo "Content of ableton-cdn-urls.txt ($(wc -l < ableton-cdn-urls.txt) URLs):"
                echo "======================================================="
                cat ableton-cdn-urls.txt
                echo ""
                echo "-------------------------------------------------------"
            else
                echo "ableton-cdn-urls.txt not found"
            fi
            
            if [[ -f ableton-packs-URL-list.txt ]]; then
                echo "Content of ableton-packs-URL-list.txt ($(wc -l < ableton-packs-URL-list.txt) URLs):"
                echo "======================================================="
                cat ableton-packs-URL-list.txt
            else
                echo "ableton-packs-URL-list.txt not found"
            fi
            echo ""
            read -n 1 -s -r -p "Press any key to continue..."
            ;;
      3)    echo -e "\nDownloading from ableton-cdn-urls.txt...\n"
            if [[ ! -f ableton-cdn-urls.txt ]]; then
                echo "ableton-cdn-urls.txt not found! Please run option 4 first to fetch URLs."
                sleep 2s
                read -n 1 -s -r -p "Press any key to continue..."
                continue
            fi
            while IFS= read -r url; do
                [[ -n "$url" ]] && download_url "$url" "./downloads"
            done < ableton-cdn-urls.txt
            echo -e "\nDone downloading!\n"
            sleep 1s
            read -n 1 -s -r -p "Press any key to continue..."
            ;;
      4)    echo -e "\nFetching URLs from Ableton account...\n"
            if [[ ! -f ./cookies.txt ]]; then
                echo "ERROR: cookies.txt not found!"
                echo ""
                echo "To get cookies.txt:"
                echo "1. Install 'cookies.txt' extension on Firefox"
                echo "2. Go to https://www.ableton.com/en/account/ and log in"
                echo "3. Click the cookies.txt extension icon"
                echo "4. Save the cookies.txt file in this script's directory"
                echo ""
                sleep 3s
                read -n 1 -s -r -p "Press any key to continue..."
                continue
            fi
            
            # Fetch CDN URLs only
            echo "Fetching CDN URLs..."
            curl -s -b ./cookies.txt https://www.ableton.com/en/account/ | grep -oE 'https://cdn[0-9]*-downloads\.ableton\.com/[^"]+' | sort > ableton-cdn-urls.txt
            
            # Fetch pack URLs only
            echo "Fetching pack URLs..."
            curl -s -b ./cookies.txt https://www.ableton.com/en/account/ | grep -oE '/en/packs/[^/]+/download/[^/]+/' | awk '{print "https://ableton.com"$0}' | sort > ableton-packs-URL-list.txt
            
            echo "Removing duplicate files from CDN URLs..."
            cdn_urls_before=$(wc -l < ableton-cdn-urls.txt)
            remove_duplicate_files ableton-cdn-urls.txt
            cdn_urls_after=$(wc -l < ableton-cdn-urls.txt)
            
            echo "CDN URLs: Found $cdn_urls_before, removed $((cdn_urls_before - cdn_urls_after)) duplicates"
            echo "Pack URLs: Found $(wc -l < ableton-packs-URL-list.txt) pack download URLs"
            echo ""
            echo "Files created:"
            echo "- ableton-cdn-urls.txt: $cdn_urls_after unique CDN download links"
            echo "- ableton-packs-URL-list.txt: $(wc -l < ableton-packs-URL-list.txt) pack download URLs"
            echo -e "\nDone fetching URLs!\n"
            sleep 3s
            read -n 1 -s -r -p "Press any key to continue..."
            ;;
      5)    echo -e "\nStarting full automated process...\n"
            
            # Step 1: Check for cookies.txt with option to continue without it
            has_cookie=true
            if [[ ! -f ./cookies.txt ]]; then
                echo "WARNING: cookies.txt not found!"
                echo ""
                echo "To get cookies.txt:"
                echo "1. Install 'cookies.txt' extension on Firefox"
                echo "2. Go to https://www.ableton.com/en/account/ and log in"
                echo "3. Click the cookies.txt extension icon"
                echo "4. Save the cookies.txt file in this script's directory"
                echo ""
                echo "Without cookies.txt, this script cannot fetch new URLs from your account."
                echo "However, it can still work with existing ableton-cdn-urls.txt file."
                echo ""
                read -p "Continue anyway? [Y/n]: " continue_choice
                
                if [[ "$continue_choice" == "n" || "$continue_choice" == "N" ]]; then
                    echo "Operation cancelled."
                    sleep 2s
                    read -n 1 -s -r -p "Press any key to continue..."
                    continue
                fi
                has_cookie=false
            fi
            
            if [[ "$has_cookie" == "true" ]]; then
                # Step 2: Fetch URLs (only if we have cookie)
                echo "Step 1/4: Fetching URLs from Ableton account..."
                curl -s -b ./cookies.txt https://www.ableton.com/en/account/ | grep -oE 'https://cdn[0-9]*-downloads\.ableton\.com/[^"]+' | sort > ableton-cdn-urls.txt
                curl -s -b ./cookies.txt https://www.ableton.com/en/account/ | grep -oE '/en/packs/[^/]+/download/[^/]+/' | awk '{print "https://ableton.com"$0}' | sort > ableton-packs-URL-list.txt
                echo "Found $(wc -l < ableton-cdn-urls.txt) CDN URLs and $(wc -l < ableton-packs-URL-list.txt) pack URLs"
                
                # Step 3: Remove duplicate files from CDN URLs
                echo "Step 2/4: Removing duplicate files from CDN URLs..."
                cdn_urls_before=$(wc -l < ableton-cdn-urls.txt)
                remove_duplicate_files ableton-cdn-urls.txt
                cdn_urls_after=$(wc -l < ableton-cdn-urls.txt)
                echo "Removed $((cdn_urls_before - cdn_urls_after)) duplicate files"
                
                current_step=3
            else
                # Skip URL fetching, check if file exists
                if [[ ! -f ableton-cdn-urls.txt ]]; then
                    echo ""
                    echo "ERROR: No ableton-cdn-urls.txt file found!"
                    echo ""
                    echo "To proceed, you need either:"
                    echo "1. A cookies.txt file to fetch URLs from your account, OR"
                    echo "2. An existing ableton-cdn-urls.txt file with download URLs"
                    echo ""
                    echo "You can:"
                    echo "- Get cookies.txt following the instructions above, OR"
                    echo "- Ask someone to share their ableton-cdn-urls.txt file with you"
                    echo ""
                    sleep 5s
                    read -n 1 -s -r -p "Press any key to continue..."
                    continue
                fi
                echo "Step 1/3: Using existing ableton-cdn-urls.txt file ($(wc -l < ableton-cdn-urls.txt) URLs)..."
                current_step=2
            fi
            
            # Check for dead URLs with progress
            echo "Step $current_step/$([ "$has_cookie" == "true" ] && echo "4" || echo "3"): Checking for dead CDN URLs..."
            total_urls=$(wc -l < ableton-cdn-urls.txt)
            current=0
            
            > tempurllist.txt  # Clear temp file
            while IFS= read -r url; do
                [[ -z "$url" ]] && continue
                current=$((current + 1))
                echo -ne "\rProgress: $current/$total_urls URLs checked"
                wget --spider -nv "$url" >> tempurllist.txt 2>&1
            done < ableton-cdn-urls.txt
            echo ""  # New line after progress
            
            cat tempurllist.txt | grep "OK" | grep -Eo "(http|https)://[a-zA-Z0-9./?=_%:-]*" | sort -u > temp_working_urls.txt
            rm ./tempurllist.txt
            working_urls=$(wc -l < temp_working_urls.txt)
            mv temp_working_urls.txt ableton-cdn-urls.txt
            echo "$working_urls working CDN URLs remaining"
            
            # Download everything
            current_step=$((current_step + 1))
            echo "Step $current_step/$([ "$has_cookie" == "true" ] && echo "4" || echo "3"): Downloading all files from CDN URLs..."
            while IFS= read -r url; do
                [[ -n "$url" ]] && download_url "$url" "./downloads"
            done < ableton-cdn-urls.txt
            
            echo -e "\nComplete! All CDN files downloaded to ./downloads/\n"
            if [[ "$has_cookie" == "true" ]]; then
                echo "Note: Pack URLs are saved in ableton-packs-URL-list.txt for reference"
            else
                echo "Note: No new URLs were fetched (no cookies.txt). Used existing ableton-cdn-urls.txt file."
            fi
            sleep 2s
            read -n 1 -s -r -p "Press any key to continue..."
            ;;
      9)    download_ableton
            ;;
      0)    echo -e "\nUser requested exit\n"
            exit 0
            ;;
      *)    echo "This is not a possible choice"
            sleep 1s
            ;;
    esac
done
