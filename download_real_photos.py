import os
import re
import urllib.request
import ssl
from duckduckgo_search import DDGS
import time

ssl._create_default_https_context = ssl._create_unverified_context
avatar_dir = "E:/APPS From Agent/Mobile-Flutter/Coffee Hub/coffee_hub_mobile/assets/images/avatars"
os.makedirs(avatar_dir, exist_ok=True)

filepath = "E:/APPS From Agent/Mobile-Flutter/Coffee Hub/coffee_hub_mobile/lib/services/seed_data.dart"
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

# Find all authors
authors = re.findall(r'"author": "([^"]+)"', content)

# Clean authors
clean_authors = []
emojis = [
      '🇳🇴', '🇬🇷', '🇨🇭', '🇯🇵', '🇬🇧', '🇷🇺', '🇹🇼', '🇮🇪', '🇨🇳', '🇰🇷',
      '🇺🇸', '🇨🇦', '🇦🇺', '🇸🇪', '🇨🇱', '🇫🇷', '🇵🇭', '🇩🇪', '🇷🇴', '🇭🇰',
      '🇲🇾', '🇸🇬', '🇦🇹', '🇦🇪', '🇨🇿', '🇮🇩'
]
for a in authors:
    clean = re.sub(r'\s*\([^)]*\)', '', a)
    for e in emojis:
        clean = clean.replace(e, '')
    clean = clean.strip()
    if clean not in clean_authors:
        clean_authors.append(clean)

print("Found brewers:", clean_authors)

def get_image_for_brewer(name):
    query = f'"{name}" coffee barista champion'
    print(f"Searching for: {query}")
    try:
        results = DDGS().images(
            keywords=query,
            region="wt-wt",
            safesearch="off",
            size="Medium",
            type_image="photo",
            max_results=1,
        )
        if results:
            return results[0]['image']
    except Exception as e:
        print(f"Error searching DDG for {name}: {e}")
    return None

for name in clean_authors:
    safe_name = name.lower().replace(' ', '_')
    save_path = os.path.join(avatar_dir, f"{safe_name}.jpg")
    
    if os.path.exists(save_path):
        print(f"Already have {name}")
        continue
        
    img_url = get_image_for_brewer(name)
    if img_url:
        print(f"Downloading {name} from {img_url}")
        try:
            req = urllib.request.Request(img_url, headers={'User-Agent': 'Mozilla/5.0'})
            with urllib.request.urlopen(req, timeout=10) as response, open(save_path, 'wb') as out_file:
                out_file.write(response.read())
        except Exception as e:
            print(f"Failed to download {img_url}: {e}")
    else:
        print(f"No image found for {name}")
    time.sleep(1) # rate limit

# Update seed_data.dart
def replace_img(match):
    # match.group(0) is the whole match, but it's hard to track which author it belongs to.
    # We will do a full string replacement line by line.
    pass

lines = content.split('\n')
for i in range(len(lines)):
    if '"author":' in lines[i]:
        author_val = re.search(r'"author": "([^"]+)"', lines[i]).group(1)
        clean = re.sub(r'\s*\([^)]*\)', '', author_val)
        for e in emojis:
            clean = clean.replace(e, '')
        clean = clean.strip()
        safe_name = clean.lower().replace(' ', '_')
        
        # Look ahead for authorImageUrl
        for j in range(i+1, min(i+5, len(lines))):
            if '"authorImageUrl":' in lines[j]:
                lines[j] = re.sub(r'"authorImageUrl":\s*"[^"]+"', f'"authorImageUrl": "assets/images/avatars/{safe_name}.jpg"', lines[j])
                break

with open(filepath, 'w', encoding='utf-8') as f:
    f.write('\n'.join(lines))
    
print("Updated seed_data.dart with real photos mapping.")
