import os

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

recipes = []

# --- BEE HOUSE DRIPPER (301-310) ---
recipes.append((301, "Bee House Dual-Hole Golden Balance", "Tetsu Kasuya 🇯🇵", "Ethiopia Guji Hambela", "Heirloom", "Washed", "Bee House Dripper", "Cone", 93, "Medium", 16, 250, 180, "Metode seduh Bee House klasik dua lubang untuk aliran terkontrol dan rasa peach manis seimbang.", [
    (1, "Blooming", 35, 45), (2, "Tuang Tengah Perlahan", 45, 105), (3, "Tuang Spiral Konsisten", 45, 100), (4, "Drawdown Tuntas", 55, 0)
]))
recipes.append((302, "Bee House Slow Infusion Sweetness", "James Hoffmann 🇬🇧", "Colombia Huila Supremo", "Caturra / Castillo", "Washed", "Bee House Dripper", "Cone", 94, "Medium-Fine", 18, 280, 195, "Ekstraksi bertahap memanfaatkan retensi panas keramik Bee House untuk cangkir kaya karamel.", [
    (1, "Blooming Rata", 40, 55), (2, "Tuang Utama Lembut", 50, 125), (3, "Tuang Penutup & Swirl", 50, 100), (4, "Tetesan Akhir", 55, 0)
]))
recipes.append((303, "Bee House Kissaten Traditional Brew", "Taizo Iwasaki 🇯🇵", "Mandheling Lintong Grade 1", "Typica", "Wet Hulled (Giling Basah)", "Bee House Dripper", "Cone", 88, "Medium-Coarse", 20, 260, 210, "Gaya kedai kopi tradisional Jepang (Kissaten) dengan tetesan osmotik lembut menghasilkan body tebal syrupy.", [
    (1, "Pre-wetting Inti", 45, 40), (2, "Tetesan Konsentris", 60, 110), (3, "Tuang Melingkar Stabil", 50, 110), (4, "Angkat Dripper", 55, 0)
]))
recipes.append((304, "Bee House Bright Acidity Floral", "Patrik Rolf 🇸🇪", "Kenya Nyeri Peaberry", "SL28 / SL34", "Double Washed", "Bee House Dripper", "Cone", 95, "Medium", 15, 240, 165, "Aliran cepat pada corong wedge keramik menjaga keasaman sitrus blackcurrant tetap menyala cerah.", [
    (1, "Bloom Cepat 50g", 30, 50), (2, "Tuang Tengah 100g", 40, 100), (3, "Tuang Akhir 90g", 40, 90), (4, "Finish", 55, 0)
]))
recipes.append((305, "Bee House Natural Fruit Punch", "Mikael Jasin 🇮🇩", "Java Frinsa Lactic Natural", "Andungsari / Sigararutang", "Lactic Natural", "Bee House Dripper", "Cone", 92, "Medium", 16, 250, 185, "Menonjolkan profil stroberi matang dan madu dengan retensi panas konsisten pada keramik Bee House.", [
    (1, "Bloom Melingkar", 35, 50), (2, "Tuang Kedua Bertahap", 45, 100), (3, "Tuang Akhir Pusat", 45, 100), (4, "Drain", 60, 0)
]))
recipes.append((306, "Bee House Low Agitation Clarity", "Lance Hedrick 🇺🇸", "Panama Boquete Geisha", "Green Tip Geisha", "Washed", "Bee House Dripper", "Cone", 93, "Medium-Coarse", 15, 250, 175, "Agitasi sangat rendah dari cerat rendah untuk menjaga kejernihan melati dan bergamot khas geisha.", [
    (1, "Bloom 45g", 40, 45), (2, "Tuang Lembut 105g", 50, 105), (3, "Tuang Lembut 100g", 45, 100), (4, "Drain", 40, 0)
]))
recipes.append((307, "Bee House Single Pour Steady Stream", "Matt Winton 🇨🇭", "Guatemala Antigua Los Volcanes", "Bourbon", "Washed", "Bee House Dripper", "Cone", 94, "Medium", 17, 270, 180, "Teknik satu kali tuang kontinyu setelah blooming, memanfaatkan sudut kemiringan dinding wedge.", [
    (1, "Blooming", 35, 50), (2, "Continuous Pour", 90, 220), (3, "Drawdown Stabil", 55, 0)
]))
recipes.append((308, "Bee House Iced Wedge Extraction", "Yoshua Tanu 🇮🇩", "Bali Kintamani Washed Carbonic", "Kopyol", "Anaerobic Washed", "Bee House Dripper", "Japanese Iced", 94, "Medium-Fine", 18, 200, 160, "Ekstraksi pekat konsentrat di atas 100g es batu dalam server untuk Japanese iced segar nan renyah.", [
    (1, "Bloom Ekstra 60g", 40, 60), (2, "Tuang Pekat 70g", 40, 70), (3, "Tuang Penutup 70g", 40, 70), (4, "Melt & Swirl", 40, 0)
]))
recipes.append((309, "Bee House Honey Process Sweet Cup", "Space Roastery 🇮🇩", "Sumatra Kerinci Red Honey", "Typica / Andung Sari", "Red Honey", "Bee House Dripper", "Cone", 91, "Medium", 16, 240, 190, "Profil manis nektarin dan kismis merah dengan suhu 91°C ramah untuk proses honey.", [
    (1, "Bloom Rata", 35, 45), (2, "Tuang Spiral 95g", 45, 95), (3, "Tuang Tengah 100g", 50, 100), (4, "Finish", 60, 0)
]))
recipes.append((310, "Bee House Daily Office Comfort", "Ryan Wibawa 🇮🇩", "Flores Bajawa Gunung Inerie", "Kartika", "Semi-Washed", "Bee House Dripper", "Cone", 92, "Medium", 15, 230, 170, "Resep harian anti-gagal dengan toleransi seduh tinggi berkat 2 lubang dasar Bee House yang konsisten.", [
    (1, "Bloom 45g", 30, 45), (2, "Tuang 95g", 45, 95), (3, "Tuang Akhir 90g", 45, 90), (4, "Drawdown", 50, 0)
]))

# --- BONMAC DRIPPER (311-320) ---
recipes.append((311, "Bonmac Single-Hole Classic Pour", "Dody Samsura 🇮🇩", "Toraja Sapan Minanga", "Toraja Sapan", "Washed", "Bonmac Dripper", "Cone", 93, "Medium-Coarse", 16, 250, 195, "Satu lubang kecil pada Bonmac memperlambat aliran secara alami, memaksimalkan ekstraksi rempah manis.", [
    (1, "Blooming Dalam", 40, 45), (2, "Tuangan Utama Konsentris", 50, 105), (3, "Tuangan Kedua Menjaga Level", 45, 100), (4, "Drawdown Tuntas", 60, 0)
]))
recipes.append((312, "Bonmac Full Body Chocolate Molasses", "Scott Rao 🇺🇸", "Brazil Cerrado Mineiro", "Mundo Novo", "Natural", "Bonmac Dripper", "Cone", 94, "Medium", 18, 280, 210, "Menghasilkan cangkir berkekuatan penuh dengan cokelat hitam pekat dan sirup molase tanpa astringensi.", [
    (1, "Bloom Rata 60g", 45, 60), (2, "Poured Wave 110g", 50, 110), (3, "Final Flush 110g", 50, 110), (4, "Drain", 65, 0)
]))
recipes.append((313, "Bonmac Precision Flow Calibration", "Hiro Lesmana 🇮🇩", "Rwanda Nyamasheke", "Red Bourbon", "Washed", "Bonmac Dripper", "Cone", 93, "Medium", 15, 240, 185, "Kalibrasi tinggi air pada dinding wedge Bonmac untuk menghasilkan kejernihan black tea dan jeruk nipis.", [
    (1, "Blooming", 35, 45), (2, "Tuangan Bertahap 95g", 45, 95), (3, "Tuangan Akhir 100g", 45, 100), (4, "Drawdown", 60, 0)
]))
recipes.append((314, "Bonmac Low-Temp Sweet Honey", "Asser Christensen 🇩🇰", "Costa Rica Tarrazu White Honey", "Catuai", "White Honey", "Bonmac Dripper", "Cone", 89, "Medium-Fine", 16, 250, 190, "Suhu rendah 89°C mengimbangi waktu kontak panjang dari lubang tunggal Bonmac agar manis madu tetap murni.", [
    (1, "Bloom 50g", 40, 50), (2, "Tuang Tengah 100g", 45, 100), (3, "Tuang Penutup 100g", 45, 100), (4, "Finish", 60, 0)
]))
recipes.append((315, "Bonmac Kissaten Style Thick Extraction", "Yuma Kawano 🇯🇵", "Sumatra Gayo Pantan Musara", "Ateng Super", "Washed", "Bonmac Dripper", "Cone", 87, "Medium-Coarse", 20, 240, 220, "Tekstur kental layaknya mentega cair dengan ekstraksi tetes demi tetes gaya bar Jepang.", [
    (1, "Tetes Awal", 45, 30), (2, "Spiral Pelan 100g", 65, 100), (3, "Pusat 110g", 55, 110), (4, "Stop Ekstraksi", 55, 0)
]))

recipes.append((316, "Bonmac 3-Pulse Dynamic Extraction", "Chad Wang 🇹🇼", "Ethiopia Yirgacheffe Idido", "Kurume", "Natural", "Bonmac Dripper", "Cone", 93, "Medium", 15, 240, 180, "Tiga kali tuangan terukur untuk memisahkan keasaman buah beri di awal dan rasa manis di akhir.", [
    (1, "Pulse 1 Bloom", 35, 45), (2, "Pulse 2 95g", 45, 95), (3, "Pulse 3 100g", 45, 100), (4, "Drain", 55, 0)
]))
recipes.append((317, "Bonmac Heavy Body Java Arabica", "Pepeng (Klinik Kopi) 🇮🇩", "Java Manglayang Karlina", "Typica", "Semi-Washed", "Bonmac Dripper", "Cone", 90, "Medium-Coarse", 17, 250, 200, "Seduhan santai tanpa agitasi berlebihan; lubang tunggal Bonmac menciptakan tahanan air alami yang ideal.", [
    (1, "Basahi Lembut", 40, 50), (2, "Tuang Memutar Santai", 60, 100), (3, "Tuang Akhir Tengah", 45, 100), (4, "Drawdown Alami", 55, 0)
]))
recipes.append((318, "Bonmac Iced Stone Fruit Burst", "Melvin (Fugol Coffee) 🇮🇩", "Aceh Gayo Anaerobic Washed", "Abyssinia", "Anaerobic Washed", "Bonmac Dripper", "Japanese Iced", 94, "Medium-Fine", 18, 190, 165, "Pekat dan jernih, mengalir lambat di atas 110g es batu menghadirkan aroma persik dan aprikot.", [
    (1, "Bloom 50g", 35, 50), (2, "Tuang 70g Lambat", 45, 70), (3, "Tuang 70g Akhir", 40, 70), (4, "Melt & Serve", 45, 0)
]))
recipes.append((319, "Bonmac Smooth Morning Cup", "Bayu Prawiro 🇮🇩", "Papua Wamena Kurima", "Typica", "Washed", "Bonmac Dripper", "Cone", 92, "Medium", 15, 230, 180, "Sangat lembut dan bersahabat di lambung dengan rasa cokelat susu dan kacang kenari panggang.", [
    (1, "Bloom 40g", 30, 40), (2, "Tuang 95g", 50, 95), (3, "Tuang 95g", 45, 95), (4, "Drain", 55, 0)
]))
recipes.append((320, "Bonmac Ultra-Clean Single Origin", "Odd-Steinar Tøllefsen 🇳🇴", "Kenya Kirinyaga SL28", "SL28", "Washed", "Bonmac Dripper", "Cone", 95, "Medium", 16, 260, 190, "Menggunakan filter Bonmac putih tebal untuk menyaring sedimen dan menonjolkan kecerahan asam sitrat.", [
    (1, "Bloom 50g", 35, 50), (2, "Spiral Utama 110g", 50, 110), (3, "Pusat Rata 100g", 45, 100), (4, "Drawdown", 60, 0)
]))

# --- CHEMEX (321-332) ---
recipes.append((321, "Chemex Classic Bonded Clarity", "James Hoffmann 🇬🇧", "Ethiopia Sidama Bensa", "Heirloom", "Washed", "Chemex", "Cone", 94, "Medium-Coarse", 30, 500, 240, "Filter tebal Chemex menyaring seluruh minyak dan partikel mikro, menghasilkan kejernihan cangkir seperti teh.", [
    (1, "Bloom Luas 80g", 45, 80), (2, "Tuangan Spiral Pertama 220g", 60, 220), (3, "Tuangan Pusat Penjaga Level 200g", 60, 200), (4, "Drawdown Tuntas", 75, 0)
]))
recipes.append((322, "Chemex Batch Brew for Two", "Scott Rao 🇺🇸", "Colombia Narino Especial", "Caturra", "Washed", "Chemex", "Cone", 95, "Coarse", 36, 600, 270, "Porsi 2 cangkir besar dengan aliran stabil dan swirl lembut di menit ke-2 untuk meratakan bed bubuk kopi.", [
    (1, "Bloom 100g & Swirl", 45, 100), (2, "Tuang 250g Melingkar", 65, 250), (3, "Tuang 250g Akhir & Swirl Ringan", 65, 250), (4, "Drainage", 95, 0)
]))
recipes.append((323, "Chemex Nordic Bright Jasmine", "Tim Wendelboe 🇳🇴", "Kenya Nyeri Hill Farm", "SL28", "Washed", "Chemex", "Cone", 96, "Medium-Coarse", 24, 400, 210, "Profil Nordic yang cerah dengan aroma melati dan rasa buah kismis merah super bersih.", [
    (1, "Bloom 60g", 35, 60), (2, "Tuang Kontinyu 180g", 55, 180), (3, "Tuang Pusat 160g", 50, 160), (4, "Finish", 70, 0)
]))
recipes.append((324, "Chemex Iced Summer Sparkle", "Mikael Jasin 🇮🇩", "Ethiopia Guji Uraga Natural", "Heirloom", "Natural", "Chemex", "Japanese Iced", 94, "Medium", 30, 320, 200, "Ekstraksi pekat Chemex langsung mengucur ke atas 180g es kristal di bagian bawah labu kaca piramida.", [
    (1, "Bloom 80g", 40, 80), (2, "Tuang 120g Perlahan", 50, 120), (3, "Tuang 120g Akhir", 50, 120), (4, "Swirl Es Kaca", 60, 0)
]))
recipes.append((325, "Chemex Sweet Citrus Sunrise", "Elika Liftee 🇺🇸", "Guatemala Huehuetenango", "Bourbon", "Washed", "Chemex", "Cone", 93, "Medium-Coarse", 25, 400, 215, "Perpaduan rasa jeruk keprok dan cokelat susu dengan aftertaste bersih berkepanjangan.", [
    (1, "Bloom 60g", 40, 60), (2, "Tuang 170g", 55, 170), (3, "Tuang 170g", 55, 170), (4, "Drain", 65, 0)
]))
recipes.append((326, "Chemex Double Filter Zero Sedimen", "Jonathan Gagné 🇨🇦", "Panama Geisha Boquete", "Geisha", "Washed", "Chemex", "Cone", 95, "Coarse", 20, 340, 210, "Menggunakan double bonded paper filter untuk memblokir seluruh partikel fines dan mencicipi profil murni terroir.", [
    (1, "Bloom 60g", 45, 60), (2, "Gentle Center Pour 140g", 55, 140), (3, "Gentle Center Pour 140g", 50, 140), (4, "Tuntas", 60, 0)
]))
recipes.append((327, "Chemex Honey Process Silk Body", "John Christopher 🇮🇩", "Costa Rica Aquiares Estate", "Esperanza", "Honey", "Chemex", "Cone", 92, "Medium-Coarse", 25, 380, 210, "Kekentalan sutra dan manis buah ara yang berpadu dengan keanggunan labu kaca Chemex.", [
    (1, "Bloom 60g", 35, 60), (2, "Spiral 160g", 55, 160), (3, "Pusat 160g", 50, 160), (4, "Drawdown", 70, 0)
]))
recipes.append((328, "Chemex Large Family Sharing 8-Cup", "Scott Rao 🇺🇸", "Brazil Fazenda Dutra", "Catucai", "Pulped Natural", "Chemex", "Cone", 94, "Coarse", 45, 750, 300, "Resep kapasitas besar untuk 4-5 cangkir, gilingan kasar menjaga waktu seduh di bawah 5 menit.", [
    (1, "Bloom 120g", 50, 120), (2, "Tuang Utama 330g", 75, 330), (3, "Tuang Akhir 300g", 75, 300), (4, "Tetesan Akhir", 100, 0)
]))
recipes.append((329, "Chemex Delicate Floral Bergamot", "Patrik Rolf 🇸🇪", "Ethiopia Gedeb Gotiti", "Yirgacheffe Local", "Washed", "Chemex", "Cone", 95, "Medium-Coarse", 22, 360, 195, "Suhu tinggi pada gilingan kasar menghasilkan aroma Earl Grey tea dan keasaman lemon cerah.", [
    (1, "Bloom 60g", 35, 60), (2, "Tuang Cepat 150g", 45, 150), (3, "Tuang Cepat 150g", 45, 150), (4, "Drawdown", 70, 0)
]))
recipes.append((330, "Chemex Rich Dark Cherry Profile", "Ryan Wibawa 🇮🇩", "Bali Kintamani Anaerobic Honey", "Kopyol", "Anaerobic Honey", "Chemex", "Cone", 92, "Medium-Coarse", 25, 400, 220, "Nuansa ceri hitam matang dan vanilla dengan tekstur velvet berkat penyaringan bonded filter tebal.", [
    (1, "Bloom 65g", 40, 65), (2, "Tuang 170g", 55, 170), (3, "Tuang 165g", 55, 165), (4, "Finish", 70, 0)
]))
recipes.append((331, "Chemex Afternoon Tea Style", "Du Jianing 🇨🇳", "Kenya Nyeri Gaturiri", "SL28 / SL34", "Washed", "Chemex", "Cone", 94, "Medium-Coarse", 20, 320, 190, "Cangkir bening berkilau keemasan dengan aftertaste blackcurrant dan madu liar yang tahan lama.", [
    (1, "Bloom 50g", 35, 50), (2, "Tuang 135g", 45, 135), (3, "Tuang 135g", 45, 135), (4, "Drain", 65, 0)
]))
recipes.append((332, "Chemex Sweet Bourbon Chocolate", "Harison Chandra 🇮🇩", "Flores Manggarai Yellow Caturra", "Yellow Caturra", "Washed", "Chemex", "Cone", 93, "Medium-Coarse", 24, 380, 205, "Manis cokelat susu karamel dan jambu biji putih dengan ekstraksi bersih tanpa rasa pahit residu.", [
    (1, "Bloom 60g", 40, 60), (2, "Tuang 160g", 50, 160), (3, "Tuang 160g", 50, 160), (4, "Finish", 65, 0)
]))

# --- CLEVER DRIPPER (333-342) ---
recipes.append((333, "Clever Dripper Water-First Immersion", "James Hoffmann 🇬🇧", "Colombia Huila Pitalito", "Caturra", "Washed", "Clever Dripper", "Immersion", 95, "Medium-Coarse", 15, 250, 180, "Air dituangkan terlebih dahulu sebelum bubuk kopi untuk mencegah clogging pada filter dan mempercepat drawdown.", [
    (1, "Tuang Air Panas Dulu", 20, 250), (2, "Masukkan Bubuk & Stir Lembut", 25, 0), (3, "Imersi Tutup Rapat", 75, 0), (4, "Letakkan di Server (Drawdown)", 60, 0)
]))
recipes.append((334, "Clever Full Steep Sweet Syrup", "Scott Rao 🇺🇸", "Guatemala San Antonio Huista", "Catuai", "Washed", "Clever Dripper", "Immersion", 96, "Medium", 18, 300, 240, "Imersi total 3 menit menghasilkan body tebal manis tanpa risiko over-ekstraksi channelling.", [
    (1, "Bloom & Basahi Rata", 30, 60), (2, "Tuang Sisa Air 240g", 30, 240), (3, "Imersi Penuh (Tutup)", 120, 0), (4, "Rilis Katup Drawdown", 60, 0)
]))
recipes.append((335, "Clever Natural Fruit Infusion", "Mikael Jasin 🇮🇩", "Ethiopia Sidama Bensa Natural", "Heirloom", "Natural", "Clever Dripper", "Immersion", 92, "Medium", 16, 260, 210, "Menonjolkan aroma bluberi dan anggur fermentasi dengan kejernihan filter kertas dan body imersi.", [
    (1, "Tuang Air 260g", 25, 260), (2, "Sendok Kopi & Aduk 2x", 20, 0), (3, "Steep Santai", 105, 0), (4, "Release ke Server", 60, 0)
]))
recipes.append((336, "Clever Fast Drawdown Clarity", "Patrik Rolf 🇸🇪", "Kenya Embu Muramuki", "SL28", "Washed", "Clever Dripper", "Immersion", 94, "Medium-Coarse", 15, 250, 180, "Gilingan medium-coarse memastikan pelepasan katup berlangsung di bawah 45 detik untuk hasil super bersih.", [
    (1, "Tuang Air 250g", 20, 250), (2, "Add Coffee & Submerge", 20, 0), (3, "Steeping", 95, 0), (4, "Fast Drawdown", 45, 0)
]))
recipes.append((337, "Clever Iced Flash Steep", "Lance Hedrick 🇺🇸", "Kenya Kirinyaga Peaberry", "SL34", "Washed", "Clever Dripper", "Japanese Iced", 95, "Medium-Fine", 18, 180, 160, "Imersi pekat 2 menit lalu langsung dirilis ke dalam server berisi 120g es batu murni.", [
    (1, "Air 180g ke Dripper", 15, 180), (2, "Kopi Masuk & Aduk", 20, 0), (3, "Steeping Pekat", 85, 0), (4, "Release ke Server Es", 40, 0)
]))
recipes.append((338, "Clever Long Steep Low Agitation", "Jonathan Gagné 🇨🇦", "Ethiopia Yirgacheffe Chelchele", "Kurume", "Washed", "Clever Dripper", "Immersion", 93, "Medium", 15, 250, 270, "Imersi panjang 4 menit memanfaatkan sedimentasi alami partikel fines ke dasar wadah.", [
    (1, "Tuang Air Panas 250g", 20, 250), (2, "Kopi Tabur & Crust Dip", 25, 0), (3, "Sedimentasi Alami", 165, 0), (4, "Release Drawdown", 60, 0)
]))
recipes.append((339, "Clever Sumatra Sweet Herbal", "Dody Samsura 🇮🇩", "Sumatra Lintong Nihuta", "Lasuna", "Wet Hulled", "Clever Dripper", "Immersion", 89, "Medium-Coarse", 17, 270, 210, "Menjinakkan rasa earthy pada kopi Sumatra dan memunculkan manis kayu manis dan dark chocolate.", [
    (1, "Tuang 270g Air 89°C", 25, 270), (2, "Masukkan Kopi & Stir", 25, 0), (3, "Steep Tutup", 100, 0), (4, "Buka Katup Rilis", 60, 0)
]))
recipes.append((340, "Clever 2-Phase Hybrid Trick", "Asser Christensen 🇩🇰", "Panama Boquete Catuai", "Catuai", "Washed", "Clever Dripper", "Immersion", 93, "Medium", 16, 250, 195, "Fase perkolasi 30 detik pertama untuk keasaman cerah, dilanjutkan imersi penuh untuk body bulat.", [
    (1, "Perkolasi Awal Katup Buka", 30, 60), (2, "Tutup Katup & Tuang Sisa", 25, 190), (3, "Imersi Penuh", 80, 0), (4, "Rilis Akhir", 60, 0)
]))
recipes.append((341, "Clever Daily Traveler Brew", "Ryan Wibawa 🇮🇩", "Bali Kintamani Ulian", "Kopyol", "Washed", "Clever Dripper", "Immersion", 92, "Medium", 15, 240, 180, "Sangat mudah dibuat saat travelling dengan toleransi ekstraksi tinggi dan rasa manis buah tropis.", [
    (1, "Tuang Air 240g", 20, 240), (2, "Kopi Masuk & Swirl", 20, 0), (3, "Steep 1:30 Menit", 90, 0), (4, "Letakkan di Mug Drawdown", 50, 0)
]))
recipes.append((342, "Clever Chocolate Toffee Warmth", "Yoshua Tanu 🇮🇩", "Brazil Mogiana Natural", "Yellow Bourbon", "Natural", "Clever Dripper", "Immersion", 94, "Medium", 18, 280, 220, "Aroma toffee karamel mentega dengan kekentalan lembut yang memanjakan lidah di pagi hari.", [
    (1, "Tuang Air 280g", 25, 280), (2, "Kopi Tabur Rata", 20, 0), (3, "Steeping Santai", 115, 0), (4, "Rilis ke Cangkir", 60, 0)
]))

# --- CUPPING (343-352) ---
recipes.append((343, "SCA Standard Cupping Protocol", "Hendri Kurniawan 🇮🇩", "Sample Roast Specialty", "Various", "Washed / Natural", "Cupping Bowl", "Cupping", 93, "Coarse (70% lolos 20-mesh)", 12, 200, 240, "Protokol resmi SCA evaluasi mutu sensorik biji kopi dengan rasio 5.5% (12g kopi : 200ml air).", [
    (1, "Dry Fragrance Evaluation", 30, 0), (2, "Pouring Water Direct to Crust", 20, 200), (3, "Wet Aroma Steep 4 Min", 220, 0), (4, "Break Crust 3x & Skim Fines", 60, 0)
]))
recipes.append((344, "Brazilian Blind Cupping Protocol", "Garam Victor Um 🇧🇷", "Brazil Cerrado Sample Lots", "Bourbon / Catuai", "Natural", "Cupping Bowl", "Cupping", 94, "Coarse", 13, 220, 240, "Metode cupping buta petani kopi Brasil untuk menilai sweetness, body, dan konsistensi cup-to-cup.", [
    (1, "Evaluasi Kering", 30, 0), (2, "Tuang Air Cepat 220g", 20, 220), (3, "Steep Diam 4 Menit", 220, 0), (4, "Break & Slurp Sensorik", 60, 0)
]))
recipes.append((345, "Barista Competition Sensory Calibration", "Mikael Jasin 🇮🇩", "Competition Micro-Lot", "Geisha / Eugenioides", "Carbonic Maceration", "Cupping Bowl", "Cupping", 95, "Medium-Coarse", 11, 190, 240, "Kalibrasi sensori juri dan barista kompetisi WBC untuk mencatat spektrum aroma, rasa, dan aftertaste.", [
    (1, "Sniff Aroma Kering", 30, 0), (2, "Tuang Menyeluruh 190g", 15, 190), (3, "Infusi Stabil 4 Menit", 225, 0), (4, "Break & Cupping Slurp", 60, 0)
]))
recipes.append((346, "Home Cupping Flavour Discovery", "James Hoffmann 🇬🇧", "Single Origin Discovery Pack", "Heirloom / Bourbon", "Various", "Cupping Bowl", "Cupping", 94, "Coarse", 12, 200, 240, "Cara paling murni mencicipi karakter asli biji kopi di rumah tanpa pengaruh teknik tuangan dripper.", [
    (1, "Aroma Bubuk Kering", 25, 0), (2, "Tuang Air Mendidih Terkontrol", 20, 200), (3, "Diamkan 4 Menit", 225, 0), (4, "Pecahkan Kerak & Hirup Slurp", 60, 0)
]))
recipes.append((347, "Roastery Production Batch Cupping", "Melvin (Fugol Coffee) 🇮🇩", "Fresh Roasted Production Batch", "West Java Varietals", "Anaerobic", "Cupping Bowl", "Cupping", 93, "Medium-Coarse", 13, 215, 240, "Uji kontrol kualitas harian roastery setelah resting 24 jam untuk memastikan profil sangrai tepat sasaran.", [
    (1, "Cek Fragrance", 25, 0), (2, "Tuang Cepat Merata", 20, 215), (3, "Steep Ekstraksi 4 Menit", 225, 0), (4, "Skim Busa & Cicip Suhu Turun", 60, 0)
]))
recipes.append((348, "Green Bean Defect & Cleanliness Cup", "Doddy Samsura 🇮🇩", "Green Bean Origin Sample", "Typica / Sigararutang", "Wet Hulled", "Cupping Bowl", "Cupping", 92, "Coarse", 12, 200, 240, "Menilai kebersihan cup (clean cup) dan mendeteksi potensi cacat fermentasi atau mold pada green bean.", [
    (1, "Dry Assessment", 30, 0), (2, "Water Infusion 200g", 20, 200), (3, "Wet Aroma Analysis", 220, 0), (4, "Break & Clean Skim", 60, 0)
]))
recipes.append((349, "Sensory Triangle Discrimination Cup", "Hiro Lesmana 🇮🇩", "Origin Matching Test", "Catimor vs Typica", "Washed", "Cupping Bowl", "Cupping", 94, "Coarse", 12, 200, 240, "Uji segitiga (triangulasi) 3 mangkuk untuk melatih kepekaan lidah menemukan 1 mangkuk yang berbeda.", [
    (1, "Dry Triangle Check", 30, 0), (2, "Tuang 3 Mangkuk Simultan", 25, 200), (3, "Steep 4 Menit", 215, 0), (4, "Blind Tasting & Selection", 60, 0)
]))
recipes.append((350, "Micro-Lot Acidity & Sweetness Score", "Carlos Medina 🇨🇱", "Panama Geisha Finca Deborah", "Geisha", "Nitrogen Macerated", "Cupping Bowl", "Cupping", 95, "Coarse", 11, 185, 240, "Penilaian rinci intensitas keasaman malat sitrat dan kelembutan rasa manis buah persik madu.", [
    (1, "Aroma Bunga Kering", 30, 0), (2, "Tuang Air Suhu Tinggi 185g", 15, 185), (3, "Steep Diam 4 Menit", 225, 0), (4, "Break & Evaluasi Suhu 70°-50°C", 60, 0)
]))
recipes.append((351, "Natural vs Washed Side-by-Side Cup", "Ryan Wibawa 🇮🇩", "Same Farm Same Harvest Test", "Kartika", "Natural vs Washed", "Cupping Bowl", "Cupping", 93, "Coarse", 12, 200, 240, "Membandingkan langsung pengaruh proses pascapanen pada varietas dan kebun yang sama.", [
    (1, "Fragrance Comparison", 30, 0), (2, "Tuang Kedua Mangkuk", 20, 200), (3, "Steeping 4 Menit", 220, 0), (4, "Dual Slurp Tasting", 60, 0)
]))
recipes.append((352, "Cooling Phase Cupping Evaluation", "Lance Hedrick 🇺🇸", "Kenya Nyeri Washed", "SL28", "Washed", "Cupping Bowl", "Cupping", 94, "Coarse", 12, 200, 270, "Mencicipi kopi pada suhu hangat (60°C), suam (45°C), dan dingin (35°C) untuk melihat evolusi rasa sebenarnya.", [
    (1, "Tuang Air 200g", 20, 200), (2, "Steep & Break 4 Menit", 220, 0), (3, "Cicip Fase Hangat 60°C", 40, 0), (4, "Cicip Fase Dingin 38°C", 40, 0)
]))

# --- DRIP COFFEE MAKER (353-364) ---
recipes.append((353, "Moccamaster Gold Cup Standard", "James Hoffmann 🇬🇧", "Colombia Tolima Especial", "Caturra", "Washed", "Drip Coffee Maker", "Drip Maker", 94, "Medium-Coarse", 30, 500, 270, "Standar Gold Cup ECBC/SCA pada mesin tetes otomatis Moccamaster untuk hasil ekstraksi merata tanpa rasa pahit.", [
    (1, "Pemanasan Boiler Mesin", 30, 0), (2, "Penyemprotan Showerhead Otomatis", 120, 500), (3, "Perkolasi Carafe", 120, 0)
]))
recipes.append((354, "Auto Drip Morning Batch Brew", "Scott Rao 🇺🇸", "Guatemala Huehuetenango", "Bourbon", "Washed", "Drip Coffee Maker", "Drip Maker", 93, "Medium-Coarse", 40, 650, 300, "Resep teko tetes otomatis porsi sarapan keluarga dengan rasa cokelat seimbang dan keasaman bersih.", [
    (1, "Mesin Mulai Mengalirkan Air", 30, 50), (2, "Showerhead Spray Utama", 150, 600), (3, "Tetesan Akhir ke Teko Kaca", 120, 0)
]))
recipes.append((355, "Breville Precision Brewer Single Cup", "Lance Hedrick 🇺🇸", "Ethiopia Guji Washed", "Heirloom", "Washed", "Drip Coffee Maker", "Drip Maker", 95, "Medium", 20, 320, 210, "Mengatur suhu presisi 95°C dan debit shower head lambat untuk meniru seduhan pour-over barista profesional.", [
    (1, "Pre-infusion Bloom Otomatis", 45, 60), (2, "Pulsed Shower Spray", 100, 260), (3, "Drawdown Basket", 65, 0)
]))
recipes.append((356, "Auto Drip Bloom & Stir Technique", "Patrik Rolf 🇸🇪", "Kenya Kirinyaga SL28", "SL28", "Washed", "Drip Coffee Maker", "Drip Maker", 95, "Medium-Coarse", 25, 400, 240, "Menjeda mesin saat air pertama membasahi basket untuk mengaduk bubuk kopi (stir) agar bebas channeling.", [
    (1, "Shower Awal & Jeda Mesin", 30, 60), (2, "Stir Keranjang Bubuk", 15, 0), (3, "Lanjutkan Seduh Otomatis", 125, 340), (4, "Drip Selesai", 70, 0)
]))
recipes.append((357, "Bonavita Connoisseur One-Touch", "Asser Christensen 🇩🇰", "Costa Rica Central Valley", "Caturra", "Yellow Honey", "Drip Coffee Maker", "Drip Maker", 93, "Medium", 32, 500, 260, "Mengaktifkan mode pra-infusi Bonavita untuk mengekstrak manis karamel dan buah ara dengan satu sentuhan.", [
    (1, "Pre-infusion Otomatis", 40, 60), (2, "Continuous Shower", 130, 440), (3, "Thermal Carafe Fill", 90, 0)
]))
recipes.append((358, "Wilfa Classic Precision Carafe", "Tim Wendelboe 🇳🇴", "Kenya Nyeri Hill", "SL28", "Washed", "Drip Coffee Maker", "Drip Maker", 96, "Medium-Coarse", 35, 550, 270, "Flow control valve pada keranjang Wilfa ditutup separuh untuk memperpanjang waktu kontak ekstraksi kopi Nordic.", [
    (1, "Water Heat-up & Spray", 35, 80), (2, "Flow Restricted Infusion", 145, 470), (3, "Finish Drip", 90, 0)
]))
recipes.append((359, "Batch Brew Everyday Sumatra", "Dody Samsura 🇮🇩", "Sumatra Mandheling Toba", "Typica", "Giling Basah", "Drip Coffee Maker", "Drip Maker", 91, "Coarse", 35, 550, 280, "Suhu terkontrol pada mesin tetes otomatis membuat kopi Sumatra terasa sangat bulat, manis gula aren, dan lembut.", [
    (1, "Mesin Mengucur Air", 30, 70), (2, "Ekstraksi Teko Otomatis", 160, 480), (3, "Penyelesaian Carafe", 90, 0)
]))
recipes.append((360, "Auto Drip Iced Coffee Batch", "Yoshua Tanu 🇮🇩", "Bali Kintamani Washed", "Kopyol", "Washed", "Drip Coffee Maker", "Drip Maker", 94, "Medium", 36, 400, 220, "Mengisi teko kaca dengan 250g es batu, air mesin mengucur pekat menghasilkan teko es kopi instan.", [
    (1, "Pre-wetting Basket", 30, 60), (2, "Shower Spray Pekat", 120, 340), (3, "Melt di Teko Es", 70, 0)
]))
recipes.append((361, "Office Hero 1-Liter Batch Brew", "Hendri Kurniawan 🇮🇩", "Java Frinsa Washed", "Andungsari", "Washed", "Drip Coffee Maker", "Drip Maker", 94, "Coarse", 60, 1000, 330, "Kapasitas 1 liter untuk rapat kantor, menghasilkan 6-8 cangkir kopi specialty yang konsisten dari cangkir pertama hingga akhir.", [
    (1, "Shower Awal 150g", 45, 150), (2, "Continuous Spray 850g", 185, 850), (3, "Carafe Settling", 100, 0)
]))
recipes.append((362, "Technivorm Cup-One Single Serve", "Chad Wang 🇹🇼", "Panama Boquete Washed", "Geisha", "Washed", "Drip Coffee Maker", "Drip Maker", 94, "Medium", 16, 260, 195, "Mesin otomatis porsi tunggal dengan keranjang kerucut kecil menghadirkan aroma melati dan rasa peach segar.", [
    (1, "Pulsing Spray 45g", 30, 45), (2, "Main Extraction 215g", 105, 215), (3, "Direct to Mug Finish", 60, 0)
]))
recipes.append((363, "Dark Roast Sweet Mocha Batch", "Pepeng (Klinik Kopi) 🇮🇩", "Java Preanger Dark Roast", "Typica", "Natural", "Drip Coffee Maker", "Drip Maker", 89, "Coarse", 32, 500, 250, "Suhu rendah 89°C pada mesin otomatis untuk biji sangrai gelap agar terhindar dari rasa pahit gosong.", [
    (1, "Spray Basah 60g", 30, 60), (2, "Aliran Shower Lambat", 140, 440), (3, "Selesai di Teko", 80, 0)
]))
recipes.append((364, "Floral Geisha Batch Brew Experiment", "Mikael Jasin 🇮🇩", "Colombia Gesha Spirits", "Geisha", "Washed", "Drip Coffee Maker", "Drip Maker", 95, "Medium-Coarse", 25, 400, 230, "Membuktikan bahwa mesin drip otomatis modern mampu mengekstrak aroma floral kompleks kopi lelang dunia.", [
    (1, "Bloom Shower 60g", 40, 60), (2, "Multi-hole Extraction", 120, 340), (3, "Drawdown Tuntas", 70, 0)
]))

# Write the rest (Espresso, French Press, Moka Pot, Aeropress, V60, Kalita, Syphon, Cold Brew) in next parts!
print(f"Base batch created with {len(recipes)} recipes so far")
