from PIL import Image
import os

img_path = r'C:\Users\user\.gemini\antigravity\brain\40f1eaa8-ab6b-4ab6-972c-dcb4dcb3667b\.user_uploaded\media_1793588144201_375bcb97.png'
im = Image.open(img_path).convert('RGB')

# MKND logo from top right of Card 1 (around x: 95 to 123, y: 35 to 63)
mknd_logo = im.crop((97, 36, 123, 62)).resize((100, 100), Image.Resampling.LANCZOS)
mknd_logo.save(r'coffe-labs-mobile\assets\images\roasteries\mknd_logo.png')
print("Saved mknd_logo.png")

# Mahugi logo from top right of Mahugi Card (around x: 220 to 244, y: 656 to 680)
mahugi_logo = im.crop((225, 656, 245, 676)).resize((100, 100), Image.Resampling.LANCZOS)
mahugi_logo.save(r'coffe-labs-mobile\assets\images\roasteries\mahugi_logo.png')
print("Saved mahugi_logo.png")

# Fugol logo from Fugol Card sticker character (around x: 165 to 215, y: 265 to 315)
fugol_logo = im.crop((165, 260, 218, 318)).resize((120, 120), Image.Resampling.LANCZOS)
fugol_logo.save(r'coffe-labs-mobile\assets\images\roasteries\fugol_logo.png')
print("Saved fugol_logo.png")
