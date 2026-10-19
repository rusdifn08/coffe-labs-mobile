import re
import json

file_path = 'E:/APPS From Agent/Mobile-Flutter/Coffee Hub/coffee_hub_mobile/lib/services/seed_data.dart'

with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Map old Indonesian/long grind sizes to short English terms
grind_map = {
    "Sangat Seragam (Sifting)": "Medium",
    "Kasar Seragam (Biji Dibekukan)": "Coarse",
    "250-350 Mikron (Diayak)": "Fine",
    "Sangat Kasar (Very Coarse)": "Very Coarse",
    "Menengah Halus (Tanpa Fines)": "Medium Fine",
    "Menengah Kasar (Medium Coarse)": "Medium Coarse",
    "Kasar (Coarse)": "Coarse",
    "Menengah (Medium)": "Medium",
    "Penggilingan Ganda (Double Grind)": "Double Grind",
    "Menengah (Rapid Degassing)": "Medium",
    "Kasar-Menengah (Medium Coarse)": "Medium Coarse",
    "Blend (75% Kasar, 25% Halus)": "Blend",
    "Berlapis (Stacked Dosing)": "Medium",
    "Menengah Halus (Medium Fine)": "Medium Fine",
    "490 Mikron (Sangat Seragam)": "Medium Fine",
    "Berlapis 3 (Sandwich Dose)": "Medium"
}

def replacer(match):
    original = match.group(1)
    if original in grind_map:
        return f'"grindSize": "{grind_map[original]}"'
    
    # Fallback to pure English if any
    clean = original.lower()
    if 'sangat kasar' in clean:
        return '"grindSize": "Very Coarse"'
    if 'kasar' in clean and 'menengah' in clean:
        return '"grindSize": "Medium Coarse"'
    if 'halus' in clean and 'menengah' in clean:
        return '"grindSize": "Medium Fine"'
    if 'kasar' in clean:
        return '"grindSize": "Coarse"'
    if 'menengah' in clean or 'medium' in clean:
        return '"grindSize": "Medium"'
    if 'halus' in clean:
        return '"grindSize": "Fine"'

    return f'"grindSize": "{original}"'

new_content = re.sub(r'"grindSize":\s*"(.*?)"', replacer, content)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(new_content)
