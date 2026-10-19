import os
import re
import shutil

filepath = "E:/APPS From Agent/Mobile-Flutter/Coffee Hub/coffee_hub_mobile/lib/services/seed_data.dart"
avatar_dir = "E:/APPS From Agent/Mobile-Flutter/Coffee Hub/coffee_hub_mobile/assets/images/avatars"

with open(filepath, 'r', encoding='utf-8') as f:
    lines = f.readlines()

emojis = [
      '🇳🇴', '🇬🇷', '🇨🇭', '🇯🇵', '🇬🇧', '🇷🇺', '🇹🇼', '🇮🇪', '🇨🇳', '🇰🇷',
      '🇺🇸', '🇨🇦', '🇦🇺', '🇸🇪', '🇨🇱', '🇫🇷', '🇵🇭', '🇩🇪', '🇷🇴', '🇭🇰',
      '🇲🇾', '🇸🇬', '🇦🇹', '🇦🇪', '🇨🇿', '🇮🇩'
]

fallback_img = os.path.join(avatar_dir, "generic_fallback.jpg")

for i in range(len(lines)):
    if '"author":' in lines[i]:
        author_val = re.search(r'"author": "([^"]+)"', lines[i]).group(1)
        clean = re.sub(r'\s*\([^)]*\)', '', author_val)
        for e in emojis:
            clean = clean.replace(e, '')
        clean = clean.strip()
        safe_name = clean.lower().replace(' ', '_').replace('ö', 'o').replace('-', '_').replace('ø', 'o')
        
        # find the actual file in assets/images/avatars/
        actual_ext = None
        for ext in ['webp', 'jpg', 'png', 'jpeg', 'gif']:
            p = os.path.join(avatar_dir, f"{safe_name}.{ext}")
            if os.path.exists(p) and os.path.getsize(p) > 0:
                actual_ext = ext
                break
                
        if not actual_ext:
            # fallback copy
            dest = os.path.join(avatar_dir, f"{safe_name}.jpg")
            if os.path.exists(fallback_img):
                shutil.copy(fallback_img, dest)
            actual_ext = 'jpg'
            print(f"Used fallback for {clean}")
            
        # Look ahead for authorImageUrl
        for j in range(i+1, min(i+5, len(lines))):
            if '"authorImageUrl":' in lines[j]:
                lines[j] = re.sub(r'"authorImageUrl":\s*"[^"]+"', f'"authorImageUrl": "assets/images/avatars/{safe_name}.{actual_ext}"', lines[j])
                break

with open(filepath, 'w', encoding='utf-8') as f:
    f.writelines(lines)

print("Synchronized seed_data.dart extensions with actual downloaded files!")
