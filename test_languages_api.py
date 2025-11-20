#!/usr/bin/env python3
import os
import requests
from collections import defaultdict

username = "Andreas-Garcia"
token = "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it"

headers = {
    "Authorization": f"Bearer {token}",
    "Accept": "application/vnd.github.v3+json"
}

# Test token first
print("Testing token...")
test_response = requests.get("https://api.github.com/user", headers=headers)
if test_response.status_code == 200:
    user_data = test_response.json()
    print(f"✓ Token valid - Authenticated as: {user_data.get('login')}")
else:
    print(f"✗ Token invalid or expired (status: {test_response.status_code})")
    print(f"  Response: {test_response.text[:200]}")
    exit(1)
print()

# Fetch repository languages
languages_data = defaultdict(int)
processed_repos = set()  # Track repos we've already processed

# First, fetch repositories owned by the user
print("Fetching owned repositories...")
page = 1
per_page = 100
while True:
    repos_response = requests.get(
        f"https://api.github.com/users/{username}/repos?per_page={per_page}&page={page}&type=all",
        headers=headers
    )
    repos_response.raise_for_status()
    repos = repos_response.json()

    if not repos:
        break

    for repo in repos:
        if repo.get("fork"):
            continue
        
        repo_full_name = repo["full_name"]
        if repo_full_name in processed_repos:
            continue
        processed_repos.add(repo_full_name)
        
        lang_response = requests.get(
            repo["languages_url"],
            headers=headers
        )
        if lang_response.status_code == 200:
            repo_langs = lang_response.json()
            for lang, bytes_count in repo_langs.items():
                languages_data[lang] += bytes_count
            print(f"  Processed: {repo_full_name}")

    page += 1
    if len(repos) < per_page:
        break

# Also fetch repositories where user has contributed (using Search API)
print("\nFetching repositories with contributions...")
search_query = f"author:{username} type:pr"
search_headers = headers.copy()
search_headers["Accept"] = "application/vnd.github.v3+json"

page = 1
while True:
    search_response = requests.get(
        f"https://api.github.com/search/issues?q={search_query}&per_page={per_page}&page={page}",
        headers=search_headers
    )
    if search_response.status_code != 200:
        print(f"  Search API returned {search_response.status_code}, skipping contribution-based repos")
        break
        
    search_data = search_response.json()
    items = search_data.get("items", [])
    
    if not items:
        break
    
    for item in items:
        repo_url = item.get("repository_url", "")
        if not repo_url:
            continue
        
        # Extract repo full name from URL
        repo_full_name = repo_url.replace("https://api.github.com/repos/", "")
        if repo_full_name in processed_repos:
            continue
        
        # Skip if user owns this repo (already processed)
        if repo_full_name.startswith(f"{username}/"):
            continue
        
        processed_repos.add(repo_full_name)
        
        # Fetch language data for this repo
        lang_url = f"https://api.github.com/repos/{repo_full_name}/languages"
        lang_response = requests.get(lang_url, headers=headers)
        if lang_response.status_code == 200:
            repo_langs = lang_response.json()
            if repo_langs:  # Only count if repo has language data
                for lang, bytes_count in repo_langs.items():
                    languages_data[lang] += bytes_count
                print(f"  Processed (contribution): {repo_full_name}")
    
    page += 1
    if len(items) < per_page:
        break

# Check for specific repositories user might have contributed to
specific_repos = [
    "Bodzify/bodzify-ultimate-music-guide-react"
]

print("\nChecking specific repositories...")
for repo_full_name in specific_repos:
    if repo_full_name in processed_repos:
        print(f"  Already processed: {repo_full_name}")
        continue
    
    lang_url = f"https://api.github.com/repos/{repo_full_name}/languages"
    lang_response = requests.get(lang_url, headers=headers)
    if lang_response.status_code == 200:
        repo_langs = lang_response.json()
        if repo_langs:
            processed_repos.add(repo_full_name)
            for lang, bytes_count in repo_langs.items():
                languages_data[lang] += bytes_count
            print(f"  ✓ Processed (specific): {repo_full_name}")
            print(f"    Languages: {list(repo_langs.keys())}")
    else:
        print(f"  ✗ Cannot access {repo_full_name} (status: {lang_response.status_code})")
        if lang_response.status_code == 404:
            print(f"    Repository not found or not accessible")
        elif lang_response.status_code == 403:
            print(f"    Access forbidden - may need repo scope in token")

# Calculate percentages
total_bytes = sum(languages_data.values())
if total_bytes == 0:
    print("\n❌ No language data found")
else:
    languages_percentages = {
        lang: (bytes_count / total_bytes) * 100
        for lang, bytes_count in languages_data.items()
    }
    
    # Sort by percentage
    sorted_languages = sorted(
        languages_percentages.items(),
        key=lambda x: x[1],
        reverse=True
    )
    
    print(f"\n✅ Total repositories processed: {len(processed_repos)}")
    print(f"✅ Total bytes: {total_bytes:,}")
    print(f"\n📊 Language Statistics:")
    for lang, percentage in sorted_languages[:10]:
        bytes_count = languages_data[lang]
        print(f"  {lang:15s}: {percentage:6.2f}% ({bytes_count:,} bytes)")

