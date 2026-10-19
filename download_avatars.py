import urllib.request
import os
import ssl

ssl._create_default_https_context = ssl._create_unverified_context

avatar_dir = "E:/APPS From Agent/Mobile-Flutter/Coffee Hub/coffee_hub_mobile/assets/images/avatars"
os.makedirs(avatar_dir, exist_ok=True)

# Using a generic user agent
req_headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
}

for i in range(1, 11):
    url = f"https://i.pravatar.cc/150?img={i+10}"
    filepath = os.path.join(avatar_dir, f"avatar_{i}.jpg")
    try:
        req = urllib.request.Request(url, headers=req_headers)
        with urllib.request.urlopen(req) as response, open(filepath, 'wb') as out_file:
            data = response.read()
            out_file.write(data)
        print(f"Downloaded {filepath}")
    except Exception as e:
        print(f"Failed to download {url}: {e}")
