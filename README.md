
# AbletonPacksDownloader

A comprehensive Bash script for downloading Ableton Live packs and software from your Ableton account. This tool automates the process of fetching, organizing, and downloading your purchased Ableton content.

## 🎵 Features

### Core Functionality
- **Automatic URL fetching** from your Ableton account using cookies
- **Smart duplicate removal** based on filename analysis
- **Dead link detection** with progress feedback
- **Batch downloading** with resume support
- **File organization** with automatic directory creation

### Bonus Features
- **Direct Ableton Live downloads** for any version/edition/OS
- **Cross-platform support** (Mac DMG and Windows ZIP)
- **Architecture detection** (64-bit vs Universal for Mac)

## 📋 Prerequisites

### System Requirements
- **Bash shell** (compatible with Bash 3.0+)
- **wget** - for downloading files
- **curl** - for fetching URLs from web pages
- **Internet connection**

### Account Requirements
- Valid Ableton account with purchased packs
- Firefox browser with cookies.txt extension (for account access)

## 🚀 Quick Start

### 1. Download the Script
```
# Download and make executable
chmod +x ableton-packs-downloader.sh
```

### 2. Get Your Cookies (Required for account access)
1. Install the **cookies.txt** extension for Firefox
2. Navigate to [https://www.ableton.com/en/account/](https://www.ableton.com/en/account/)
3. Log in to your Ableton account
4. Click the cookies.txt extension icon
5. Save the `cookies.txt` file in the same directory as the script

### 3. Run the Script
```
./ableton-packs-downloader.sh
```

## 📖 Usage Guide

### Main Menu Options

```
AbletonPacksDownloader:

  Select an option by typing a number
      1 - Remove down URLs from CDN URLs file
      2 - View URLs files content
      3 - Download every Ableton packs from CDN URLs
      4 - Fetch and update Ableton URLs from account
      5 - Do everything automatically (fetch URLs then download)

  🎵 BONUS:
      9 - Download Ableton Live (any version/edition/OS)

      0 - Exit
```

### Option Details

#### Option 1: Clean URL List
- **Purpose**: Remove dead/broken links from your URL list
- **Process**:
  - Removes duplicate files based on filename
  - Tests each URL for availability with progress feedback
  - Updates the list with only working URLs
- **Requirements**: Existing `ableton-cdn-urls.txt` file

#### Option 2: View URL Files
- **Purpose**: Display contents of URL files
- **Shows**:
  - `ableton-cdn-urls.txt` - Direct CDN download links
  - `ableton-packs-URL-list.txt` - Pack download page URLs
  - File count for each list

#### Option 3: Download Packs
- **Purpose**: Download all files from CDN URL list
- **Features**:
  - Skips existing files automatically
  - Uses cookies for authenticated downloads
  - Creates organized directory structure
- **Requirements**: `ableton-cdn-urls.txt` file

#### Option 4: Fetch URLs from Account
- **Purpose**: Get fresh download URLs from your Ableton account
- **Process**:
  - Connects to your account using cookies
  - Extracts CDN download links
  - Extracts pack page URLs
  - Removes duplicates automatically
- **Requirements**: Valid `cookies.txt` file
- **Output**: Creates/updates URL list files

#### Option 5: Full Automation ⭐ (Recommended)
- **Purpose**: Complete hands-off downloading experience
- **Process**:
  1. **URL Fetching**: Gets URLs from your account (if cookie available)
  2. **Duplicate Removal**: Cleans up duplicate files
  3. **Link Validation**: Removes dead URLs with progress tracking
  4. **Batch Download**: Downloads all valid content

**Special Features**:
- **Cookie-less mode**: Can work with existing URL files if no cookie available
- **Intelligent error handling**: Provides clear guidance when files are missing
- **Progress feedback**: Shows real-time progress during URL validation

#### Option 9: Ableton Live Download 🎵 (Bonus)
- **Purpose**: Download any version of Ableton Live
- **Supported Versions**: All versions from legacy to latest
- **Supported Editions**: Suite, Standard, Intro, Lite, Trial
- **Supported Platforms**: 
  - **Mac**: DMG files (64-bit for older versions, Universal for 11.1+)
  - **Windows**: ZIP files (64-bit)
- **Features**:
  - Automatic architecture detection
  - Version validation
  - Direct download with progress

## 📁 File Structure

```
project-directory/
├── ableton-packs-downloader.sh     # Main script
├── cookies.txt                      # Browser cookies (required)
├── ableton-cdn-urls.txt           # CDN download links
├── ableton-packs-URL-list.txt     # Pack page URLs
└── downloads/                     # Downloaded content
    ├── PackName1_r12345_v1.0.alp
    ├── PackName2_r67890_v2.1.alp
    └── ableton_live_suite_12.2.2_universal.dmg
```

## 🔧 Advanced Usage

### Working Without Cookies

If you don't have `cookies.txt`, you can still use the script with existing URL files:

1. **Get URL file from someone**: Ask another user to share their `ableton-cdn-urls.txt`
2. **Use Option 5**: Choose to continue when prompted about missing cookie
3. **Manual URL management**: Use Options 1-3 to work with existing URL lists

### URL File Formats

#### ableton-cdn-urls.txt
```
https://cdn-downloads.ableton.com/livepacks/ableton/pack-name/12.0/r12345/PackName_r12345_v1.0.alp
https://cdn2-downloads.ableton.com/livepacks/ableton/other-pack/11.0/r67890/OtherPack_r67890_v2.0.alp
```

#### ableton-packs-URL-list.txt  
```
https://ableton.com/en/packs/pack-name/download/1234567/
https://ableton.com/en/packs/other-pack/download/7890123/
```

### Custom Download Locations

The script automatically creates a `downloads` directory, but you can modify the script to change the download location by editing the `target_dir` parameter in the `download_url` function.

## 🛠️ Troubleshooting

### Common Issues

#### "cookies.txt not found" Error
**Cause**: Missing authentication cookies
**Solution**: Follow the cookie setup instructions in the Quick Start section

#### "ableton-cdn-urls.txt not found" Error  
**Cause**: No URL list available
**Solutions**:
- Run Option 4 to fetch URLs (requires cookies.txt)
- Get an existing URL file from another user
- Use Option 9 for direct Ableton Live downloads

#### Downloads Fail with 403/401 Errors
**Cause**: Invalid or expired cookies
**Solutions**:
- Refresh your cookies.txt file by re-logging into Ableton
- Ensure you're logged into the correct Ableton account
- Verify the packs are actually owned by your account

#### Slow URL Checking Process
**Cause**: Large number of URLs to validate
**Solutions**:
- **Normal behavior** - the script shows progress: "Progress: X/Y URLs checked"
- Process typically takes 1-3 seconds per URL
- Consider running during off-peak hours for better performance

#### "declare: -A: invalid option" Error
**Cause**: Very old Bash version (pre-4.0)
**Solution**: The current script is compatible with Bash 3.0+ - update if you encounter this error

### Debugging Tips

1. **Check file permissions**:
   ```
   ls -la ableton-packs-downloader.sh
   chmod +x ableton-packs-downloader.sh
   ```

2. **Verify cookie format**:
   ```
   head -n 5 cookies.txt
   # Should show Netscape cookie format
   ```

3. **Test wget functionality**:
   ```
   wget --version
   curl --version
   ```

4. **Monitor downloads**:
   ```
   # In another terminal
   watch -n 1 'ls -la downloads/ | tail -10'
   ```

## 🔒 Security & Privacy

### Data Handling
- **Cookies**: Stored locally, never transmitted except to Ableton servers
- **URLs**: Generated from your account, stored in plain text files
- **Downloads**: Saved locally in the downloads directory

### Best Practices
- **Keep cookies.txt secure**: Don't share this file as it contains your session data
- **Regular cookie refresh**: Update cookies periodically for security
- **Clean up**: Remove cookies.txt when no longer needed


## 📝 License

This script is provided as-is for educational and personal use. Users are responsible for complying with Ableton's Terms of Service and only downloading content they legally own.

