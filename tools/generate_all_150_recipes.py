import os
import sys

OUTPUT_DIR = r"c:\Rusdi\Coffe Labs\coffe-labs-mobile\lib\data\seeds"

def make_recipe(id_num, title, author, bean, variety, process, method, category, temp, grind, dose, water, time_sec, desc, steps, cover="assets/images/avatars/generic_fallback.jpg", avatar="assets/images/avatars/generic_fallback.jpg"):
    steps_dart = ",\n".join([
        f'          {{"stepOrder": {s[0]}, "title": "{s[1]}", "durationSeconds": {s[2]}, "waterAddedGrams": {s[3]}}}'
        for s in steps
    ])
    return f'''  {{
    "id": {id_num},
    "title": "{title}",
    "author": "{author}",
    "coverImageUrl": "{cover}",
    "authorAvatarUrl": "{avatar}",
    "authorImageUrl": "{cover}",
    "beanName": "{bean}",
    "variety": "{variety}",
    "process": "{process}",
    "method": "{method}",
    "category": "{category}",
    "waterTempCelsius": {temp},
    "grindSize": "{grind}",
    "coffeeWeightGrams": {dose},
    "totalWaterWeightGrams": {water},
    "totalTimeSeconds": {time_sec},
    "description": "{desc}",
    "isCustom": false,
    "createdAt": now,
    "steps": [
{steps_dart}
    ]
  }}'''

# Import the first 64 recipes from previous file
from build_all_new_recipes import recipes as base_recipes
all_recipes = list(base_recipes)

# --- ESPRESSO MACHINE (365-378) ---
all_recipes.append((365, "Modern Specialty 1:2.2 Ratio Espresso", "Mikael Jasin 🇮🇩", "Competition Espresso Blend (Ethiopia + Colombia)", "Geisha / Castillo", "Anaerobic Washed", "Espresso Machine", "Espresso", 93, "Fine (Espresso)", 19, 42, 28, "Rasio ekstraksi modern 1:2.2 dengan profil rasa buah persik, sirup nektar, dan keasaman sitrat elegan.", [
    (1, "Pre-infusion 3 Bar", 6, 8), (2, "Full Pressure 9 Bar", 18, 28), (3, "Pressure Decline 6 Bar", 4, 6)
]))
all_recipes.append((366, "Turbo Shot High Extraction 6 Bar", "Scott Rao 🇺🇸", "Kenya Kirinyaga Washed", "SL28", "Washed", "Espresso Machine", "Espresso", 94, "Medium-Fine (Coarser Espresso)", 15, 45, 16, "Teknik Turbo Shot bertekanan rendah 6 bar dan gilingan lebih kasar untuk ekstraksi sangat tinggi dan bebas astringensi.", [
    (1, "Fast Saturation 3 Bar", 3, 10), (2, "High Flow Extraction 6 Bar", 13, 35)
]))
all_recipes.append((367, "Classic Italian Dark Hazelnut Ristretto", "Alessandro Galtieri (Italia)", "Italian Espresso Roast Blend", "Arabica + Robusta Fine", "Natural", "Espresso Machine", "Espresso", 91, "Fine", 20, 30, 25, "Ristretto pekat 1:1.5 dengan crema tebal keemasan, rasa hazelnut panggang, dark chocolate, dan body sangat berat.", [
    (1, "Pre-soak", 4, 5), (2, "Full 9 Bar Extraction", 21, 25)
]))
all_recipes.append((368, "Allongé High Clarity Long Espresso", "Jonathan Gagné 🇨🇦", "Ethiopia Yirgacheffe Washed", "Heirloom", "Washed", "Espresso Machine", "Espresso", 93, "Medium-Fine", 18, 90, 30, "Espresso panjang khas Montreal (Allongé) dengan rasio 1:5, menghasilkan crema tipis berkilau dan rasa buah teh bergamot.", [
    (1, "Pre-infusion 4 Bar", 5, 15), (2, "High Yield Extraction 6 Bar", 25, 75)
]))
all_recipes.append((369, "Lever Machine Declining Pressure Pull", "Matt Perger 🇦🇺", "Colombia Huila Washed", "Caturra", "Washed", "Espresso Machine", "Espresso", 92, "Fine", 18, 38, 32, "Profil tekanan menurun khas mesin tuas manual (spring lever) dari 10 bar melandai ke 4 bar untuk rasa manis maksimal.", [
    (1, "Pre-infusion Tuas Naik", 8, 8), (2, "Peak Pressure 10 Bar", 12, 18), (3, "Declining Spring Pressure", 12, 12)
]))
all_recipes.append((370, "Slayer Style Long Pre-Brew Espresso", "Yoshua Tanu 🇮🇩", "Panama Boquete Natural", "Catuai", "Natural", "Espresso Machine", "Espresso", 93, "Fine", 20, 44, 38, "Aliran air sangat lambat (flow restriction) selama 15 detik sebelum ekstraksi penuh 9 bar memunculkan rasa sirup stroberi kental.", [
    (1, "Pre-brew Slow Saturate", 15, 8), (2, "Full Extraction 9 Bar", 18, 30), (3, "Finish Flush", 5, 6)
]))
all_recipes.append((371, "Sweet Milk Drink Espresso Base (Cortado/Flat White)", "Muhammad Aga 🇮🇩", "House Blend Sweet Harmony", "Sumatra + Brazil", "Washed / Natural", "Espresso Machine", "Espresso", 92, "Fine", 19, 36, 26, "Dirancang khusus agar memotong rasa gurih susu steamed menghasilkan karamel, vanila, dan cokelat praline manis.", [
    (1, "Soft Infusion", 5, 6), (2, "Dense Extraction 9 Bar", 21, 30)
]))
all_recipes.append((372, "Nordic Light Roast Sweet Citrus Shot", "Tim Wendelboe 🇳🇴", "Kenya Nyeri Hill", "SL28", "Washed", "Espresso Machine", "Espresso", 95, "Fine", 18, 48, 27, "Suhu tinggi 95°C dan rasio 1:2.6 untuk mengekstrak manis alami asam fosfatik dan rasa blackcurrant juicy pada sangrai Nordic.", [
    (1, "Pre-infusion 2 Bar", 6, 10), (2, "Extraction 7 Bar", 21, 38)
]))
all_recipes.append((373, "Lungo Clean Balanced Extraction", "James Hoffmann 🇬🇧", "Guatemala Huehuetenango", "Bourbon", "Washed", "Espresso Machine", "Espresso", 93, "Medium-Fine", 17, 55, 30, "Lungo seimbang 1:3.2 tanpa sensasi pahit gosong, sangat nikmat diminum langsung hitam tanpa gula.", [
    (1, "Pre-infusion", 5, 10), (2, "Smooth Extraction 8 Bar", 25, 45)
]))
all_recipes.append((374, "High Extraction Basket Precision Shot (IMS / VST)", "Lance Hedrick 🇺🇸", "Ethiopia Sidama Natural", "Heirloom", "Natural", "Espresso Machine", "Espresso", 94, "Extra-Fine", 20, 50, 24, "Menggunakan basket presisi tinggi dengan filter kertas bawah untuk mencegah channeling mikro dan mendongkrak TDS hingga 10.5%.", [
    (1, "Rapid Saturation", 4, 12), (2, "High Flow Extraction", 20, 38)
]))
all_recipes.append((375, "Single Origin Gayo Wine Sweet Crema", "Doddy Samsura 🇮🇩", "Aceh Gayo Wine Process", "Ateng Super", "Wine Fermentation", "Espresso Machine", "Espresso", 91, "Fine", 18, 36, 28, "Crema tebal berwarna merah tembaga dengan aroma anggur merah matang, kismis, dan cokelat truffle.", [
    (1, "Pre-infusion Lembut", 6, 6), (2, "Full Pressure 9 Bar", 22, 30)
]))
all_recipes.append((376, "Double Ristretto Crema Velvet", "Dody Samsura 🇮🇩", "Toraja Sapan Minanga", "Typica", "Semi-Washed", "Espresso Machine", "Espresso", 92, "Fine", 20, 32, 26, "Ekstraksi pendek yang mengunci bagian terbaik minyak aromatik kopi Toraja untuk sensasi velvet di langit-langit mulut.", [
    (1, "Pre-infusion", 5, 6), (2, "Dense Pull", 21, 26)
]))
all_recipes.append((377, "Filter 3.0 Paper-Lined Espresso", "Scott Rao 🇺🇸", "Colombia Gesha Washed", "Geisha", "Washed", "Espresso Machine", "Espresso", 95, "Fine", 16, 75, 25, "Kertas saring di atas dan di bawah puck kopi, menghasilkan minuman espresso jernih berkecepatan tinggi beraroma melati.", [
    (1, "Pre-wet 3 Bar", 5, 15), (2, "Rapid Flow Extraction 6 Bar", 20, 60)
]))
all_recipes.append((378, "Cold Espresso Tonic Concentrate", "Ryan Wibawa 🇮🇩", "Bali Kintamani Washed", "Kopyol", "Washed", "Espresso Machine", "Espresso", 94, "Fine", 20, 40, 26, "Espresso segar yang langsung diekstraksi ke atas es batu untuk dituangkan di atas air tonik dingin berkarbonasi.", [
    (1, "Pre-infusion", 5, 8), (2, "Concentrate Pull", 21, 32)
]))

# --- FRENCH PRESS (379-390) ---
all_recipes.append((379, "The Ultimate French Press Technique", "James Hoffmann 🇬🇧", "Colombia Huila San Agustin", "Caturra", "Washed", "French Press", "French Press", 95, "Medium-Coarse", 30, 500, 480, "Teknik legendaris tanpa menekan plunger hingga dasar; setelah 4 menit kerak diaduk dan dibersihkan lalu didiamkan 5 menit agar fines mengendap.", [
    (1, "Tuang Air Penuh 500g", 30, 500), (2, "Infusi Diam Tanpa Sentuh", 210, 0), (3, "Aduk Kerak & Buang Busa (Skim)", 60, 0), (4, "Sedimentasi 5 Menit (No Plunge)", 180, 0)
]))
all_recipes.append((378 + 2, "Nordic Light Roast Clear Press", "Tim Wendelboe 🇳🇴", "Kenya Nyeri Hill", "SL28", "Washed", "French Press", "French Press", 96, "Coarse", 20, 320, 360, "Ekstraksi imersi penuh yang memamerkan keasaman asam sitrat buah delima dan blackcurrant tanpa rasa bubuk di lidah.", [
    (1, "Tuang Air Mendidih 320g", 25, 320), (2, "Imersi 4 Menit", 215, 0), (3, "Skimming Busa Atas", 40, 0), (4, "Press Ringan Hanya di Permukaan", 80, 0)
]))
all_recipes.append((381, "Rich & Heavy Chocolate Immersion", "Dody Samsura 🇮🇩", "Sumatra Mandheling Lintong", "Typica", "Wet Hulled", "French Press", "French Press", 92, "Coarse", 25, 380, 300, "Ekstraksi imersi klasik untuk pecinta body tebal kopi nusantara, memadukan minyak alami kopi dan manis rempah kayu manis.", [
    (1, "Tuang Air 380g", 30, 380), (2, "Aduk Merata 3x", 20, 0), (3, "Imersi Penuh 4 Menit", 190, 0), (4, "Plunge Lembut ke Dasar", 60, 0)
]))
all_recipes.append((382, "Fast 3-Minute Breakfast Press", "Scott Rao 🇺🇸", "Guatemala Antigua", "Bourbon", "Washed", "French Press", "French Press", 94, "Medium", 20, 300, 180, "Gilingan sedikit lebih halus dari biasanya untuk seduhan cepat 3 menit yang tetap bersih dengan bantuan skimming sendok ganda.", [
    (1, "Tuang 300g Cepat", 20, 300), (2, "Steep 2 Menit", 100, 0), (3, "Skim Permukaan", 30, 0), (4, "Saring ke Mug", 30, 0)
]))
all_recipes.append((383, "Iced French Press Flash Brew", "Lance Hedrick 🇺🇸", "Ethiopia Guji Natural", "Heirloom", "Natural", "French Press", "French Press", 95, "Medium-Coarse", 30, 300, 300, "Seduh pekat di French press selama 4 menit, lalu tuangkan langsung ke gelas penuh es batu untuk es kopi instan kaya rasa.", [
    (1, "Tuang 300g Air Pekat", 25, 300), (2, "Steep Diam 4 Menit", 215, 0), (3, "Skim Crust", 30, 0), (4, "Tuang ke Es Batu di Gelas", 30, 0)
]))
all_recipes.append((384, "Tea-Like Natural Geisha Press", "Mikael Jasin 🇮🇩", "Panama Boquete Geisha", "Geisha", "Natural", "French Press", "French Press", 93, "Medium-Coarse", 15, 260, 420, "French press terbukti sangat baik untuk geisha natural karena mengekstrak seluruh spektrum rasa bunga melati dan leci tanpa tertahan kertas.", [
    (1, "Tuang 260g Lembut", 25, 260), (2, "Imersi Diam 4 Menit", 215, 0), (3, "Aduk 1 Putaran & Skim", 40, 0), (4, "Endapkan 3 Menit & Tuang", 140, 0)
]))
all_recipes.append((385, "Double Mesh Ultra-Clean Press", "Asser Christensen 🇩🇰", "Costa Rica Tarrazu", "Caturra", "White Honey", "French Press", "French Press", 94, "Coarse", 18, 300, 360, "Menggunakan plunger berlapis filter mesh ganda untuk mencegah partikel fines lolos ke cangkir akhir.", [
    (1, "Tuang 300g", 25, 300), (2, "Steep 4 Menit", 215, 0), (3, "Skimming", 30, 0), (4, "Plunge Stabil", 90, 0)
]))
all_recipes.append((386, "Sweet Spiced Bali Kintamani Press", "Muhammad Aga 🇮🇩", "Bali Kintamani Natural", "Kopyol", "Natural", "French Press", "French Press", 92, "Coarse", 22, 340, 300, "Menonjolkan manis jeruk keprok dan aroma bunga kopi Kintamani dengan kebulatan rasa yang tahan lama.", [
    (1, "Tuang 340g", 25, 340), (2, "Aduk Ringan", 15, 0), (3, "Imersi 4 Menit", 200, 0), (4, "Tekan Plunger Perlahan", 60, 0)
]))
all_recipes.append((387, "Cold Infusion Over-Night Press", "Pepeng (Klinik Kopi) 🇮🇩", "Java Preanger Washed", "Typica", "Washed", "French Press", "French Press", 25, "Coarse", 35, 350, 480, "Seduh dingin di dalam French press, masukkan kulkas 12 jam, lalu tinggal tekan plunger di pagi hari untuk cold brew siap minum.", [
    (1, "Tuang Air Suhu Ruang 350g", 30, 350), (2, "Aduk Merata", 30, 0), (3, "Simpan Kulkas 12 Jam", 360, 0), (4, "Press Plunger & Sajikan", 60, 0)
]))
all_recipes.append((388, "Honey Process Silk Texture Press", "Yoshua Tanu 🇮🇩", "Java Frinsa Honey", "Sigararutang", "Yellow Honey", "French Press", "French Press", 93, "Coarse", 20, 320, 360, "Tekstur kental layaknya madu cair dengan rasa buah persik matang dan gula kelapa.", [
    (1, "Tuang 320g", 25, 320), (2, "Imersi 4 Menit", 215, 0), (3, "Skim Kerak", 30, 0), (4, "Endapkan & Tuang", 90, 0)
]))
all_recipes.append((389, "Gentle Bloom Immersion Press", "Patrik Rolf 🇸🇪", "Ethiopia Sidama Washed", "Heirloom", "Washed", "French Press", "French Press", 95, "Medium-Coarse", 18, 300, 330, "Membasahi bubuk kopi dengan 60g air terlebih dahulu sebelum menuangkan sisa air agar degassing CO2 tuntas.", [
    (1, "Bloom 60g di Press", 30, 60), (2, "Tuang Sisa 240g", 25, 240), (3, "Steeping 4 Menit", 215, 0), (4, "Skim & Press Ringan", 60, 0)
]))
all_recipes.append((390, "Flores Bajawa Creamy Caramel Press", "Harison Chandra 🇮🇩", "Flores Bajawa Washed", "Kartika", "Washed", "French Press", "French Press", 91, "Coarse", 22, 340, 310, "Menghadirkan aroma kacang macadamia dan karamel legit yang terasa sangat lembut di lidah.", [
    (1, "Tuang 340g", 25, 340), (2, "Aduk 2x", 15, 0), (3, "Imersi 4 Menit", 210, 0), (4, "Plunge Santai", 60, 0)
]))

# --- MOKA POT (391-404) ---
all_recipes.append((391, "Bialetti Preheated Water Sweet Extraction", "James Hoffmann 🇬🇧", "Colombia Huila Supremo", "Caturra", "Washed", "Moka Pot", "Moka Pot", 98, "Fine-Medium (Antara Espresso & V60)", 18, 180, 180, "Mengisi ruang bawah teko dengan air yang sudah mendidih agar bubuk kopi tidak terpanggang lama di atas kompor.", [
    (1, "Isi Air Mendidih ke Katup Bawah", 20, 180), (2, "Pasang Corong Kopi (Rata No Tamp)", 20, 0), (3, "Panaskan Api Sedang-Kecil", 90, 0), (4, "Aliran Kuning Madu & Dinginkan Dasar Teko", 50, 0)
]))
all_recipes.append((392, "AeroPress Paper Filter Mod Moka Pot", "Scott Rao 🇺🇸", "Brazil Cerrado Natural", "Bourbon", "Natural", "Moka Pot", "Moka Pot", 98, "Fine", 16, 160, 165, "Menyelipkan 1 lembar kertas saring AeroPress di bawah filter logam atas untuk menyerap minyak berlebih dan menjernihkan rasa.", [
    (1, "Air Mendidih di Boiler", 20, 160), (2, "Pasang Kertas AeroPress Basah", 15, 0), (3, "Ekstraksi Api Kecil Stabil", 90, 0), (4, "Hentikan Saat Aliran Berbusa", 40, 0)
]))
all_recipes.append((393, "Low Heat Creamy Moka Espresso", "Dody Samsura 🇮🇩", "Toraja Sapan Minanga", "Typica", "Washed", "Moka Pot", "Moka Pot", 96, "Fine-Medium", 17, 170, 195, "Menggunakan api lilin paling kecil untuk menjaga kenaikan uap lambat dan menghasilkan konsentrat kental manis.", [
    (1, "Isi Air Panas", 20, 170), (2, "Tutup Rapat dengan Handuk", 20, 0), (3, "Pemanasan Api Sangat Kecil", 110, 0), (4, "Ekstraksi Mengalir Halus", 45, 0)
]))
all_recipes.append((394, "Iced Moka Americano Fresh Brew", "Lance Hedrick 🇺🇸", "Ethiopia Guji Natural", "Heirloom", "Natural", "Moka Pot", "Moka Pot", 98, "Fine", 18, 180, 170, "Hasil ekstraksi Moka Pot pekat langsung dituangkan ke atas 150g es batu dan sedikit air dingin untuk Iced Americano segar.", [
    (1, "Isi Air Panas", 20, 180), (2, "Ekstraksi Kompor", 90, 0), (3, "Siram Bawah Teko Air Dingin", 15, 0), (4, "Tuang ke Gelas Berisi Es", 45, 0)
]))
all_recipes.append((395, "Sumatra Spiced Velvet Moka Pot", "Pepeng (Klinik Kopi) 🇮🇩", "Sumatra Gayo Pantan Musara", "Ateng Super", "Washed", "Moka Pot", "Moka Pot", 95, "Fine-Medium", 18, 170, 180, "Rasa cokelat hitam pekat dengan rempah kapulaga dan gula aren alami, sangat nikmat diminum di pagi hari.", [
    (1, "Air Hangat di Tangki Bawah", 20, 170), (2, "Kopi Tanpa Ditekan", 20, 0), (3, "Kompor Api Sedang", 95, 0), (4, "Selesai Saat Suara Desis", 45, 0)
]))
all_recipes.append((396, "Moka Pot Latte Base Velvet", "Yoshua Tanu 🇮🇩", "House Blend Choco Caramel", "Brazil + Toraja", "Natural", "Moka Pot", "Moka Pot", 98, "Fine", 20, 180, 180, "Konsentrat 60ml yang diekstraksi sangat pekat untuk dicampur dengan 150ml susu panas berbusa (frother).", [
    (1, "Air Panas ke Katup Tekanan", 20, 180), (2, "Ratakan Bubuk Penuh", 20, 0), (3, "Ekstraksi Pekat", 85, 0), (4, "Campur ke Susu Hangat", 55, 0)
]))
all_recipes.append((397, "Brikka Double Valve Foam Crema", "Alessandro Galtieri (Italia)", "Italian Roast Arabica", "Catuai Blend", "Washed", "Moka Pot", "Moka Pot", 98, "Fine", 16, 120, 150, "Bialetti Brikka dengan katup berbobot menghasilkan tekanan ganda dan lapisan crema tebal layaknya mesin espresso.", [
    (1, "Isi Air Ukuran Brikka 120ml", 20, 120), (2, "Pasang Erat Teko", 20, 0), (3, "Api Sedang Sampai Katup Terbuka", 80, 0), (4, "Semburan Crema & Tuang Cepat", 30, 0)
]))
all_recipes.append((398, "High Altitude Geisha Moka Extraction", "Mikael Jasin 🇮🇩", "Panama Boquete Geisha", "Geisha", "Washed", "Moka Pot", "Moka Pot", 96, "Medium-Fine", 15, 160, 160, "Ekstraksi presisi dengan kompor induksi menjaga suhu uap tidak melompat, memunculkan aroma peach dan melati.", [
    (1, "Air Panas 160g", 20, 160), (2, "Bubuk Geisha Rata", 15, 0), (3, "Induksi Suhu Terkontrol", 85, 0), (4, "Bungkus Teko Kain Basah", 40, 0)
]))
all_recipes.append((399, "French Vanilla Sweet Moka Pot", "Ryan Wibawa 🇮🇩", "Flores Manggarai Washed", "Yellow Caturra", "Washed", "Moka Pot", "Moka Pot", 97, "Fine-Medium", 17, 170, 175, "Menghasilkan aftertaste lembut seperti kacang panggang dan vanilla tanpa aftertaste pahit di tenggorokan.", [
    (1, "Air Panas", 20, 170), (2, "Corong Terisi Rata", 15, 0), (3, "Pemanasan Pelan", 95, 0), (4, "Aliran Cokelat Mengkilap", 45, 0)
]))
all_recipes.append((400, "Cold Water Start Gentle Rise", "Asser Christensen 🇩🇰", "Guatemala Huehuetenango", "Bourbon", "Washed", "Moka Pot", "Moka Pot", 25, "Fine-Medium", 16, 160, 240, "Metode klasik air suhu ruang untuk mereka yang menyukai body lebih bulat dan rasa cokelat kayu manis tradisional.", [
    (1, "Isi Air Dingin ke Boiler", 15, 160), (2, "Bubuk Halus Sedang", 15, 0), (3, "Api Kecil Pemanasan Lambat", 160, 0), (4, "Ekstraksi Melandai", 50, 0)
]))
all_recipes.append((401, "Bali Citrus Sparkle Moka", "Muhammad Aga 🇮🇩", "Bali Kintamani Washed", "Kopyol", "Washed", "Moka Pot", "Moka Pot", 98, "Fine-Medium", 16, 160, 165, "Keasaman jeruk Kintamani berpadu manis dengan crema tipis dari ekstraksi uap air mendidih.", [
    (1, "Air Mendidih", 15, 160), (2, "Pasang Rapat", 15, 0), (3, "Api Kecil Sedang", 85, 0), (4, "Angkat Sebelum Menyembur Gas", 50, 0)
]))
all_recipes.append((402, "Dark Chocolate Molasses Stovetop", "Doddy Samsura 🇮🇩", "Java Frinsa Lactic Natural", "Andungsari", "Lactic Natural", "Moka Pot", "Moka Pot", 97, "Fine", 18, 175, 180, "Sangat tebal dan pekat dengan rasa pisang karamel dan cokelat hitam leleh di setiap seruputan.", [
    (1, "Air Panas", 15, 175), (2, "Isi Basket Penuh", 15, 0), (3, "Kompor Api Kecil", 95, 0), (4, "Penyelesaian Halus", 55, 0)
]))
all_recipes.append((403, "Precision Scale Moka Extraction", "Patrik Rolf 🇸🇪", "Kenya Nyeri Washed", "SL28", "Washed", "Moka Pot", "Moka Pot", 98, "Medium-Fine", 15, 150, 150, "Menimbang cairan yang keluar di teko atas di atas timbangan digital untuk menghentikan seduhan tepat di 100g cairan.", [
    (1, "Air Panas di Dasar", 15, 150), (2, "Timbang di Kompor Portable", 15, 0), (3, "Ekstraksi Berjalan", 80, 0), (4, "Stop di Bobot 100g", 40, 0)
]))
all_recipes.append((404, "Campfire Outdoor Moka Pot", "Harison Chandra 🇮🇩", "Papua Wamena Typica", "Typica", "Washed", "Moka Pot", "Moka Pot", 98, "Fine-Medium", 17, 170, 180, "Seduhan praktis di alam terbuka menggunakan kompor gas camping, menghasilkan cangkir hangat penuh aroma kayu manis.", [
    (1, "Air Panas Camping", 15, 170), (2, "Pasang Teko", 15, 0), (3, "Api Kompor Portable", 100, 0), (4, "Tuang ke Mug Enamel", 50, 0)
]))

# --- AEROPRESS (405-414) ---
all_recipes.append((405, "World AeroPress Champion Inverted Fast Press", "Tuomas Merikanto 🇫🇮", "Ethiopia Guji Washed", "Heirloom", "Washed", "AeroPress", "AeroPress", 85, "Medium-Fine", 18, 200, 100, "Resep juara dunia WAC dengan posisi inverted dan suhu rendah 85°C menghasilkan cangkir manis beraroma melati segar.", [
    (1, "Tuang Air 85°C 100g", 15, 100), (2, "Aduk Cepat 20 Detik", 20, 0), (3, "Tuang Sisa 100g", 15, 100), (4, "Balik & Press Lembut 30s", 50, 0)
]))
all_recipes.append((406, "Alan Adler Original 80°C Concentrate", "Alan Adler 🇺🇸", "Colombia Caturra", "Caturra", "Washed", "AeroPress", "AeroPress", 80, "Fine", 15, 120, 90, "Resep asli penemu AeroPress suhu 80°C; ekstrak pekat 120g lalu tambahkan air panas (bypass) sesuai selera ke cangkir.", [
    (1, "Tuang Air 80°C 120g", 15, 120), (2, "Aduk 10 Detik", 15, 0), (3, "Tekan Plunger Lembut", 25, 0), (4, "Bypass Air Panas Tambahan", 35, 100)
]))
all_recipes.append((407, "Prismo Espresso-Style High Crema", "Lance Hedrick 🇺🇸", "Guatemala Antigua Washed", "Bourbon", "Washed", "AeroPress", "AeroPress", 96, "Fine (Espresso)", 20, 60, 90, "Menggunakan katup Fellow Prismo bertekanan dengan filter logam untuk menghasilkan konsentrat espresso kental berbusa crema.", [
    (1, "Tuang Air 96°C 60g", 15, 60), (2, "Aduk Kuat 20 Detik", 20, 0), (3, "Diamkan 30 Detik", 30, 0), (4, "Press Kuat Maksimal", 25, 0)
]))
all_recipes.append((408, "Ultra-Long Immersion 10-Minute Gagné", "Jonathan Gagné 🇨🇦", "Kenya Nyeri Peaberry", "SL28", "Washed", "AeroPress", "AeroPress", 99, "Medium-Coarse", 15, 250, 600, "Metode imersi ultra-panjang 10 menit dengan air mendidih; fines mengendap alami menghasilkan ekstraksi sangat tinggi dan super jernih.", [
    (1, "Tuang Air Mendidih 250g", 25, 250), (2, "Pasang Plunger Ciptakan Vakum", 15, 0), (3, "Infusi Diam 9 Menit", 500, 0), (4, "Press Sangat Lembut 1 Menit", 60, 0)
]))
all_recipes.append((409, "Double Paper Filter Clean Body", "Tim Wendelboe 🇳🇴", "Colombia Huila Washed", "Caturra", "Washed", "AeroPress", "AeroPress", 95, "Medium-Fine", 14, 200, 120, "Dua lembar kertas saring yang dibilas air panas menyaring seluruh minyak untuk keasaman apel hijau dan kemurnian rasa.", [
    (1, "Tuang Air 200g", 15, 200), (2, "Aduk 3x Maju Mundur", 15, 0), (3, "Pasang Plunger Tahan Vakum", 60, 0), (4, "Tekan Santai 30s", 30, 0)
]))
all_recipes.append((410, "Japanese Iced AeroPress Flash Concentrate", "Mikael Jasin 🇮🇩", "Ethiopia Yirgacheffe Natural", "Heirloom", "Natural", "AeroPress", "Japanese Iced", 93, "Medium", 20, 140, 120, "Ekstraksi pekat inverted langsung ditekan ke atas 120g es batu di server untuk mengunci aroma buah stroberi.", [
    (1, "Inverted Tuang Air 140g", 15, 140), (2, "Aduk Cepat 15 Detik", 20, 0), (3, "Steep 45 Detik", 45, 0), (4, "Flip & Press ke Server Es", 40, 0)
]))
all_recipes.append((411, "Fine-Grind Bypass Sweet Americano", "Scott Rao 🇺🇸", "Brazil Fazenda Natural", "Mundo Novo", "Natural", "AeroPress", "AeroPress", 88, "Fine", 18, 100, 90, "Gilingan halus diekstrak singkat dengan 100g air suhu 88°C, lalu diencerkan dengan 120g air dingin untuk cangkir super manis bebas pahit.", [
    (1, "Tuang 100g Cepat", 15, 100), (2, "Aduk 10 Detik", 15, 0), (3, "Press Cepat", 25, 0), (4, "Tambahkan Bypass Water 120g", 35, 120)
]))
all_recipes.append((412, "Coarse Grind High Agitation", "James Hoffmann 🇬🇧", "Rwanda Washed Bourbon", "Red Bourbon", "Washed", "AeroPress", "AeroPress", 96, "Coarse", 16, 250, 180, "Gilingan kasar dengan pengadukan berulang-ulang untuk mengekstrak manis karamel dan keasaman jeruk tanpa rasa astringent.", [
    (1, "Tuang 250g", 20, 250), (2, "Aduk Kuat 20 Detik", 25, 0), (3, "Steep 1 Menit", 65, 0), (4, "Press Ringan", 70, 0)
]))
all_recipes.append((413, "Low-Temp Cold Water Aero Bloom", "Asser Christensen 🇩🇰", "Panama Geisha Natural", "Geisha", "Natural", "AeroPress", "AeroPress", 84, "Medium-Fine", 15, 220, 120, "Suhu 84°C menjaga keharuman bunga melati dan rasa buah mangga manis tidak rusak oleh suhu panas berlebih.", [
    (1, "Tuang 110g", 15, 110), (2, "Aduk Lembut", 15, 0), (3, "Tuang Sisa 110g", 15, 110), (4, "Press 40 Detik", 75, 0)
]))
all_recipes.append((414, "Sumatra Gayo Herbal Heavy Press", "Pepeng (Klinik Kopi) 🇮🇩", "Sumatra Gayo Wine", "Typica", "Wine Fermentation", "AeroPress", "AeroPress", 89, "Medium", 17, 200, 130, "Kopi Gayo diekstrak pada suhu 89°C menghasilkan rasa anggur fermentasi manis legit dengan sensasi rempah kayu manis halus.", [
    (1, "Tuang 200g Air 89°C", 20, 200), (2, "Aduk 15 Detik", 20, 0), (3, "Diamkan 45 Detik", 45, 0), (4, "Press Lembut Tuntas", 45, 0)
]))

# --- HARIO V60 (415-424) ---
all_recipes.append((415, "Metode 4:6 Kasuya Classic Competition", "Tetsu Kasuya 🇯🇵", "Ethiopia Guji Hambela", "Heirloom", "Natural", "Hario V60", "V60 Pour Over", 92, "Coarse", 20, 300, 210, "Resep legendaris juara dunia WBrC 2016: membagi air seduh menjadi 40% pengatur asam-manis dan 60% pengatur kepekatan body.", [
    (1, "Tuang 1 (Manis) 50g", 45, 50), (2, "Tuang 2 (Keasaman) 70g", 45, 70), (3, "Tuang 3 (Kekuatan) 60g", 45, 60), (4, "Tuang 4 (Kekuatan) 60g", 45, 60), (5, "Tuang 5 (Akhir) 60g", 30, 60)
]))
all_recipes.append((416, "Single Continuous Center Pour V60", "Matt Perger 🇦🇺", "Kenya Nyeri Washed", "SL28", "Washed", "Hario V60", "V60 Pour Over", 95, "Medium-Fine", 15, 250, 150, "Satu kali tuangan kontinyu di bagian pusat setelah blooming untuk efisiensi ekstraksi maksimal dan turbulensi merata.", [
    (1, "Bloom 45g & Swirl", 30, 45), (2, "Continuous Center Pour 205g", 65, 205), (3, "Rao Spin & Drawdown", 55, 0)
]))
all_recipes.append((417, "Osmotic Flow Gentle Center Drip", "Mirza Luqman 🇮🇩", "Toraja Sapan Washed", "Typica", "Washed", "Hario V60", "V60 Pour Over", 88, "Coarse", 18, 240, 195, "Aliran tetesan osmotik di pusat dome bubuk kopi tanpa membasahi dinding kertas, menghasilkan manis sirup yang sangat kental.", [
    (1, "Basahi Inti Kopi", 35, 30), (2, "Tetes Osmotik Pusat", 60, 90), (3, "Spiral Lambat", 50, 120), (4, "Angkat Dripper", 50, 0)
]))
all_recipes.append((418, "Rao Spin V60 Flat Bed Perfection", "Scott Rao 🇺🇸", "Colombia Narino Washed", "Caturra", "Washed", "Hario V60", "V60 Pour Over", 95, "Medium", 20, 340, 195, "Teknik swirl melingkar di akhir tuangan untuk memastikan permukaan bubuk kopi rata sempurna bebas high-and-dry grounds.", [
    (1, "Bloom 60g & Excavate", 45, 60), (2, "Main Pour 280g", 60, 280), (3, "Rao Spin & Drawdown", 90, 0)
]))
all_recipes.append((419, "5-Pour Rhythmic Percolation V60", "Harison Chandra 🇮🇩", "Panama Geisha Washed", "Geisha", "Washed", "Hario V60", "V60 Pour Over", 93, "Medium", 15, 250, 175, "Lima kali tuangan berirama 50g setiap 30 detik menjaga ketinggian slurry stabil untuk konsistensi ekstraksi sempurna.", [
    (1, "Bloom 50g", 30, 50), (2, "Pour 2 50g", 30, 50), (3, "Pour 3 50g", 30, 50), (4, "Pour 4 50g", 30, 50), (5, "Pour 5 50g", 55, 50)
]))
all_recipes.append((420, "Low-Temp High Agitation V60", "Doddy Samsura 🇮🇩", "Flores Bajawa Washed", "Kartika", "Washed", "Hario V60", "V60 Pour Over", 88, "Medium-Fine", 16, 240, 165, "Suhu 88°C dengan ketinggian cerat kettle tinggi untuk mengagitasi bubuk halus menghasilkan cangkir manis beraroma kacang madu.", [
    (1, "Bloom 40g", 30, 40), (2, "Tuang Agitasi Tinggi 100g", 40, 100), (3, "Tuang Penutup 100g", 40, 100), (4, "Drain", 55, 0)
]))
all_recipes.append((421, "Japanese Iced Concentric V60", "Chad Wang 🇹🇼", "Ethiopia Yirgacheffe Washed", "Kurume", "Washed", "Hario V60", "Japanese Iced", 94, "Medium-Fine", 18, 180, 150, "Konsentrat 180g air panas langsung mengucur di atas 120g es batu dalam server untuk Japanese iced beraroma jeruk nipis.", [
    (1, "Bloom 50g", 35, 50), (2, "Spiral 65g", 40, 65), (3, "Pusat 65g", 35, 65), (4, "Melt & Swirl", 40, 0)
]))
all_recipes.append((422, "Thermal Retention Metal V60", "Mikael Jasin 🇮🇩", "Java Frinsa Lactic Natural", "Andungsari", "Lactic Natural", "Hario V60", "V60 Pour Over", 92, "Medium", 16, 250, 170, "Menggunakan V60 stainless steel dengan konduksi panas stabil memunculkan karakter buah plum dan manis cokelat hitam.", [
    (1, "Bloom 50g", 35, 50), (2, "Tuang 100g", 45, 100), (3, "Tuang 100g", 40, 100), (4, "Drainage", 50, 0)
]))
all_recipes.append((423, "Melodrip Zero Bypass V60", "Elika Liftee 🇺🇸", "Kenya Kirinyaga SL28", "SL28", "Washed", "Hario V60", "V60 Pour Over", 95, "Fine", 15, 250, 200, "Menggunakan alat Melodrip untuk mendistribusikan tetesan air tanpa merusak lapisan bubuk kopi, bebas partikel terhambur.", [
    (1, "Bloom Kettle 45g", 40, 45), (2, "Melodrip Pour 105g", 60, 105), (3, "Melodrip Pour 100g", 50, 100), (4, "Drawdown Tuntas", 50, 0)
]))
all_recipes.append((424, "Everyday Sweet Comfort V60", "Dustin Wijaya 🇮🇩", "Bali Kintamani Washed", "Kopyol", "Washed", "Hario V60", "V60 Pour Over", 92, "Medium", 15, 230, 160, "Rasio 1:15.3 yang sangat ramah pemula, menghasilkan seduhan manis seimbang tanpa rasa pahit menyengat.", [
    (1, "Bloom 40g", 30, 40), (2, "Spiral 95g", 45, 95), (3, "Spiral 95g", 40, 95), (4, "Selesai", 45, 0)
]))

# --- KALITA WAVE (425-434) ---
all_recipes.append((425, "Kalita Wave 185 Flat Bed Clarity", "Mikaela Wallgren (Finlandia)", "Kenya Nyeri Hill", "SL28", "Washed", "Kalita Wave", "Flat Bottom", 94, "Medium", 15, 250, 180, "Tiga lubang kecil pada dasar rata Kalita Wave membatasi laju aliran, menciptakan perkolasi merata bebas channelling.", [
    (1, "Bloom 45g", 35, 45), (2, "Spiral Tengah 105g", 45, 105), (3, "Pusat 100g", 45, 100), (4, "Drawdown Rata", 55, 0)
]))
all_recipes.append((426, "Kalita Pulse Pour 5x Wave Technique", "Chad Wang 🇹🇼", "Ethiopia Sidama Washed", "Heirloom", "Washed", "Kalita Wave", "Flat Bottom", 93, "Medium", 16, 250, 195, "Lima kali tuangan kecil bertahap menjaga bed kopi tetap terendam rata dan menghasilkan aroma floral peach.", [
    (1, "Pulse 1 50g", 35, 50), (2, "Pulse 2 50g", 35, 50), (3, "Pulse 3 50g", 35, 50), (4, "Pulse 4 50g", 35, 50), (5, "Pulse 5 50g", 55, 50)
]))
all_recipes.append((427, "Kalita Hasami Ceramic High Sweetness", "James Hoffmann 🇬🇧", "Colombia Huila Washed", "Castillo", "Washed", "Kalita Wave", "Flat Bottom", 94, "Medium", 18, 300, 205, "Kalita Wave versi keramik Hasami mempertahankan suhu seduh tinggi untuk menghasilkan tekstur sirup gula tebu legit.", [
    (1, "Bloom 60g", 40, 60), (2, "Tuang 120g", 50, 120), (3, "Tuang 120g", 45, 120), (4, "Drawdown Tuntas", 70, 0)
]))
all_recipes.append((428, "Kalita Wave Japanese Iced Sweetness", "Hiro Lesmana 🇮🇩", "Bali Kintamani Washed", "Kopyol", "Washed", "Kalita Wave", "Japanese Iced", 94, "Medium-Fine", 18, 190, 160, "Ekstraksi pekat di dasar rata mengalir perlahan ke atas 110g es batu menghadirkan aroma jeruk keprok renyah.", [
    (1, "Bloom 50g", 35, 50), (2, "Spiral 70g", 40, 70), (3, "Pusat 70g", 40, 70), (4, "Swirl Es Server", 45, 0)
]))
all_recipes.append((429, "Kalita Single Pour Minimal Agitation", "Patrik Rolf 🇸🇪", "Guatemala Huehuetenango", "Bourbon", "Washed", "Kalita Wave", "Flat Bottom", 95, "Medium-Coarse", 16, 260, 175, "Satu kali tuangan perlahan tanpa membuat gelombang tinggi di dinding lipatan filter Kalita Wave.", [
    (1, "Bloom 50g", 35, 50), (2, "Continuous Pour Lembut 210g", 80, 210), (3, "Drain Tuntas", 60, 0)
]))
all_recipes.append((430, "Kalita Honey Process Caramel Body", "Ryan Wibawa 🇮🇩", "Java Frinsa Yellow Honey", "Sigararutang", "Yellow Honey", "Kalita Wave", "Flat Bottom", 92, "Medium", 15, 240, 180, "Dasar rata 3 lubang sangat ideal mengekstrak kekayaan gula proses honey tanpa khawatir over-ekstraksi.", [
    (1, "Bloom 45g", 35, 45), (2, "Spiral 100g", 45, 100), (3, "Pusat 95g", 45, 95), (4, "Drawdown", 55, 0)
]))
all_recipes.append((431, "Kalita Glass 155 Solo Cup", "Tetsu Kasuya 🇯🇵", "Panama Boquete Geisha", "Geisha", "Washed", "Kalita Wave", "Flat Bottom", 93, "Medium", 12, 190, 160, "Porsi cangkir tunggal dengan Kalita Wave kecil 155 menghasilkan konsentrasi rasa persik dan melati super tajam.", [
    (1, "Bloom 35g", 30, 35), (2, "Tuang 80g", 40, 80), (3, "Tuang 75g", 40, 75), (4, "Drain", 50, 0)
]))
all_recipes.append((432, "Kalita Low Agitation Chocolate Rich", "Scott Rao 🇺🇸", "Brazil Cerrado Natural", "Mundo Novo", "Natural", "Kalita Wave", "Flat Bottom", 93, "Medium", 18, 280, 195, "Ketinggian cerat rendah menjaga partikel halus tidak bermigrasi ke dasar filter, menghasilkan rasa cokelat praline bersih.", [
    (1, "Bloom 55g", 35, 55), (2, "Tuang Rendah 115g", 50, 115), (3, "Tuang Rendah 110g", 45, 110), (4, "Drainage", 65, 0)
]))
all_recipes.append((433, "Kalita Wave Double Bloom Extraction", "Lance Hedrick 🇺🇸", "Ethiopia Guji Washed", "Heirloom", "Washed", "Kalita Wave", "Flat Bottom", 94, "Medium-Fine", 15, 250, 190, "Dua kali blooming (40g + 40g) untuk memastikan seluruh inti bubuk kopi terhidrasi sempurna sebelum tuangan utama.", [
    (1, "Bloom 1 40g", 35, 40), (2, "Bloom 2 40g", 35, 40), (3, "Tuang Utama 170g", 55, 170), (4, "Finish Drawdown", 65, 0)
]))
all_recipes.append((434, "Sumatra Mandheling Sweet Herbal Wave", "Dody Samsura 🇮🇩", "Sumatra Mandheling Lintong", "Typica", "Wet Hulled", "Kalita Wave", "Flat Bottom", 90, "Medium-Coarse", 17, 250, 185, "Menjaga rasa rempah alami dan manis gula tebu tetap jernih tanpa rasa pahit astringent di lidah.", [
    (1, "Bloom 50g", 35, 50), (2, "Spiral Lembut 100g", 45, 100), (3, "Pusat 100g", 45, 100), (4, "Drawdown", 60, 0)
]))

# --- SYPHON (VACUUM POT) (435-444) ---
all_recipes.append((435, "Japanese Kissaten Master Syphon", "Taizo Iwasaki 🇯🇵", "Mandheling Lintong Grade 1", "Typica", "Wet Hulled", "Syphon", "Syphon", 95, "Medium", 20, 260, 180, "Seni seduh vakum klasik Jepang dengan kain flanel tradisional: air naik stabil, diaduk lembut seperti dayung perahu.", [
    (1, "Air Naik ke Tabung Atas", 40, 260), (2, "Masukkan Kopi & Paddle Stir 10x", 20, 0), (3, "Imersi Suhu Stabil 45s", 45, 0), (4, "Matikan Api (Vakum Menarik Turun)", 75, 0)
]))
all_recipes.append((436, "Clean Paper Filter Modern Syphon", "James Hoffmann 🇬🇧", "Kenya Nyeri Hill", "SL28", "Washed", "Syphon", "Syphon", 94, "Medium", 18, 250, 160, "Menggunakan adaptor filter kertas pada Syphon modern untuk kejernihan asam sitrat setajam pisau tanpa sisa bau kain.", [
    (1, "Air Terangkat ke Atas", 35, 250), (2, "Kopi Masuk & Aduk 2x Putaran", 15, 0), (3, "Ekstraksi Panas 40 Detik", 40, 0), (4, "Tarik Api & Drawdown Cepat", 70, 0)
]))
all_recipes.append((437, "Halogen Beam Heater Competition Syphon", "Chad Wang 🇹🇼", "Panama Boquete Geisha", "Geisha", "Washed", "Syphon", "Syphon", 93, "Medium-Fine", 15, 220, 150, "Pemanas halogen dengan kontrol cahaya presisi memunculkan aroma melati dan rasa buah persik super intens.", [
    (1, "Halogen Heat Rise", 35, 220), (2, "Infusi Kopi & Gentle Swirl", 15, 0), (3, "Ekstraksi Suhu 93°C Stabil", 40, 0), (4, "Drawdown Dome Bubuk Sempurna", 60, 0)
]))
all_recipes.append((438, "Rich Ethiopian Bergamot Vacuum Pot", "Mikael Jasin 🇮🇩", "Ethiopia Yirgacheffe Washed", "Heirloom", "Washed", "Syphon", "Syphon", 94, "Medium", 16, 240, 165, "Aroma bunga mekar dan teh bergamot yang sangat harum saat kopi tersedot turun ke labu kaca bulat bawah.", [
    (1, "Air Naik Penuh", 35, 240), (2, "Tuang Bubuk & Cross Stir", 20, 0), (3, "Steep Panas 45 Detik", 45, 0), (4, "Drawdown Vacuum", 65, 0)
]))
all_recipes.append((439, "Sweet Chocolate Bourbon Syphon", "Yoshua Tanu 🇮🇩", "Guatemala Antigua Washed", "Bourbon", "Washed", "Syphon", "Syphon", 93, "Medium", 18, 260, 175, "Tekstur sangat halus dan bulat dengan rasa cokelat susu dan karamel mentega yang sangat memuaskan.", [
    (1, "Air Terangkat", 35, 260), (2, "Kopi Masuk & Aduk Rata", 20, 0), (3, "Steeping Panas 45s", 45, 0), (4, "Turun ke Bola Kaca", 75, 0)
]))
all_recipes.append((440, "Cloth Filter Silk Body Syphon", "Doddy Samsura 🇮🇩", "Java Frinsa Washed", "Andungsari", "Washed", "Syphon", "Syphon", 92, "Medium", 17, 250, 170, "Filter kain yang dirawat dengan baik memberikan rasa sutra di lidah dan aroma rempah manis alami.", [
    (1, "Pemanasan Air", 35, 250), (2, "Aduk Bubuk Kopi", 20, 0), (3, "Infusi 40 Detik", 40, 0), (4, "Vakum Menghisap", 75, 0)
]))
all_recipes.append((441, "Fast Drawdown High Acid Vacuum", "Patrik Rolf 🇸🇪", "Rwanda Nyamasheke", "Red Bourbon", "Washed", "Syphon", "Syphon", 95, "Medium-Coarse", 15, 220, 140, "Gilingan sedikit lebih kasar untuk mempercepat proses turunnya kopi, menjaga rasa buah kranberi segar berkilau.", [
    (1, "Water Up", 30, 220), (2, "Stir 2x", 15, 0), (3, "Steep 35s", 35, 0), (4, "Rapid Vacuum Drop", 60, 0)
]))
all_recipes.append((442, "Bali Tropical Fruit Syphon Infusion", "Muhammad Aga 🇮🇩", "Bali Kintamani Washed", "Kopyol", "Washed", "Syphon", "Syphon", 93, "Medium", 16, 240, 165, "Keserbagunaan Syphon memunculkan aroma jeruk nipis dan mangga muda yang segar di labu kaca.", [
    (1, "Air Naik", 35, 240), (2, "Kopi Masuk & Aduk Melingkar", 15, 0), (3, "Infusi 45 Detik", 45, 0), (4, "Vacuum Finish", 70, 0)
]))
all_recipes.append((443, "Double Stir Vacuum Technique", "Scott Rao 🇺🇸", "Colombia Huila Washed", "Caturra", "Washed", "Syphon", "Syphon", 94, "Medium", 18, 270, 180, "Dua kali pengadukan: adukan pertama saat kopi masuk, dan adukan kedua 10 detik sebelum api dimatikan untuk formasi dome.", [
    (1, "Water Up", 35, 270), (2, "Initial Stir", 15, 0), (3, "Steep 35s & Final Stir", 45, 0), (4, "Dome Formation Drop", 85, 0)
]))
all_recipes.append((444, "Low Temperature Gentle Syphon", "Asser Christensen 🇩🇰", "Costa Rica White Honey", "Catuai", "White Honey", "Syphon", "Syphon", 89, "Medium-Fine", 16, 230, 170, "Mengatur api pembakar seminimal mungkin agar suhu ekstraksi atas tidak melebihi 89°C demi kelembutan rasa madu.", [
    (1, "Air Naik & Redupkan Api", 40, 230), (2, "Stir Lembut", 15, 0), (3, "Infusi Suhu Redup 40s", 40, 0), (4, "Kain Basah di Bola Bawah", 75, 0)
]))

# --- COLD BREW & COLD DRIP (445-450) ---
all_recipes.append((445, "Kyoto Slow Drip Tower Cold Extraction", "Yuma Kawano 🇯🇵", "Ethiopia Yirgacheffe Natural", "Heirloom", "Natural", "Cold Brew", "Cold Brew", 20, "Medium-Coarse", 40, 450, 480, "Satu tetes setiap 1.5 detik melalui menara kaca Kyoto Drip selama 6 jam menghasilkan konsentrat seperti minuman anggur anggun.", [
    (1, "Basahi Bubuk di Kolom Drip", 30, 50), (2, "Pasang Kertas Saring Atas", 15, 0), (3, "Atur Katup Tetes 1 Tetes/Detik", 375, 400), (4, "Penyelesaian Labu Spiral", 60, 0)
]))
all_recipes.append((446, "Toddy Style 16-Hour Smooth Concentrate", "James Hoffmann 🇬🇧", "Brazil Cerrado Natural", "Bourbon", "Natural", "Cold Brew", "Cold Brew", 20, "Coarse", 100, 700, 600, "Ekstraksi dingin imersi 16 jam tanpa keasaman pahit, sangat manis legit untuk disajikan dengan susu oat atau air soda.", [
    (1, "Masukkan Kopi ke Wadah Saring", 30, 0), (2, "Tuang Air Dingin Tersaring 700g", 30, 700), (3, "Imersi Suhu Ruang 16 Jam", 480, 0), (4, "Buka Stopper & Teteskan", 60, 0)
]))
all_recipes.append((447, "Nitro Cold Brew Velvety Cascade", "Scott Rao 🇺🇸", "Colombia Narino Washed", "Caturra", "Washed", "Cold Brew", "Cold Brew", 4, "Coarse", 80, 600, 540, "Cold brew pekat yang diinjeksi gas nitrogen bertekanan tinggi menghasilkan efek cascade ombak dan tekstur krim Guinness.", [
    (1, "Steeping Air Es 14 Jam", 420, 600), (2, "Double Filtration", 60, 0), (3, "Injeksi Nitrogen Dispenser", 60, 0)
]))
all_recipes.append((448, "Flash Cold Brew with Orange Peel", "Mikael Jasin 🇮🇩", "Bali Kintamani Washed", "Kopyol", "Washed", "Cold Brew", "Cold Brew", 20, "Coarse", 50, 400, 480, "Ditambahkan sedikit kulit jeruk segar pada saat imersi dingin untuk mengangkat karakter sitrus alami kopi Kintamani.", [
    (1, "Campur Bubuk Kopi & Kulit Jeruk", 20, 0), (2, "Tuang Air Dingin 400g", 25, 400), (3, "Imersi Dingin 12 Jam", 375, 0), (4, "Saring Kertas Halus", 60, 0)
]))
all_recipes.append((449, "Sumatra Dark Cocoa Cold Drip", "Doddy Samsura 🇮🇩", "Sumatra Gayo Natural", "Ateng Super", "Natural", "Cold Brew", "Cold Brew", 20, "Medium-Coarse", 45, 450, 480, "Tetesan lambat air es memunculkan rasa cokelat pahit manis, kismis hitam, dan rempah kayu manis tanpa keasaman lambung.", [
    (1, "Basahi Kolom Ekstraksi", 25, 50), (2, "Pasang Kertas Saring", 15, 0), (3, "Tetesan Air Es Bertahap", 380, 400), (4, "Selesai di Botol Kaca", 60, 0)
]))
all_recipes.append((450, "Coconut Water Cold Brew Infusion", "Ryan Wibawa 🇮🇩", "Flores Bajawa Washed", "Kartika", "Washed", "Cold Brew", "Cold Brew", 4, "Coarse", 40, 350, 480, "Mengganti air biasa dengan air kelapa muda segar untuk imersi dingin 10 jam di kulkas, super segar dan manis alami.", [
    (1, "Bubuk Kopi di Wadah Kaca", 20, 0), (2, "Tuang Air Kelapa Murni 350g", 25, 350), (3, "Imersi Kulkas 10 Jam", 375, 0), (4, "Saring & Tuang ke Es Batu", 60, 0)
]))

print(f"Total new recipes generated: {len(all_recipes)}")

# Now write them into 10 files: seeds_part_12.dart to seeds_part_21.dart (15 recipes each!)
for file_idx in range(10):
    part_num = file_idx + 12
    batch = all_recipes[file_idx * 15 : (file_idx + 1) * 15]
    
    start_id = batch[0][0]
    end_id = batch[-1][0]
    
    code = f"// SEED RECIPES PART {part_num} ({start_id} - {end_id})\n\n"
    code += f"List<Map<String, dynamic>> getSeedsPart{part_num}(String now) => [\n"
    
    formatted_recipes = []
    for r in batch:
        formatted_recipes.append(make_recipe(
            r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14]
        ))
    
    code += ",\n".join(formatted_recipes)
    code += "\n];\n"
    
    file_path = os.path.join(OUTPUT_DIR, f"seeds_part_{part_num}.dart")
    with open(file_path, "w", encoding="utf-8") as f:
        f.write(code)
    
    line_count = len(code.split("\n"))
    print(f"Written seeds_part_{part_num}.dart with {len(batch)} recipes ({line_count} lines)")

print("All 10 seed parts written successfully!")
