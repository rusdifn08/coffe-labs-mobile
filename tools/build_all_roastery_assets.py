import os
import re
from PIL import Image, ImageDraw, ImageFont

p_roasteries = r'c:\Rusdi\Coffe Labs\coffe-labs-mobile\lib\data\roasteries'
out_roasteries = r'c:\Rusdi\Coffe Labs\coffe-labs-mobile\assets\images\roasteries'
out_beans = r'c:\Rusdi\Coffe Labs\coffe-labs-mobile\assets\images\beans'

os.makedirs(out_roasteries, exist_ok=True)
os.makedirs(out_beans, exist_ok=True)

# Roastery distinct brand colors
BRAND_PALETTES = {
    'tanamera_coffee': ((180, 20, 20), (255, 255, 255), "TC"),
    'sakha_coffee': ((30, 80, 160), (255, 255, 255), "SAKHA"),
    'missibu_roaster': ((220, 140, 50), (255, 255, 255), "MISSIBU"),
    'fumidai_roastery': ((60, 60, 60), (240, 200, 100), "FUMIDAI"),
    'sematjam_coffee': ((190, 80, 60), (255, 255, 255), "SEMATJAM"),
    'kopiteori_deapati': ((45, 55, 72), (255, 255, 255), "TEORI"),
    'indibro_sutoyo_mknd': ((218, 165, 32), (20, 20, 20), "MKND"),
    'otten_coffee': ((220, 38, 38), (255, 255, 255), "OTTEN"),
    'arutala_coffee': ((16, 185, 129), (255, 255, 255), "ARUTALA"),
    'semekar_coffee': ((236, 72, 153), (255, 255, 255), "SEMEKAR"),
    'anomali_coffee': ((120, 53, 15), (255, 255, 255), "ANOMALI"),
    'kopi_anjis': ((234, 88, 12), (255, 255, 255), "ANJIS"),
    'koro_roasters': ((67, 56, 202), (255, 255, 255), "KORO"),
    'els_coffee': ((194, 65, 12), (255, 255, 255), "ELS"),
    'serkop_roastery': ((30, 41, 59), (255, 255, 255), "SERKOP"),
    'fugol_coffee': ((245, 158, 11), (20, 20, 20), "FUGOL"),
    'herd_coffee': ((13, 148, 136), (255, 255, 255), "HERD"),
    'thf_roastery': ((24, 24, 27), (255, 255, 255), "THF"),
    'wheels_coffee': ((22, 101, 52), (255, 255, 255), "WHEELS"),
    'toko_kopi_aroma': ((113, 63, 18), (255, 255, 255), "AROMA"),
    'klasik_beans': ((87, 83, 78), (255, 255, 255), "KLASIK"),
    '5758_coffee_lab': ((15, 118, 110), (255, 255, 255), "5758"),
    'makmur_jaya': ((202, 138, 4), (20, 20, 20), "MAKMUR"),
    'more_coffee': ((79, 70, 229), (255, 255, 255), "MORE"),
    'village_coffee': ((82, 82, 91), (255, 255, 255), "VILLAGE"),
    'instinct_roastery': ((190, 24, 93), (255, 255, 255), "INSTINCT"),
    'giyanti_coffee': ((180, 83, 9), (255, 255, 255), "GIYANTI"),
    'one_fifteenth_morph': ((15, 23, 42), (255, 255, 255), "1/15"),
    'first_crack_coffee': ((185, 28, 28), (255, 255, 255), "1ST CRACK"),
    'smoking_barrels': ((41, 37, 36), (234, 179, 8), "BARRELS"),
    'pigeonhole_coffee': ((3, 105, 161), (255, 255, 255), "PIGEON"),
    'onward_coffee': ((30, 58, 138), (255, 255, 255), "ONWARD"),
    'movere_coffee': ((124, 45, 18), (255, 255, 255), "MOVERE"),
    'life_coffee': ((101, 163, 13), (255, 255, 255), "LIFE"),
    'comfort_table_maharaja': ((136, 19, 55), (255, 255, 255), "MAHARAJA"),
    'space_coffee': ((225, 29, 72), (255, 255, 255), "SPACE"),
    'hayati_coffee': ((154, 52, 18), (255, 255, 255), "HAYATI"),
    'klinik_kopi': ((22, 78, 99), (255, 255, 255), "KLINIK"),
    'kopirelo_coffee': ((120, 53, 15), (255, 255, 255), "RELO"),
    'hana_roastery': ((219, 39, 119), (255, 255, 255), "HANA"),
    'initial_coffee': ((15, 23, 42), (255, 255, 255), "INITIAL"),
    'steam_and_brew': ((30, 64, 175), (255, 255, 255), "S&B"),
    'koeslans_coffee': ((124, 45, 18), (255, 255, 255), "KOESLAN"),
    'typika_nordic_surabaya': ((14, 116, 144), (255, 255, 255), "TYPIKA"),
    'darat_motiv_roasters': ((68, 64, 60), (255, 255, 255), "DARAT"),
    'seniman_coffee': ((161, 98, 7), (255, 255, 255), "SENIMAN"),
    'hungry_bird_coffee': ((202, 138, 4), (255, 255, 255), "BIRD"),
    'catur_coffee': ((91, 33, 182), (255, 255, 255), "CATUR"),
    'revolver_espresso': ((24, 24, 27), (251, 191, 36), "REVOLVER"),
    'blacklist_everhaos': ((15, 23, 42), (255, 255, 255), "BLACKLIST"),
}

def generate_logo(r_id, r_name):
    path = os.path.join(out_roasteries, f"{r_id}.png")
    # Brand details
    palette = BRAND_PALETTES.get(r_id, ((50, 50, 60), (255, 255, 255), r_name[:4].upper()))
    bg_col, txt_col, label = palette
    
    im = Image.new('RGBA', (200, 200), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    
    # Outer circle
    d.ellipse((8, 8, 192, 192), fill=bg_col, outline=(255, 255, 255, 200), width=5)
    # Inner circle accent
    d.ellipse((18, 18, 182, 182), fill=None, outline=(255, 255, 255, 100), width=2)
    # Typography
    d.text((100, 95), label, fill=txt_col, anchor='mm')
    d.text((100, 135), "ROASTERY", fill=(255, 255, 255, 180), anchor='mm')
    im.save(path)
    return path

def generate_bean_pouch(filename, roastery_name, bean_name, origin, roast, process, notes, r_id):
    path = os.path.join(out_beans, filename)
    if os.path.exists(path) and os.path.getsize(path) > 15000:
        # already an authentic cropped or downloaded photo
        return path
        
    W, H = 400, 480
    
    # Determine pouch color by roast & process
    roast_lower = roast.lower()
    proc_lower = process.lower()
    
    if 'dark' in roast_lower:
        pouch_col = (30, 28, 26)
        label_col = (25, 23, 22)
        txt_col = (240, 210, 150)
        bg_col = (235, 230, 225)
    elif 'light' in roast_lower:
        pouch_col = (250, 248, 245)
        label_col = (255, 255, 255)
        txt_col = (35, 30, 25)
        bg_col = (245, 238, 230)
    elif 'wine' in proc_lower or 'anaerob' in proc_lower:
        pouch_col = (75, 20, 40)
        label_col = (255, 255, 255)
        txt_col = (40, 20, 25)
        bg_col = (245, 230, 235)
    elif 'honey' in proc_lower:
        pouch_col = (210, 150, 60)
        label_col = (255, 255, 255)
        txt_col = (50, 35, 20)
        bg_col = (245, 238, 225)
    else: # Medium Washed
        pouch_col = (180, 140, 100) # Kraft paper
        label_col = (255, 255, 255)
        txt_col = (40, 30, 20)
        bg_col = (240, 235, 230)
        
    im = Image.new('RGB', (W, H), bg_col)
    d = ImageDraw.Draw(im)
    
    # Background soft gradient vignette
    for y in range(H):
        ratio = y / H
        r = int(bg_col[0] - ratio * 15)
        g = int(bg_col[1] - ratio * 15)
        b = int(bg_col[2] - ratio * 15)
        d.line([(0, y), (W, y)], fill=(r, g, b))
        
    # Pouch shadow
    d.rounded_rectangle((78, 68, 328, 428), radius=22, fill=(0, 0, 0, 35))
    # Pouch stand-up bag
    d.rounded_rectangle((70, 60, 320, 420), radius=20, fill=pouch_col, outline=(220, 210, 195), width=2)
    # Zip seal lines
    d.line([(70, 95), (320, 95)], fill=(0, 0, 0, 60), width=2)
    d.line([(70, 102), (320, 102)], fill=(255, 255, 255, 50), width=1)
    
    # Central Branding Label Sticker
    d.rounded_rectangle((90, 125, 300, 365), radius=12, fill=label_col, outline=(220, 210, 195), width=1)
    
    # Roastery Header
    r_palette = BRAND_PALETTES.get(r_id, ((60, 60, 70), (255, 255, 255), "COFFEE"))
    d.rounded_rectangle((100, 135, 290, 168), radius=6, fill=r_palette[0])
    d.text((195, 151), roastery_name.upper(), fill=r_palette[1], anchor='mm')
    
    # Bean Title (Word wrap)
    words = bean_name.split()
    if len(words) >= 3:
        line1 = " ".join(words[:2])
        line2 = " ".join(words[2:])
        d.text((195, 195), line1, fill=txt_col, anchor='mm')
        d.text((195, 218), line2, fill=txt_col, anchor='mm')
    else:
        d.text((195, 205), bean_name, fill=txt_col, anchor='mm')
        
    d.line([(120, 240), (270, 240)], fill=(200, 190, 175), width=1)
    
    # Origin & Process
    d.text((195, 258), f"{origin.split('(')[0].strip()}", fill=(110, 100, 90), anchor='mm')
    d.text((195, 280), f"{roast} • {process}", fill=(140, 70, 20), anchor='mm')
    
    # Tasting Notes pill
    clean_notes = notes.split('(')[0].replace(';', ',').strip()
    notes_short = clean_notes[:35] + '...' if len(clean_notes) > 35 else clean_notes
    d.rounded_rectangle((105, 305, 285, 335), radius=6, fill=(245, 240, 230), outline=(230, 220, 200))
    d.text((195, 320), notes_short, fill=(60, 50, 40), anchor='mm')
    
    # Bottom weight badge
    d.rounded_rectangle((235, 385, 305, 408), radius=6, fill=(40, 35, 30))
    d.text((270, 396), "200 G", fill=(255, 255, 255), anchor='mm')
    
    im.save(path, quality=94)
    return path

# Run parsing and generation
print("Processing roasteries...")
bean_count = 0
for f in sorted(os.listdir(p_roasteries)):
    if f.endswith('.dart'):
        txt = open(os.path.join(p_roasteries, f), encoding='utf-8').read()
        # Find roastery blocks
        roastery_splits = re.split(r'Roastery\(', txt)[1:]
        for r_str in roastery_splits:
            id_m = re.search(r"id:\s*['\"]([^'\"]+)['\"]", r_str)
            name_m = re.search(r"name:\s*['\"]([^'\"]+)['\"]", r_str)
            if not id_m or not name_m:
                continue
            r_id = id_m.group(1)
            r_name = name_m.group(1)
            
            # Generate logo
            generate_logo(r_id, r_name)
            
            # Find all lineups
            items = re.findall(r"CoffeeLineupItem\(\s*name:\s*['\"]([^'\"]+)['\"].*?origin:\s*['\"]([^'\"]+)['\"].*?roastProfile:\s*['\"]([^'\"]+)['\"].*?process:\s*['\"]([^'\"]+)['\"].*?tastingNotes:\s*['\"]([^'\"]+)['\"]", r_str, re.DOTALL)
            for item in items:
                b_name, b_origin, b_roast, b_proc, b_notes = item
                slug = re.sub(r'[^a-z0-9]+', '_', b_name.lower()).strip('_')
                filename = f"{r_id}_{slug}.jpg"
                generate_bean_pouch(filename, r_name, b_name, b_origin, b_roast, b_proc, b_notes, r_id)
                bean_count += 1

print(f"Finished generating all roastery logos and {bean_count} custom roastery bean pouches!")
