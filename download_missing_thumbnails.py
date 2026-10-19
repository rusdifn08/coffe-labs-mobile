import os
import subprocess
import time

avatar_dir = "E:/APPS From Agent/Mobile-Flutter/Coffee Hub/coffee_hub_mobile/assets/images/avatars"

brewers = [
    "Alessandro Galtieri", "Bayu Prawiro", "Benjamin Prager", "Carlos Escobar", "Chad Wang",
    "Daiki Hatakeyama", "Du Jianing", "Elysia Tan", "Garam Victor Um", "Martin Wölfl",
    "Matt Winton", "Patrik Rolf", "Regine Wai Yee Beng", "Savina Giachgia", "Shih Yuan Hsu",
    "Stathis Koremtas", "Wataru Iidaka"
]

fallback_size = 24764

for name in brewers:
    safe_name = name.lower().replace(' ', '_').replace('ö', 'o').replace('-', '_').replace('ø', 'o')
    
    # check if they have the fallback image
    p_jpg = os.path.join(avatar_dir, f"{safe_name}.jpg")
    p_webp = os.path.join(avatar_dir, f"{safe_name}.webp")
    
    if os.path.exists(p_jpg) and os.path.getsize(p_jpg) == fallback_size:
        os.remove(p_jpg)
    
    queries = [
        f"ytsearch1:{name} world brewers cup",
        f"ytsearch1:{name} brewers cup",
        f"ytsearch1:{name} coffee champion",
        f"ytsearch1:{name} barista"
    ]
    
    success = False
    output_tmpl = os.path.join(avatar_dir, f"{safe_name}")
    
    print(f"Fetching youtube thumbnail for {name}...")
    for query in queries:
        cmd = [
            "yt-dlp",
            "--write-thumbnail",
            "--skip-download",
            "-o", output_tmpl,
            query
        ]
        
        try:
            res = subprocess.run(cmd, check=False, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            # check if it actually created a .webp or .jpg
            if os.path.exists(f"{output_tmpl}.webp") or os.path.exists(f"{output_tmpl}.jpg"):
                print(f"Success with query: {query}")
                success = True
                break
        except Exception as e:
            pass
            
    if not success:
        print(f"Failed to find ANY thumbnail for {name}")
        
    time.sleep(1)

print("Done downloading missing thumbnails!")
