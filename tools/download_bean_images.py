import os
import re
import json
import urllib.request
import urllib.parse

HEADERS = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8',
    'Accept-Language': 'id-ID,id;q=0.9,en-US;q=0.8,en;q=0.7',
}

def search_bing_images(query):
    encoded = urllib.parse.quote(query)
    url = f"https://www.bing.com/images/search?q={encoded}&first=1&scenario=ImageBasicHover"
    req = urllib.request.Request(url, headers=HEADERS)
    try:
        with urllib.request.urlopen(req, timeout=12) as response:
            html = response.read().decode('utf-8', errors='ignore')
            # Extract murl
            matches = re.findall(r'murl&quot;:&quot;(https://[^&]+)&quot;', html)
            for m in matches:
                # prefer tokopedia, shopee, or direct image hostings
                if any(k in m for k in ['tokopedia', 'shopee', 'bp.blogspot', 'susercontent', 'shopify', 'roasters', 'coffee']):
                    return m
            if matches:
                return matches[0]
    except Exception as e:
        print(f"Error {query}: {e}")
    return None

def download_file(url, out_path):
    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    try:
        req = urllib.request.Request(url, headers=HEADERS)
        with urllib.request.urlopen(req, timeout=15) as resp:
            data = resp.read()
            if len(data) > 3000: # at least 3KB
                with open(out_path, 'wb') as f:
                    f.write(data)
                print(f"[OK] {os.path.basename(out_path)} ({len(data)} bytes) from {url[:60]}...")
                return True
            else:
                print(f"[SKIP] Data too small ({len(data)} bytes) for {out_path}")
    except Exception as e:
        print(f"[FAIL] {out_path}: {e}")
    return False

# Target items from user's image & top roasteries
TARGETS = [
    # MKND Coffee Roastery (Shown in screenshot)
    ("mknd_bali_kintamani.jpg", "MKND Coffee Roastery Bali Kintamani 100g tokopedia"),
    ("mknd_kopi_excelsa.jpg", "MKND Coffee Roastery Kopi Excelsa 100g tokopedia"),
    ("mknd_aceh_gayo.jpg", "MKND Coffee Roastery Aceh Arabica Gayo 100g tokopedia"),
    ("mknd_toraja_sapan.jpg", "MKND Coffee Roastery Toraja Arabica 100g tokopedia"),
    ("mknd_logo.png", "MKND Coffee Roastery logo tokopedia"),

    # Fugol Coffee Roasters (Shown in screenshot)
    ("fugol_sample_c.jpg", "Sample Biji Kopi Filter Roast C Fugol Coffee tokopedia"),
    ("fugol_sample_a.jpg", "Sample Biji Kopi Filter Roast A Fugol Coffee tokopedia"),
    ("fugol_sample_b.jpg", "Sample Biji Kopi Filter Roast B Fugol Coffee tokopedia"),
    ("fugol_kamojang_classico.jpg", "Fugol Coffee Kamojang Classico Natural"),
    ("fugol_logo.png", "Fugol Coffee Roasters logo"),

    # Mahugi Coffee (Shown in screenshot)
    ("mahugi_ijen_carbonic.jpg", "Mahugi Coffee COE Series Ijen Carbonic Maceration tokopedia"),
    ("mahugi_rancabali_patuha.jpg", "Mahugi Coffee Rancabali Patuha Ennave tokopedia"),
    ("mahugi_logo.png", "Mahugi Coffee Official Store logo"),

    # Space Roastery
    ("space_halu_pink_banana.jpg", "Space Roastery Halu Pink Banana tokopedia"),
    ("space_tolu_batak.jpg", "Space Roastery Tolu Batak kemasan tokopedia"),
    ("space_logo.png", "Space Roastery Yogyakarta logo"),

    # Tanamera Coffee
    ("tanamera_aceh_gayo.jpg", "Tanamera Coffee Aceh Gayo Natural kemasan"),
    ("tanamera_rasuna.jpg", "Tanamera Coffee Rasuna Washed kemasan"),
    ("tanamera_logo.png", "Tanamera Coffee logo official"),

    # Smoking Barrels
    ("smoking_barrels_kerinci.jpg", "Smoking Barrels Kerinci Honey kemasan"),
    ("smoking_barrels_logo.png", "Smoking Barrels Craft Coffee logo"),

    # Common Grounds
    ("common_grounds_guji.jpg", "Common Grounds Coffee Roasters Guji Hambela kemasan"),
    ("common_grounds_logo.png", "Common Grounds Coffee Roasters logo"),

    # Two Hands Full
    ("two_hands_full_kamojang.jpg", "Two Hands Full Bandung coffee beans kemasan"),
    ("two_hands_full_logo.png", "Two Hands Full Coffee logo"),

    # Anomali Coffee
    ("anomali_toraja.jpg", "Anomali Coffee Toraja Sapan kemasan"),
    ("anomali_logo.png", "Anomali Coffee logo"),

    # Gordi Coffee
    ("gordi_flores.jpg", "Gordi Coffee Roastery Flores Bajawa kemasan"),
    ("gordi_logo.png", "Gordi Coffee logo"),
]

if __name__ == '__main__':
    base_dir = r"coffe-labs-mobile\assets\images"
    for filename, query in TARGETS:
        folder = "roasteries" if "logo" in filename else "beans"
        target_path = os.path.join(base_dir, folder, filename)
        if os.path.exists(target_path) and os.path.getsize(target_path) > 3000:
            print(f"[EXISTS] {filename}")
            continue
        print(f"Searching for: {query}...")
        url = search_bing_images(query)
        if url:
            success = download_file(url, target_path)
            if not success:
                print(f"Retrying generic query for {filename}...")
                fallback_url = search_bing_images(query.replace("tokopedia", "").replace("kemasan", ""))
                if fallback_url:
                    download_file(fallback_url, target_path)
        else:
            print(f"No image found for {query}")
