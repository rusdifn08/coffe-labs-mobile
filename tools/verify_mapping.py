import os
import sys

# Target destination definitions:
# Key: filename in brewer/
# Value: dict with:
#   'type': 'brewer' or 'roastery' or 'both'
#   'slug': main slug
#   'aliases': other slugs that should also get the image
#   'roastery_ids': roastery ids in RoasteryCatalog that should get the logo in assets/images/roasteries/

MAPPING = {
    "Alessandro Galtieri.png": {
        "type": "brewer",
        "slug": "alessandro_galtieri",
        "name": "Alessandro Galtieri"
    },
    "Archivist & Kafe Specialty Seoul logo.png": {
        "type": "both",
        "slug": "archivist_seoul",
        "aliases": ["archivist_kafe_specialty_seoul"],
        "name": "Archivist & Kafe Specialty Seoul"
    },
    "Athens Barista Community.png": {
        "type": "both",
        "slug": "athens_barista_community",
        "name": "Athens Barista Community"
    },
    "Dick Bradsell.png": {
        "type": "brewer",
        "slug": "dick_bradsell",
        "name": "Dick Bradsell"
    },
    "Edrick.png": {
        "type": "brewer",
        "slug": "edrick",
        "name": "Edrick"
    },
    "Emi Fukahori.png": {
        "type": "brewer",
        "slug": "emi_fukahori",
        "name": "Emi Fukahori"
    },
    "Garam Victor.png": {
        "type": "brewer",
        "slug": "garam_victor_um",
        "aliases": ["garam_victor"],
        "name": "Garam Victor Um"
    },
    "Hungry Bird Coffe .png": {
        "type": "both",
        "slug": "hungry_bird_coffee",
        "roastery_ids": ["hungry_bird_coffee"],
        "name": "Hungry Bird Coffee"
    },
    "Instinct Roastery.png": {
        "type": "both",
        "slug": "instinct_roastery",
        "roastery_ids": ["instinct_roastery"],
        "name": "Instinct Roastery"
    },
    "John Richard Christopher.png": {
        "type": "brewer",
        "slug": "john_richard_christopher",
        "aliases": ["john_christopher"],
        "name": "John Richard Christopher"
    },
    "Madan (Kendari).png": {
        "type": "brewer",
        "slug": "madan",
        "aliases": ["madan_kendari"],
        "name": "Madan (Kendari)"
    },
    "Mandie (Fugol Coffee).png": {
        "type": "brewer",
        "slug": "mandie_fugol",
        "name": "Mandie (Fugol Coffee)"
    },
    "Matt Winton.png": {
        "type": "brewer",
        "slug": "matt_winton",
        "name": "Matt Winton"
    },
    "Muhammad Fakhri.png": {
        "type": "brewer",
        "slug": "muhammad_fakhri",
        "name": "Muhammad Fakhri"
    },
    "One Fifteenth.png": {
        "type": "both",
        "slug": "one_fifteenth_coffee",
        "aliases": ["one_fifteenth", "1_15_coffee"],
        "roastery_ids": ["one_fifteenth_morph"],
        "name": "One Fifteenth (1/15)"
    },
    "Opak Kopi Channel.jpg": {
        "type": "both",
        "slug": "opak_kopi",
        "aliases": ["opak_kopi_channel"],
        "name": "Opak Kopi Channel"
    },
    "Our Daily Caffeine.jpg": {
        "type": "both",
        "slug": "panna_roastery",
        "aliases": ["our_daily_caffeine", "daily_caffeine"],
        "name": "Our Daily Caffeine"
    },
    "Ray Janson.png": {
        "type": "brewer",
        "slug": "ray_janson",
        "name": "Ray Janson"
    },
    "Regine Wai Yee Beng.png": {
        "type": "brewer",
        "slug": "regine_wai_yee_beng",
        "name": "Regine Wai Yee Beng"
    },
    "Roy Panggabean.png": {
        "type": "brewer",
        "slug": "roy_panggabean",
        "aliases": ["serkop", "roy_panggabean_serkop"],
        "roastery_ids": ["serkop_roastery"],
        "name": "Roy Panggabean (Serkop)"
    },
    "Sam Corra.png": {
        "type": "brewer",
        "slug": "sam_corra",
        "name": "Sam Corra"
    },
    "agnieszka rojewska.png": {
        "type": "brewer",
        "slug": "agnieszka_rojewska",
        "name": "Agnieszka Rojewska"
    },
    "andanu prasetyo.png": {
        "type": "brewer",
        "slug": "andanu_prasetyo",
        "name": "Andanu Prasetyo (Toko Kopi Tuku)"
    },
    "anomali coffee.png": {
        "type": "both",
        "slug": "anomali_coffee",
        "roastery_ids": ["anomali_coffee"],
        "name": "Anomali Coffee"
    },
    "anthony douglas.png": {
        "type": "brewer",
        "slug": "anthony_douglas",
        "name": "Anthony Douglas"
    },
    "bavis kwong.png": {
        "type": "brewer",
        "slug": "bavis_kwong",
        "name": "Bavis Kwong"
    },
    "bayu prawiro.png": {
        "type": "brewer",
        "slug": "bayu_prawiro",
        "name": "Bayu Prawiro"
    },
    "blue doors.png": {
        "type": "both",
        "slug": "blue_doors",
        "name": "Blue Doors"
    },
    "carlos escobar.png": {
        "type": "brewer",
        "slug": "carlos_escobar",
        "name": "Carlos Escobar"
    },
    "carlos medina.png": {
        "type": "brewer",
        "slug": "carlos_medina",
        "name": "Carlos Medina"
    },
    "chad wang.png": {
        "type": "brewer",
        "slug": "chad_wang",
        "name": "Chad Wang"
    },
    "chandra.png": {
        "type": "brewer",
        "slug": "chandra_brewer",
        "aliases": ["chandra"],
        "name": "Chandra (Home Brewer)"
    },
    "common grounds.png": {
        "type": "both",
        "slug": "common_grounds",
        "roastery_ids": ["common_grounds"],
        "name": "Common Grounds"
    },
    "daiki hatakeyama.png": {
        "type": "brewer",
        "slug": "daiki_hatakeyama",
        "name": "Daiki Hatakeyama"
    },
    "djournal coffee.png": {
        "type": "both",
        "slug": "djournal_coffee",
        "name": "Djournal Coffee"
    },
    "doddy samsura.png": {
        "type": "brewer",
        "slug": "dody_samsura",
        "aliases": ["doddy_samsura"],
        "name": "Doddy Samsura"
    },
    "du jianing.png": {
        "type": "brewer",
        "slug": "du_jianing",
        "name": "Du Jianing"
    },
    "dustin wijaya.png": {
        "type": "brewer",
        "slug": "dustin_wijaya",
        "name": "Dustin Wijaya"
    },
    "elika liftee.png": {
        "type": "brewer",
        "slug": "elika_liftee",
        "name": "Elika Liftee"
    },
    "elysia tan.png": {
        "type": "brewer",
        "slug": "elysia_tan",
        "name": "Elysia Tan"
    },
    "fore coffee.png": {
        "type": "both",
        "slug": "fore_coffee",
        "name": "Fore Coffee"
    },
    "fugol.png": {
        "type": "both",
        "slug": "fugol_coffee",
        "aliases": ["fugol_coffee_roasters", "melvin_fugol"],
        "roastery_ids": ["fugol_coffee"],
        "name": "Fugol Coffee Roasters"
    },
    "gianni frasi .png": {
        "type": "brewer",
        "slug": "gianni_frasi",
        "name": "Gianni Frasi"
    },
    "harison chandra.png": {
        "type": "brewer",
        "slug": "harison_chandra",
        "name": "Harison Chandra"
    },
    "hendri kurniawan.png": {
        "type": "brewer",
        "slug": "hendri_kurniawan",
        "name": "Hendri Kurniawan"
    },
    "hiro lesmana.png": {
        "type": "brewer",
        "slug": "hiro_lesmana",
        "name": "Hiro Lesmana"
    },
    "hiroshi sawada.png": {
        "type": "brewer",
        "slug": "hiroshi_sawada",
        "name": "Hiroshi Sawada"
    },
    "james hoffmann.png": {
        "type": "brewer",
        "slug": "james_hoffmann",
        "name": "James Hoffmann"
    },
    "jaya pranata.png": {
        "type": "brewer",
        "slug": "jaya_pranata",
        "name": "Jaya Pranata"
    },
    "john christopher.png": {
        "type": "brewer",
        "slug": "john_christopher",
        "name": "John Christopher"
    },
    "lance hedrick.png": {
        "type": "brewer",
        "slug": "lance_hedrick",
        "name": "Lance Hedrick"
    },
    "martin wölfl.png": {
        "type": "brewer",
        "slug": "martin_wolfl",
        "name": "Martin Wölfl"
    },
    "matt perger.png": {
        "type": "brewer",
        "slug": "matt_perger",
        "name": "Matt Perger"
    },
    "mikael_jasin.png": {
        "type": "brewer",
        "slug": "mikael_jasin",
        "name": "Mikael Jasin"
    },
    "mikaela wallgren.png": {
        "type": "brewer",
        "slug": "mikaela_wallgren",
        "name": "Mikaela Wallgren"
    },
    "mirza luqman.png": {
        "type": "brewer",
        "slug": "mirza_luqman",
        "name": "Mirza Luqman"
    },
    "muhammad aga.png": {
        "type": "brewer",
        "slug": "muhammad_aga",
        "name": "Muhammad Aga"
    },
    "nas jaafar.png": {
        "type": "brewer",
        "slug": "nas_jaafar",
        "name": "Nas Jaafar"
    },
    "odd-steinar tøllefsen.png": {
        "type": "brewer",
        "slug": "odd_steinar_tollefsen",
        "name": "Odd-Steinar Tøllefsen"
    },
    "ombe kofie.png": {
        "type": "both",
        "slug": "ombe_kofie",
        "name": "Ombe Kofie"
    },
    "onathan gagné .png": {
        "type": "brewer",
        "slug": "jonathan_gagne",
        "name": "Jonathan Gagné"
    },
    "otten coffee.jpg": {
        "type": "both",
        "slug": "otten_coffee",
        "aliases": ["otten_coffee_academy"],
        "roastery_ids": ["otten_coffee"],
        "name": "Otten Coffee"
    },
    "patrik rolf.png": {
        "type": "brewer",
        "slug": "patrik_rolf",
        "name": "Patrik Rolf"
    },
    "peng jinyang.png": {
        "type": "brewer",
        "slug": "peng_jinyang",
        "name": "Peng Jinyang"
    },
    "pepeng.png": {
        "type": "both",
        "slug": "pepeng_klinik_kopi",
        "aliases": ["pepeng"],
        "roastery_ids": ["klinik_kopi"],
        "name": "Pepeng (Klinik Kopi)"
    },
    "ryan_wibawa.png": {
        "type": "brewer",
        "slug": "ryan_wibawa",
        "name": "Ryan Wibawa"
    },
    "tetsu_katsuya.png": {
        "type": "brewer",
        "slug": "tetsu_kasuya",
        "name": "Tetsu Kasuya"
    }
}

brewer_dir = r'c:\Rusdi\Coffe Labs\coffe-labs-mobile\brewer'
actual_files = set(os.listdir(brewer_dir))
mapped_files = set(MAPPING.keys())

unmapped = actual_files - mapped_files
missing = mapped_files - actual_files

print(f"Total actual files: {len(actual_files)}")
print(f"Total mapped files: {len(mapped_files)}")
print(f"Unmapped: {unmapped}")
print(f"Missing from dir: {missing}")
