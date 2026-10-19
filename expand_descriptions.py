import re
import json

file_path = 'E:/APPS From Agent/Mobile-Flutter/Coffee Hub/coffee_hub_mobile/lib/services/seed_data.dart'

with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# We need to extract the recipes list, modify it, and put it back.
# But seed_data.dart is Dart code, not pure JSON.
# It looks like:
# return [
#   { ... },
#   { ... }
# ]
# We can use regex to find the description field and replace it.

specific_narratives = {
    "Tetsu Kasuya": "Metode 4:6 yang legendaris ini membagi total air seduhan menjadi dua fraksi utama. Fraksi pertama (40% air) difokuskan murni pada manipulasi keseimbangan rasa asam (acidity) dan manis (sweetness). Kasuya menuangkan air dalam dua tahap awal untuk mengatur rasio ini. Fraksi kedua (60% air) dibagi menjadi tiga tuangan berturut-turut yang dirancang khusus untuk mengatur intensitas konsentrasi atau kekuatan (strength) kopi tanpa mengekstraksi rasa pahit berlebih. Penggunaan gilingan sangat kasar memastikan air mengalir lancar dan kejernihan rasa tetap maksimal.",
    "Matt Winton": "Resep ini adalah mahakarya perakitan rasa. Matt Winton menggunakan metode tuangan konsisten yang meminimalkan agitasi berlebih, memastikan ekstraksi berjalan seragam di seluruh lapisan bubuk kopi. Dengan rasio yang cukup padat dan suhu presisi, metode ini mengekstrak minyak aromatik terdalam dari biji kopi tanpa menyentuh komponen astringent yang tidak diinginkan. Sangat disarankan untuk menggunakan penyeduh berdasar datar (flat bottom) untuk menjaga kestabilan suhu selama proses ekstraksi.",
    "Martin Wölfl": "Menggabungkan kecepatan dan presisi, resep dari Juara Dunia 2024 ini menuntut teknik penuangan yang ritmis. Fase blooming dibiarkan cukup lama agar degasing terjadi sempurna. Alih-alih menuang secara perlahan, tuangan utama dilakukan dengan debit air yang stabil dan agresif untuk mengaduk *slurry* secara alami (turbulensi termal), menghasilkan profil rasa yang sangat cerah, berani, dan *juicy*.",
    "Du Jianing": "Inovasi tingkat tinggi! Du Jianing memukau dunia dengan pendekatan analitisnya terhadap suhu dan ukuran gilingan. Resep ini menggunakan teknik *bypass* atau manipulasi agitasi yang sangat halus. Tuangan dibagi ke dalam beberapa tahap pendek untuk menjaga suhu *slurry* tetap tinggi tanpa menggenangi kopi terlalu lama, sehingga keasaman buah (fruity acidity) terekstrak dengan sangat tajam dan bersih.",
    "Ryan Wibawa": "Kebanggaan Indonesia di panggung dunia! Ryan Wibawa merancang resep ini dengan filosofi keselarasan rasa. Dengan memperpanjang waktu kontak air dan kopi melalui tuangan yang lembut dan perlahan, ekstraksi gula alami (sweetness) dimaksimalkan. Hasilnya adalah secangkir kopi dengan *body* yang membulat, *aftertaste* yang panjang, dan tingkat kemanisan yang sangat dominan.",
    "Odd-Steinar Tøllefsen": "Fokus ekstrem pada kejernihan rasa (*clarity*). Masa pra-infusi (blooming) dilakukan dengan sangat hati-hati untuk memastikan seluruh partikel basah sempurna. Tuangan selanjutnya dilakukan dengan ritme yang lambat dan stabil, menghasilkan total waktu seduh yang cukup panjang. Teknik ini dirancang khusus untuk biji kopi proses Natural tingkat tinggi, mengeluarkan seluruh potensi rasa buah tropis tanpa fermentasi berlebih.",
    "Konstantinos Iatridis": "Inovasi pemecahan suhu! Teknik ini memperkenalkan cara-cara radikal dalam memanipulasi ekstraksi. Penuangan dibagi menjadi fase-fase yang sangat ketat. Fokus utamanya adalah mencegah penyumbatan filter (*clogging*) dengan menuang air sedemikian rupa sehingga partikel halus (fines) tidak turun ke dasar kertas saring, menjaga kejelasan rasa dari awal hingga tetesan terakhir.",
    "Benjamin Prager": "Bermain dengan kurva suhu! Resep ini sengaja menggunakan profil tuangan yang perlahan menurunkan suhu *slurry* menjelang akhir seduhan. Hal ini bertujuan untuk mencegah ekstraksi komponen pahit yang biasanya larut pada suhu tinggi di akhir fase seduh. Hasilnya adalah tekstur kopi yang sehalus sutra dengan *mouthfeel* yang elegan."
}

def generate_dynamic_description(match):
    original_desc = match.group(1)
    
    # We will just return a placeholder for the regex replacer and handle the logic via python string replacement
    return match.group(0) # Not used directly this way

# We will iterate line by line to inject the logic
lines = content.split('\n')
new_lines = []
current_author = ""
current_temp = ""
current_coffee = ""
current_water = ""
current_grind = ""
current_desc = ""

for i in range(len(lines)):
    line = lines[i]
    
    if '"author":' in line:
        current_author = re.search(r'"author":\s*"(.*?)"', line).group(1)
    if '"waterTempCelsius":' in line:
        current_temp = re.search(r'"waterTempCelsius":\s*(\d+)', line).group(1)
    if '"coffeeWeightGrams":' in line:
        current_coffee = re.search(r'"coffeeWeightGrams":\s*([\d\.]+)', line).group(1)
    if '"totalWaterWeightGrams":' in line:
        current_water = re.search(r'"totalWaterWeightGrams":\s*([\d\.]+)', line).group(1)
    if '"grindSize":' in line:
        current_grind = re.search(r'"grindSize":\s*"(.*?)"', line).group(1)
        
    if '"description":' in line:
        original_desc = re.search(r'"description":\s*"(.*?)"', line).group(1)
        
        # Determine specific author narrative
        author_key = next((k for k in specific_narratives.keys() if k in current_author), None)
        
        if author_key:
            expanded_desc = specific_narratives[author_key]
        else:
            try:
                ratio = round(float(current_water) / float(current_coffee), 1)
            except:
                ratio = 15.0
                
            expanded_desc = (
                f"{original_desc} "
                f"Resep ini menggunakan rasio presisi 1:{ratio} yang dirancang untuk menyeimbangkan ekstraksi secara optimal. "
                f"Dengan memanfaatkan air bersuhu {current_temp}°C dan gilingan berukuran {current_grind}, "
                f"teknik penuangan ini mampu memanipulasi turbulensi (agitasi) di dalam alat seduh. "
                f"Hal ini memastikan pelepasan gas karbon dioksida saat fase blooming berjalan sempurna, "
                f"serta mencegah terjadinya channeling (aliran air tak merata). Hasil akhirnya adalah secangkir kopi dengan "
                f"spektrum rasa yang kompleks, menonjolkan tingkat kemanisan (sweetness) alami dan kejelasan (clarity) yang tajam."
            )
        
        # Replace the description line
        line = re.sub(r'"description":\s*".*?"', f'"description": "{expanded_desc}"', line)
        
    new_lines.append(line)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write('\n'.join(new_lines))
