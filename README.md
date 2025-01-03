## RedirectHunter
**RedirectHunter** is a tool designed to discover and test open redirect vulnerabilities across subdomains of a given domain. It performs the following tasks:

- **Subdomain Discovery**: Finds subdomains of a target domain using popular tools like ```assetfinder``` and ```subfinder```.
- **Live Subdomain Checking**: Verifies if discovered subdomains are live and accessible using ```httpx-toolkit```.
- **URL Crawling and Filtering**: Crawls discovered URLs using ```gau``` and filters out parameters that may be involved in open redirects (such as redirect_uri, next, url, prev, and others).
- **Open Redirect Testing**: Tests filtered URLs to check if they lead to external sites, potentially indicating open redirect vulnerabilities.

## Features
- Automated detection of open redirect parameters in URLs.
- High-speed crawling with multi-threading support.
- Simple and easy to use for security assessments and bug bounty hunters.

## Prerequisites
To use **RedirectHunter**, you'll need the following tools installed:

- ```assetfinder```
- ```subfinder```
- ```httpx-toolkit```
- ```gau```
- ```uro```
- ```curl```

## Installation

```
# Clone the repository
git clone https://github.com/anhedoniczz/RedirectHunter.git

# Navigate into the directory
cd RedirectHunter

# Run the script
./redirecthunter.sh -u <domain>
```

## Usage
To start using **RedirectHunter**, simply provide a domain to scan:

```
./redirecthunter.sh -u example.com
```
This will:
- Discover subdomains of ```example.com```.
- Check for live subdomains.
- Crawl the URLs and filter for potential open redirect parameters.
- Test for open redirect vulnerabilities.

## Contributing
Feel free to fork the repository and submit pull requests. Contributions are welcome!
