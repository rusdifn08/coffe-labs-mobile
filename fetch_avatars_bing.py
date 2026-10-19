import os
import shutil
from bing_image_downloader import downloader

avatar_dir = "E:/APPS From Agent/Mobile-Flutter/Coffee Hub/coffee_hub_mobile/assets/images/avatars"
os.makedirs(avatar_dir, exist_ok=True)

brewers = [
    "Nas Jaafar", "Simon Gautherin", "Bavis Kwong", "Peng Jinyang", "Carlos Fernandez", "Ryan Wibawa",
    "Odd-Steinar Tøllefsen", "Konstantinos Iatridis", "Benjamin Prager", "Tetsu Kasuya",
    "Stefanos Domatiotis", "Emi Fukahori", "Berg Wu", "Matt Winton", "Carlos Escobar",
    "Martin Hudak", "Daiki Hatakeyama", "Anthony Douglas", "Cole Torode", "Patricio Rossi",
    "Boram Um", "Francois Putz", "Federico Pezzetta", "Du Jianing", "Regine Wai Yee Beng", 
    "Shih Yuan Hsu", "Elysia Tan", "Savina Giachgia", "Garam Victor Um", "Martin Wölfl", "Wataru Iidaka", "Bayu Prawiro", "Alessandro Galtieri", "Patrik Rolf", "Chad Wang"
]

for name in brewers:
    safe_name = name.lower().replace(' ', '_').replace('ö', 'o').replace('-', '_')
    save_path = os.path.join(avatar_dir, f"{safe_name}.jpg")
    
    print(f"Fetching {name}...")
    try:
        # download to dataset directory
        downloader.download(f"{name} coffee champion portrait", limit=1, output_dir='dataset', adult_filter_off=True, force_replace=True, timeout=10, filter="photo")
        
        # move file to our assets
        downloaded_dir = os.path.join('dataset', f"{name} coffee champion portrait")
        if os.path.exists(downloaded_dir):
            files = os.listdir(downloaded_dir)
            if files:
                downloaded_file = os.path.join(downloaded_dir, files[0])
                shutil.copy(downloaded_file, save_path)
                print(f"Saved {save_path}")
            else:
                print(f"No file found for {name}")
    except Exception as e:
        print(f"Error fetching {name}: {e}")

print("Done downloading all avatars via Bing!")
