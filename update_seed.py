import re
import random

filepath = "E:/APPS From Agent/Mobile-Flutter/Coffee Hub/coffee_hub_mobile/lib/services/seed_data.dart"
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Replace authorImageUrl with local asset
# "authorImageUrl": "https://..."
def replace_img(match):
    idx = random.randint(1, 10)
    return f'"authorImageUrl": "assets/images/avatars/avatar_{idx}.jpg"'

content = re.sub(r'"authorImageUrl":\s*"[^"]+"', replace_img, content)

# 2. Replace countries with flags
country_flags = {
    'Norwegia': '🇳🇴',
    'Yunani': '🇬🇷',
    'Swiss': '🇨🇭',
    'Jepang': '🇯🇵',
    'Inggris': '🇬🇧',
    'Rusia': '🇷🇺',
    'Taiwan': '🇹🇼',
    'Irlandia': '🇮🇪',
    'China': '🇨🇳',
    'Korea Selatan': '🇰🇷',
    'Amerika Serikat': '🇺🇸',
    'Kanada': '🇨🇦',
    'Australia': '🇦🇺',
    'Swedia': '🇸🇪',
    'Chile': '🇨🇱',
    'Prancis': '🇫🇷',
    'Filipina': '🇵🇭',
    'Jerman': '🇩🇪',
    'Rumania': '🇷🇴',
    'Hong Kong': '🇭🇰',
    'Malaysia': '🇲🇾',
    'Singapura': '🇸🇬',
    'Austria': '🇦🇹',
    'UEA': '🇦🇪',
    'Republik Ceko': '🇨🇿',
    'Indonesia': '🇮🇩',
    'Jepang ': '🇯🇵',
}

for country, flag in country_flags.items():
    content = content.replace(f'({country})', flag)

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)

print("seed_data.dart updated!")
