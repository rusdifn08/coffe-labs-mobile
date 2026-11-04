import os
import sys
from PIL import Image

sys.stdout.reconfigure(encoding='utf-8')

brewer_dir = r'c:\Rusdi\Coffe Labs\coffe-labs-mobile\brewer'
base_dir = r'c:\Rusdi\Coffe Labs\coffe-labs-mobile'
portraits_dir = os.path.join(base_dir, 'assets', 'images', 'avatars', 'portraits')
roasteries_dir = os.path.join(base_dir, 'assets', 'images', 'roasteries')

os.makedirs(portraits_dir, exist_ok=True)
os.makedirs(roasteries_dir, exist_ok=True)

# Import our verified mapping
from verify_mapping import MAPPING

def crop_to_square(img, fname):
    w, h = img.size
    if w == h:
        return img
    
    if w > h:
        # Wide image: center crop horizontally
        left = (w - h) // 2
        right = left + h
        top = 0
        bottom = h
        return img.crop((left, top, right, bottom))
    else:
        # Tall image (h > w)
        diff = h - w
        if fname.lower().startswith('chandra'):
            # Chandra: face is near top
            top = int(diff * 0.15)
        else:
            # General: slightly higher than middle for portraits
            top = int(diff * 0.25)
        bottom = top + w
        if bottom > h:
            bottom = h
            top = h - w
        return img.crop((0, top, w, bottom))

def process_and_save():
    processed_count = 0
    saved_portraits = 0
    saved_roasteries = 0
    
    for filename, info in MAPPING.items():
        src_path = os.path.join(brewer_dir, filename)
        if not os.path.exists(src_path):
            print(f"Warning: file {src_path} not found!")
            continue
            
        with Image.open(src_path) as im:
            # Convert to RGBA first to handle any mode cleanly
            im_rgba = im.convert('RGBA')
            
            # Crop to 1:1
            sq = crop_to_square(im_rgba, filename)
            
            # Target resolution: standard 400x400 (or keep original if smaller than 400)
            orig_size = sq.size[0]
            target_size = min(orig_size, 480)
            if target_size < 200:
                target_size = orig_size # don't upscale tiny icons too much
            elif target_size > 400:
                target_size = 400
                
            if sq.size[0] != target_size:
                sq = sq.resize((target_size, target_size), Image.Resampling.LANCZOS)
                
            # Create RGB version for JPEG
            # Use white background for transparent pixels if any
            bg = Image.new('RGB', sq.size, (255, 255, 255))
            bg.paste(sq, mask=sq.split()[3])
            rgb_img = bg
            
            slug = info['slug']
            aliases = info.get('aliases', [])
            roastery_ids = info.get('roastery_ids', [])
            is_brewer = info['type'] in ('brewer', 'both')
            is_roastery = info['type'] in ('roastery', 'both') or len(roastery_ids) > 0
            
            # 1. Save portraits
            if is_brewer:
                # Target portrait path
                p_targets = [slug] + aliases
                for p_slug in p_targets:
                    out_jpg = os.path.join(portraits_dir, f"{p_slug}.jpg")
                    rgb_img.save(out_jpg, format='JPEG', quality=86, optimize=True, subsampling=0)
                    saved_portraits += 1
                    
            # 2. Save roastery logos
            if is_roastery:
                r_targets = roastery_ids if roastery_ids else [slug]
                for r_id in r_targets:
                    out_png = os.path.join(roasteries_dir, f"{r_id}.png")
                    sq.save(out_png, format='PNG', optimize=True)
                    saved_roasteries += 1
                    
                # If also has roastery, also make sure portrait exists if recipe uses it
                if not is_brewer:
                    out_jpg = os.path.join(portraits_dir, f"{slug}.jpg")
                    rgb_img.save(out_jpg, format='JPEG', quality=86, optimize=True, subsampling=0)
                    saved_portraits += 1
                    
            processed_count += 1
            print(f"Processed: {filename:40} -> slug: {slug} (1:1 {sq.size[0]}x{sq.size[1]})")

    print(f"\nSUCCESS: Processed {processed_count} source images.")
    print(f"Saved {saved_portraits} portraits to {portraits_dir}")
    print(f"Saved {saved_roasteries} roastery logos to {roasteries_dir}")

if __name__ == '__main__':
    process_and_save()
