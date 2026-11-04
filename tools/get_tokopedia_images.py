import urllib.request
import re
import os

HEADERS = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
}

urls = [
    ("fugol_sample_c.jpg", "https://www.tokopedia.com/fugolcoffee/sample-biji-kopi-arabika-filter-roast-c-20-gram-biji-kopi"),
    ("fugol_sample_a.jpg", "https://www.tokopedia.com/fugolcoffee/sample-biji-kopi-arabika-filter-roast-a-20-gram-biji-kopi"),
    ("fugol_sample_b.jpg", "https://www.tokopedia.com/fugolcoffee/sample-biji-kopi-arabika-filter-roast-b-20-gram-biji-kopi"),
]

for name, url in urls:
    try:
        req = urllib.request.Request(url, headers=HEADERS)
        html = urllib.request.urlopen(req, timeout=10).read().decode('utf-8', errors='ignore')
        # find images
        imgs = re.findall(r'(https://images\.tokopedia\.net/img/cache/[^\s"\'<>]+\.(?:jpg|jpeg|png))', html)
        print(f"URL: {url} -> found {len(imgs)} images")
        for img in imgs:
            if '700' in img or '500' in img or 'product' in img:
                print(f"Candidate: {img}")
    except Exception as e:
        print(f"Failed {url}: {e}")
