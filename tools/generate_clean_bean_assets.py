from PIL import Image, ImageDraw, ImageFont, ImageFilter
import os

# Create stylish packaging cards if missing or to ensure high aesthetics
beans_dir = r"coffe-labs-mobile\assets\images\beans"
roasteries_dir = r"coffe-labs-mobile\assets\images\roasteries"
os.makedirs(beans_dir, exist_ok=True)
os.makedirs(roasteries_dir, exist_ok=True)

def create_roastery_logo(name, filename, bg_color, text_color, initials):
    path = os.path.join(roasteries_dir, filename)
    if os.path.exists(path) and os.path.getsize(path) > 3000:
        return
    im = Image.new('RGBA', (200, 200), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    # Circle badge
    d.ellipse((10, 10, 190, 190), fill=bg_color, outline=(255, 255, 255, 180), width=4)
    # Initials / Typography
    d.text((100, 95), initials, fill=text_color, anchor='mm')
    im.save(path)
    print(f"Created logo: {filename}")

def create_coffee_pouch(title, roastery, origin, notes, filename, bg_gradient_start, bg_gradient_end, pouch_color, badge="100 G"):
    path = os.path.join(beans_dir, filename)
    if os.path.exists(path) and os.path.getsize(path) > 10000:
        # Check if it's already a good image
        return
    
    W, H = 400, 480
    im = Image.new('RGB', (W, H), bg_gradient_start)
    d = ImageDraw.Draw(im)
    
    # Background subtle gradient
    for y in range(H):
        r = int(bg_gradient_start[0] + (bg_gradient_end[0] - bg_gradient_start[0]) * (y / H))
        g = int(bg_gradient_start[1] + (bg_gradient_end[1] - bg_gradient_start[1]) * (y / H))
        b = int(bg_gradient_start[2] + (bg_gradient_end[2] - bg_gradient_start[2]) * (y / H))
        d.line([(0, y), (W, y)], fill=(r, g, b))
    
    # Coffee Pouch body (shadow + rounded rect)
    d.rounded_rectangle((75, 75, 325, 415), radius=20, fill=(0, 0, 0, 80)) # shadow
    d.rounded_rectangle((70, 70, 320, 410), radius=18, fill=pouch_color, outline=(220, 200, 170), width=2)
    
    # Pouch top zip line
    d.line([(70, 110), (320, 110)], fill=(80, 70, 60), width=2)
    
    # Center label sticker
    d.rounded_rectangle((95, 135, 295, 355), radius=12, fill=(255, 255, 255), outline=(230, 220, 200), width=1)
    
    # Text on label
    d.text((195, 160), roastery.upper(), fill=(140, 90, 40), anchor='mm')
    d.line([(120, 175), (270, 175)], fill=(200, 180, 150), width=1)
    
    # Title (wrap if long)
    words = title.split()
    if len(words) > 2:
        t1 = " ".join(words[:2])
        t2 = " ".join(words[2:])
        d.text((195, 205), t1, fill=(30, 25, 20), anchor='mm')
        d.text((195, 230), t2, fill=(30, 25, 20), anchor='mm')
    else:
        d.text((195, 215), title, fill=(30, 25, 20), anchor='mm')
        
    d.text((195, 260), origin, fill=(100, 90, 80), anchor='mm')
    d.text((195, 295), f"Notes: {notes}", fill=(180, 80, 30), anchor='mm')
    
    # Badge (e.g. 100 G / Halal / Special)
    d.rounded_rectangle((230, 370, 310, 400), radius=8, fill=(180, 130, 60))
    d.text((270, 385), badge, fill=(255, 255, 255), anchor='mm')
    
    im.save(path, quality=92)
    print(f"Created pouch: {filename}")

# Generate logos if needed
create_roastery_logo("Tanamera", "tanamera_logo.png", (180, 20, 20), (255, 255, 255), "TC")
create_roastery_logo("Common Grounds", "common_grounds_logo.png", (20, 120, 140), (255, 255, 255), "CG")
create_roastery_logo("Smoking Barrels", "smoking_barrels_logo.png", (40, 40, 40), (220, 170, 70), "SB")
create_roastery_logo("Two Hands Full", "two_hands_full_logo.png", (25, 25, 25), (255, 255, 255), "2HF")

# Generate extra popular packages
create_coffee_pouch("Halu Pink Banana", "Space Roastery", "Gunung Halu • Anaerobic", "Banana, Bubblegum, Strawberry", "space_halu_pink_banana.jpg", (250, 230, 235), (230, 200, 215), (245, 160, 180), "200 G")
create_coffee_pouch("Rancabali Patuha Ennave", "Mahugi Coffee", "Ciwidey • Natural", "Tropical Fruit, Floral, Honey", "mahugi_rancabali_patuha.jpg", (245, 245, 245), (225, 225, 230), (250, 250, 250), "100 G")
create_coffee_pouch("Kamojang Classico", "Fugol Coffee Roasters", "Garut • Natural", "Passion Fruit, Mango, Cacao", "kamojang_classico.jpg", (255, 235, 240), (240, 200, 210), (255, 180, 200), "100 G")
create_coffee_pouch("Kerinci Honey", "Smoking Barrels", "Kerinci • Honey", "Sweet Honey, Apple, Caramel", "smoking_barrels_kerinci.jpg", (245, 240, 230), (220, 210, 190), (240, 230, 210), "200 G")
create_coffee_pouch("Tolu Batak", "Space Roastery", "Sumatra • Wet Hulled", "Dark Chocolate, Spices, Brown Sugar", "space_tolu_batak.jpg", (220, 230, 225), (190, 210, 200), (40, 55, 50), "200 G")
create_coffee_pouch("Berawa Blend", "Hungry Bird Bali", "Bali & Sumatra", "Chocolate Nibs, Roasted Almond", "hungry_bird_berawa.jpg", (255, 245, 220), (235, 215, 180), (250, 240, 210), "250 G")
