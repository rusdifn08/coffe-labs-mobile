import os
import subprocess
import time

avatar_dir = "E:/APPS From Agent/Mobile-Flutter/Coffee Hub/coffee_hub_mobile/assets/images/avatars"

brewers = [
    "Nas Jaafar", "Simon Gautherin", "Bavis Kwong", "Peng Jinyang", "Carlos Fernandez", "Ryan Wibawa",
    "Odd-Steinar Tøllefsen", "Konstantinos Iatridis", "Benjamin Prager", "Tetsu Kasuya",
    "Stefanos Domatiotis", "Emi Fukahori", "Berg Wu", "Matt Winton", "Carlos Escobar",
    "Martin Hudak", "Daiki Hatakeyama", "Anthony Douglas", "Cole Torode", "Patricio Rossi",
    "Boram Um", "Francois Putz", "Federico Pezzetta", "Du Jianing", "Regine Wai Yee Beng", 
    "Shih Yuan Hsu", "Elysia Tan", "Savina Giachgia", "Garam Victor Um", "Martin Wölfl", "Wataru Iidaka", "Bayu Prawiro", "Alessandro Galtieri", "Patrik Rolf", "Chad Wang"
]

for name in brewers:
    safe_name = name.lower().replace(' ', '_').replace('ö', 'o').replace('-', '_').replace('ø', 'o')
    
    # We will delete any existing .webp or .jpg for these missing ones (since Bing downloaded junk)
    p_jpg = os.path.join(avatar_dir, f"{safe_name}.jpg")
    p_webp = os.path.join(avatar_dir, f"{safe_name}.webp")
    if os.path.exists(p_jpg): os.remove(p_jpg)
    if os.path.exists(p_webp): os.remove(p_webp)
        
    print(f"Fetching youtube thumbnail for {name}...")
    query = f"ytsearch1:{name} world brewers cup performance"
    output_tmpl = os.path.join(avatar_dir, f"{safe_name}")
    
    cmd = [
        "yt-dlp",
        "--write-thumbnail",
        "--skip-download",
        "-o", output_tmpl,
        query
    ]
    
    try:
        subprocess.run(cmd, check=False)
    except Exception as e:
        print(f"Failed {name}: {e}")
        
    time.sleep(1)

print("Done downloading thumbnails!")
