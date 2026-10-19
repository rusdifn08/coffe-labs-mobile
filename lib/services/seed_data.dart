

class SeedData {
  static List<Map<String, dynamic>> getDefaultRecipes() {
    String now = DateTime.now().toIso8601String();
    return [
      // 2026
      {
        "id": 100,
        "title": "Metode Multi-Pour Neo Brew (2026)",
        "author": "Tetsu Kasuya 🇯🇵",
        "coverImageUrl": "assets/images/avatars/covers/tetsu_kasuya.jpg",
        "authorAvatarUrl": "assets/images/avatars/portraits/tetsu_kasuya.jpg",
        "authorImageUrl": "assets/images/avatars/covers/tetsu_kasuya.jpg",
        "beanName": "Light Roast Single Origin",
        "method": "Hario V60 / Neo",
        "category": "V60 Pour Over",
        "waterTempCelsius": 96,
        "grindSize": "Super Coarse (45 Klik)",
        "coffeeWeightGrams": 20,
        "totalWaterWeightGrams": 300,
        "totalTimeSeconds": 210,
        "description": "Resep ulang tahun ke-10 (2026) Tetsu Kasuya. Menggunakan gilingan super kasar dan 10 kali tuangan beruntun (30g setiap 15 detik) untuk menghasilkan tekstur sangat kental (syrupy), rasa manis maksimal, dan minim pahit.",
        "isCustom": false,
        "createdAt": now,
        "steps": [
          {"stepOrder": 1, "title": "Blooming", "durationSeconds": 30, "waterAddedGrams": 30},
          {"stepOrder": 2, "title": "Tuang 2", "durationSeconds": 15, "waterAddedGrams": 30},
          {"stepOrder": 3, "title": "Tuang 3", "durationSeconds": 15, "waterAddedGrams": 30},
          {"stepOrder": 4, "title": "Tuang 4", "durationSeconds": 15, "waterAddedGrams": 30},
          {"stepOrder": 5, "title": "Tuang 5", "durationSeconds": 15, "waterAddedGrams": 30},
          {"stepOrder": 6, "title": "Tuang 6", "durationSeconds": 15, "waterAddedGrams": 30},
          {"stepOrder": 7, "title": "Tuang 7", "durationSeconds": 15, "waterAddedGrams": 30},
          {"stepOrder": 8, "title": "Tuang 8", "durationSeconds": 15, "waterAddedGrams": 30},
          {"stepOrder": 9, "title": "Tuang 9", "durationSeconds": 15, "waterAddedGrams": 30},
          {"stepOrder": 10, "title": "Tuang Akhir (Tunggu Surut)", "durationSeconds": 60, "waterAddedGrams": 30}
        ]
      },
      // 2015
      {
        "id": 1,
        "title": "Simplifikasi Kopi Natural Murni (2015 Juara 1)",
        "author": "Odd-Steinar Tøllefsen 🇳🇴",
        "coverImageUrl": "assets/images/avatars/covers/odd_steinar_tollefsen.jpg",
        "authorAvatarUrl": "assets/images/avatars/portraits/odd_steinar_tollefsen.jpg",
        "authorImageUrl": "assets/images/avatars/covers/odd_steinar_tollefsen.jpg",
        "beanName": "Ninety Plus Nekisse (Ethiopia, Natural)",
        "method": "Hario V60",
        "category": "V60 Pour Over",
        "waterTempCelsius": 92,
        "grindSize": "Medium",
        "coffeeWeightGrams": 20,
        "totalWaterWeightGrams": 300,
        "totalTimeSeconds": 210,
        "description": "Pada tahun 2015, Odd-Steinar mendobrak dogma dengan menggunakan kopi proses natural (Ninety Plus Nekisse) yang menonjolkan profil buah tropis yang pekat namun luar biasa bersih. Ekstraksi dimulai dengan masa pra-infusi (blooming) selama 45 detik, menghasilkan total waktu seduh 3 menit 30 detik. Keputusan krusialnya terletak pada penggunaan air mineral alami dari pantai barat Norwegia yang memiliki kandungan mineral sangat rendah. Hal ini memberikan tekstur lembut yang menonjolkan profil rasa mangga, markisa, dan aprikot.",
        "isCustom": false,
        "createdAt": now,
        "steps": [
          {"stepOrder": 1, "title": "Blooming", "durationSeconds": 45, "waterAddedGrams": 50},
          {"stepOrder": 2, "title": "Main Pour", "durationSeconds": 165, "waterAddedGrams": 250}
        ]
      },
      {
        "id": 2,
        "title": "Inovasi Pemecahan Biji Dingin (2015 Juara 2)",
        "author": "Konstantinos Iatridis 🇬🇷",
        "coverImageUrl": "assets/images/avatars/covers/konstantinos_iatridis.jpg",
        "authorAvatarUrl": "assets/images/avatars/portraits/konstantinos_iatridis.jpg",
        "authorImageUrl": "assets/images/avatars/covers/konstantinos_iatridis.jpg",
        "beanName": "Ninety Plus Perci Pinnacle Gesha",
        "method": "Hario V60",
        "category": "V60 Pour Over",
        "waterTempCelsius": 92,
        "grindSize": "Coarse",
        "coffeeWeightGrams": 20,
        "totalWaterWeightGrams": 300,
        "totalTimeSeconds": 180,
        "description": "Konstantinos memperkenalkan teknik mekanis prapanggung yang sangat inovatif. Ia menyadari selaput perak (silver skin) sering menyumbangkan rasa sepat. Ia menggiling bijinya secara manual dan meniup sisa selaput perak tersebut. Lebih jauh lagi, ia membekukan biji kopinya di dalam lemari es sebelum digiling! Penurunan suhu ini mengubah biji kopi menjadi sangat rapuh (brittle), sehingga saat digiling, biji pecah dengan lebih seragam dan menghasilkan jauh lebih sedikit debu kopi (fines). Ini mencegah penyumbatan filter dan membangkitkan rasa pepaya dan bunga jeruk.",
        "isCustom": false,
        "createdAt": now,
        "steps": [
          {"stepOrder": 1, "title": "Blooming", "durationSeconds": 30, "waterAddedGrams": 60},
          {"stepOrder": 2, "title": "Main Pour", "durationSeconds": 150, "waterAddedGrams": 240}
        ]
      },
      {
        "id": 3,
        "title": "Penurunan Suhu Body Sutra (2015 Juara 3)",
        "author": "Benjamin Prager 🇨🇭",
        "coverImageUrl": "assets/images/avatars/covers/benjamin_prager.jpg",
        "authorAvatarUrl": "assets/images/avatars/portraits/benjamin_prager.jpg",
        "authorImageUrl": "assets/images/avatars/covers/benjamin_prager.jpg",
        "beanName": "SL-28 & SL-34 (Kenya, Washed)",
        "method": "Hario V60",
        "category": "V60 Pour Over",
        "waterTempCelsius": 93,
        "grindSize": "Fine",
        "coffeeWeightGrams": 14,
        "totalWaterWeightGrams": 236,
        "totalTimeSeconds": 150,
        "description": "Prager mengisolasi ukuran partikel kopinya dengan saringan baja tahan karat berukuran 350 mikron dan 250 mikron. Secara kinetik, alih-alih menuangkan air dalam beberapa tahap, ia menuangkan seluruh volume air 236 gram sekaligus setelah blooming! Keputusan ini dirancang untuk menciptakan kurva penurunan suhu yang stabil di dalam slurry (campuran air dan kopi), yang secara termodinamika membantu memperlambat ekstraksi komponen tanin yang pahit, menghasilkan profil cangkir yang mirip teh buah dengan body sehalus sutra.",
        "isCustom": false,
        "createdAt": now,
        "steps": [
          {"stepOrder": 1, "title": "Blooming", "durationSeconds": 30, "waterAddedGrams": 30},
          {"stepOrder": 2, "title": "Single Continuous Pour", "durationSeconds": 120, "waterAddedGrams": 206}
        ]
      },
      // 2016
      {
        "id": 4,
        "title": "Metode 4:6 (2016 Juara 1)",
        "author": "Tetsu Kasuya 🇯🇵",
        "coverImageUrl": "assets/images/avatars/covers/tetsu_kasuya.jpg",
        "authorAvatarUrl": "assets/images/avatars/portraits/tetsu_kasuya.jpg",
        "authorImageUrl": "assets/images/avatars/covers/tetsu_kasuya.jpg",
        "beanName": "Ninety Plus Gesha Estate (Panama)",
        "method": "Hario V60",
        "category": "V60 Pour Over",
        "waterTempCelsius": 92,
        "grindSize": "Very Coarse",
        "coffeeWeightGrams": 20,
        "totalWaterWeightGrams": 300,
        "totalTimeSeconds": 210,
        "description": "Tahun 2016 menjadi titik balik historis dengan diperkenalkannya Metode 4:6. Teori ini membagi air seduhan menjadi dua fraksi utama. Fraksi pertama (40% air) difokuskan pada pelarutan asam dan gula, di mana Kasuya menuangkan 50g air pertama dan 70g air kedua untuk memanipulasi rasio keasaman terhadap rasa manis. Fraksi kedua (60% air) dibagi menjadi tiga tuangan berturut-turut untuk mengatur intensitas konsentrasi (strength). Metodologi ini bergantung mutlak pada gilingan kopi yang sangat kasar untuk memastikan air turun dengan cepat, mengekstraksi tingkat kejernihan ekstrem tanpa over-ekstraksi.",
        "isCustom": false,
        "createdAt": now,
        "steps": [
          {"stepOrder": 1, "title": "Bloom (Sweetness/Acidity)", "durationSeconds": 45, "waterAddedGrams": 50},
          {"stepOrder": 2, "title": "Balance Pour (40% done)", "durationSeconds": 45, "waterAddedGrams": 70},
          {"stepOrder": 3, "title": "Strength Pour 1", "durationSeconds": 45, "waterAddedGrams": 60},
          {"stepOrder": 4, "title": "Strength Pour 2", "durationSeconds": 45, "waterAddedGrams": 60},
          {"stepOrder": 5, "title": "Strength Pour 3", "durationSeconds": 30, "waterAddedGrams": 60}
        ]
      },
      {
        "id": 5,
        "title": "Rutinitas Kedai Kopi (2016 Juara 2)",
        "author": "Mikaela Wallgren (Finlandia)",
        "coverImageUrl": "assets/images/avatars/covers/mikaela_wallgren.jpg",
        "authorAvatarUrl": "assets/images/avatars/portraits/mikaela_wallgren.jpg",
        "authorImageUrl": "assets/images/avatars/covers/mikaela_wallgren.jpg",
        "beanName": "Kieni, Mugaga Society (Kenya)",
        "method": "Kalita Wave 155",
        "category": "Flat Bottom",
        "waterTempCelsius": 96,
        "grindSize": "Medium Fine",
        "coffeeWeightGrams": 15,
        "totalWaterWeightGrams": 250,
        "totalTimeSeconds": 105,
        "description": "Mikaela membawa semangat realisme kedai kopi ke panggung dunia. Menggunakan Kalita Wave 155 berbahan logam, dasar Kalita yang datar memberikan ekstraksi yang lebih merata tanpa harus memanipulasi air terlalu banyak. Setelah memisahkan fines (debu kopi) dengan saringan, Mikaela melakukan tuangan spiral secara perlahan dan terus-menerus hingga mencapai target 250 gram air pada menit 1:45. Air yang digunakan adalah hasil manipulasi Reverse Osmosis yang mengoptimalkan daya tarik senyawa rasa manis.",
        "isCustom": false,
        "createdAt": now,
        "steps": [
          {"stepOrder": 1, "title": "Blooming", "durationSeconds": 30, "waterAddedGrams": 50},
          {"stepOrder": 2, "title": "Continuous Spiral Pour", "durationSeconds": 75, "waterAddedGrams": 200}
        ]
      },
      {
        "id": 6,
        "title": "Ekstraksi Konstan Berbasis Aroma (2016 Juara 3)",
        "author": "Chad Wang 🇹🇼",
        "coverImageUrl": "assets/images/avatars/covers/chad_wang.jpg",
        "authorAvatarUrl": "assets/images/avatars/portraits/chad_wang.jpg",
        "authorImageUrl": "assets/images/avatars/covers/chad_wang.jpg",
        "beanName": "Ninety Plus Gesha Makers Series",
        "method": "Hario V60",
        "category": "V60 Pour Over",
        "waterTempCelsius": 92,
        "grindSize": "Medium Coarse",
        "coffeeWeightGrams": 15,
        "totalWaterWeightGrams": 250,
        "totalTimeSeconds": 120,
        "description": "Chad Wang memenangkan kompetisi dengan presisi tinggi. Ia tidak melakukan pergerakan memutar saat menuang, melainkan menjaga aliran air jatuh persis di tengah dripper secara statis. Pendekatan ini menjaga suhu slurry sangat panas dan stabil, mendorong tingkat ekstraksi yang seragam. Rutinitas ini mendeskripsikan transisi presisi dari rasa persik saat panas, bunga jeruk pada suhu hangat, dan likur pisang ketika kopi mendingin.",
        "isCustom": false,
        "createdAt": now,
        "steps": [
          {"stepOrder": 1, "title": "Blooming", "durationSeconds": 30, "waterAddedGrams": 30},
          {"stepOrder": 2, "title": "Center Continuous Pour", "durationSeconds": 90, "waterAddedGrams": 220}
        ]
      },
      // 2017
      {
        "id": 7,
        "title": "Transisi Rasa Presisi Suhu (2017 Juara 1)",
        "author": "Chad Wang 🇹🇼",
        "coverImageUrl": "assets/images/avatars/covers/chad_wang.jpg",
        "authorAvatarUrl": "assets/images/avatars/portraits/chad_wang.jpg",
        "authorImageUrl": "assets/images/avatars/covers/chad_wang.jpg",
        "beanName": "Ninety Plus Gesha (Panama, Natural)",
        "method": "Hario V60",
        "category": "V60 Pour Over",
        "waterTempCelsius": 92,
        "grindSize": "Medium Coarse",
        "coffeeWeightGrams": 15,
        "totalWaterWeightGrams": 250,
        "totalTimeSeconds": 120,
        "description": "Chad Wang memenangkan kompetisi dengan presisi tinggi. Ia tidak melakukan pergerakan memutar saat menuang, melainkan menjaga aliran air jatuh persis di tengah dripper secara statis. Pendekatan ini menjaga suhu slurry sangat panas dan stabil, mendorong tingkat ekstraksi yang seragam. Rutinitas ini mendeskripsikan transisi presisi dari rasa persik saat panas, bunga jeruk pada suhu hangat, dan likur pisang ketika kopi mendingin.",
        "isCustom": false,
        "createdAt": now,
        "steps": [
          {"stepOrder": 1, "title": "Blooming", "durationSeconds": 30, "waterAddedGrams": 30},
          {"stepOrder": 2, "title": "Strict Center Pour", "durationSeconds": 90, "waterAddedGrams": 220}
        ]
      },
      {
        "id": 8,
        "title": "Ekstraksi Carbonic Maceration (2017 Juara 2)",
        "author": "Sam Corra 🇦🇺",
        "coverImageUrl": "assets/images/avatars/covers/sam_corra.jpg",
        "authorAvatarUrl": "assets/images/avatars/portraits/sam_corra.jpg",
        "authorImageUrl": "assets/images/avatars/covers/sam_corra.jpg",
        "beanName": "Finca Deborah Green-tip Gesha",
        "method": "Hario V60",
        "category": "V60 Pour Over",
        "waterTempCelsius": 93,
        "grindSize": "Coarse",
        "coffeeWeightGrams": 20,
        "totalWaterWeightGrams": 300,
        "totalTimeSeconds": 160,
        "description": "Sam Corra mencatatkan sejarah dengan kopi proses Carbonic Maceration (CM), teknik pinjaman dari industri winemaking. Corra menggunakan gilingan kasar dan membagi 300ml air menjadi lima tuangan agresif secara cepat. Presentasinya secara gamblang memisahkan elemen terroir (pengaruh alam) dan profil yang sengaja direkayasa melalui intervensi mikrobiologi fermentasi.",
        "isCustom": false,
        "createdAt": now,
        "steps": [
          {"stepOrder": 1, "title": "Aggressive Pour 1", "durationSeconds": 32, "waterAddedGrams": 60},
          {"stepOrder": 2, "title": "Aggressive Pour 2", "durationSeconds": 32, "waterAddedGrams": 60},
          {"stepOrder": 3, "title": "Aggressive Pour 3", "durationSeconds": 32, "waterAddedGrams": 60},
          {"stepOrder": 4, "title": "Aggressive Pour 4", "durationSeconds": 32, "waterAddedGrams": 60},
          {"stepOrder": 5, "title": "Aggressive Pour 5", "durationSeconds": 32, "waterAddedGrams": 60}
        ]
      },
      {
        "id": 9,
        "title": "Konsistensi Heavy Body (2017 Juara 3)",
        "author": "Stathis Koremtas 🇬🇷",
        "coverImageUrl": "assets/images/avatars/covers/stathis_koremtas.jpg",
        "authorAvatarUrl": "assets/images/avatars/portraits/stathis_koremtas.jpg",
        "authorImageUrl": "assets/images/avatars/covers/stathis_koremtas.jpg",
        "beanName": "Ninety Plus Gesha (Panama, Natural)",
        "method": "Hario V60",
        "category": "V60 Pour Over",
        "waterTempCelsius": 92,
        "grindSize": "Medium",
        "coffeeWeightGrams": 15,
        "totalWaterWeightGrams": 250,
        "totalTimeSeconds": 95,
        "description": "Tuangan sangat lambat dan terpusat minim agitasi untuk mencegah pelarutan asam klorogenat berlebih dan mengamankan body tebal. Resep ini menggunakan rasio presisi 1:16.7 yang dirancang untuk menyeimbangkan ekstraksi secara optimal. Dengan memanfaatkan air bersuhu 92°C dan gilingan berukuran Medium to Coarse, teknik penuangan ini mampu memanipulasi turbulensi (agitasi) di dalam alat seduh. Hal ini memastikan pelepasan gas karbon dioksida saat fase blooming berjalan sempurna, serta mencegah terjadinya channeling (aliran air tak merata). Hasil akhirnya adalah secangkir kopi dengan spektrum rasa yang kompleks, menonjolkan tingkat kemanisan (sweetness) alami dan kejelasan (clarity) yang tajam.",
        "isCustom": false,
        "createdAt": now,
        "steps": [
          {"stepOrder": 1, "title": "Gentle Bloom", "durationSeconds": 30, "waterAddedGrams": 30},
          {"stepOrder": 2, "title": "Slow Center Pour", "durationSeconds": 65, "waterAddedGrams": 220}
        ]
      },
      // 2018
      {
        "id": 10,
        "title": "Dinamika Profil Tanpa Pahit (2018 Juara 1)",
        "author": "Emi Fukahori 🇨🇭",
        "coverImageUrl": "assets/images/avatars/covers/emi_fukahori.jpg",
        "authorAvatarUrl": "assets/images/avatars/portraits/emi_fukahori.jpg",
        "authorImageUrl": "assets/images/avatars/covers/emi_fukahori.jpg",
        "beanName": "Laurina, Daterra Farm (Brasil, Semi-CM)",
        "method": "GINA",
        "category": "Hybrid",
        "waterTempCelsius": 80, // Using lowest start temp for simplicity
        "grindSize": "Medium",
        "coffeeWeightGrams": 17,
        "totalWaterWeightGrams": 220,
        "totalTimeSeconds": 150,
        "description": "Fukahori mengguncang tatanan dengan varietas Laurina, sebuah mutasi dari pohon Bourbon yang memiliki kandungan kafein dan asam klorogenat 50% lebih rendah. Hal ini membuatnya hampir mustahil diekstraksi menjadi pahit. Ia menggunakan alat seduh GINA. Ia menutup katup bawah untuk fase imersi dengan air 80°C selama 45 detik (menarik molekul gula), lalu membuka katup dengan air 95°C (menarik asam buah), dan menutupnya kembali di tahap akhir untuk menambah bobot tekstur.",
        "isCustom": false,
        "createdAt": now,
        "steps": [
          {"stepOrder": 1, "title": "Immersion (80°C)", "durationSeconds": 45, "waterAddedGrams": 50},
          {"stepOrder": 2, "title": "Percolation (95°C)", "durationSeconds": 75, "waterAddedGrams": 120},
          {"stepOrder": 3, "title": "Final Immersion", "durationSeconds": 30, "waterAddedGrams": 50}
        ]
      },
      {
        "id": 11,
        "title": "Presisi Asia Tenggara (2018 Juara 2)",
        "author": "Regine Wai Yee Beng 🇲🇾",
        "coverImageUrl": "assets/images/avatars/covers/regine_wai_yee_beng.jpg",
        "authorAvatarUrl": "assets/images/avatars/portraits/regine_wai_yee_beng.jpg",
        "authorImageUrl": "assets/images/avatars/covers/regine_wai_yee_beng.jpg",
        "beanName": "Gesha (Panama)",
        "method": "Flat Bed / V60",
        "category": "Flat Bottom",
        "waterTempCelsius": 93,
        "grindSize": "Medium",
        "coffeeWeightGrams": 16,
        "totalWaterWeightGrams": 240,
        "totalTimeSeconds": 140,
        "description": "Fokus pada presisi mekanik dan kejernihan buah yang bulat dan bersih. Resep ini menggunakan rasio presisi 1:15.0 yang dirancang untuk menyeimbangkan ekstraksi secara optimal. Dengan memanfaatkan air bersuhu 93°C dan gilingan berukuran Medium to Coarse, teknik penuangan ini mampu memanipulasi turbulensi (agitasi) di dalam alat seduh. Hal ini memastikan pelepasan gas karbon dioksida saat fase blooming berjalan sempurna, serta mencegah terjadinya channeling (aliran air tak merata). Hasil akhirnya adalah secangkir kopi dengan spektrum rasa yang kompleks, menonjolkan tingkat kemanisan (sweetness) alami dan kejelasan (clarity) yang tajam.",
        "isCustom": false,
        "createdAt": now,
        "steps": [
          {"stepOrder": 1, "title": "Blooming", "durationSeconds": 30, "waterAddedGrams": 40},
          {"stepOrder": 2, "title": "Main Pour", "durationSeconds": 110, "waterAddedGrams": 200}
        ]
      },
      {
        "id": 12,
        "title": "Gravitasi Minim Agitasi (2018 Juara 3)",
        "author": "Stathis Koremtas 🇬🇷",
        "coverImageUrl": "assets/images/avatars/covers/stathis_koremtas.jpg",
        "authorAvatarUrl": "assets/images/avatars/portraits/stathis_koremtas.jpg",
        "authorImageUrl": "assets/images/avatars/covers/stathis_koremtas.jpg",
        "beanName": "Ninety Plus Gesha (Panama, Natural)",
        "method": "Hario V60",
        "category": "V60 Pour Over",
        "waterTempCelsius": 92,
        "grindSize": "Medium",
        "coffeeWeightGrams": 15,
        "totalWaterWeightGrams": 250,
        "totalTimeSeconds": 110,
        "description": "Mempertahankan metode penuangan gravitasi stabil tanpa intervensi mekanik, eksekusi tanpa cela. Resep ini menggunakan rasio presisi 1:16.7 yang dirancang untuk menyeimbangkan ekstraksi secara optimal. Dengan memanfaatkan air bersuhu 92°C dan gilingan berukuran Medium to Coarse, teknik penuangan ini mampu memanipulasi turbulensi (agitasi) di dalam alat seduh. Hal ini memastikan pelepasan gas karbon dioksida saat fase blooming berjalan sempurna, serta mencegah terjadinya channeling (aliran air tak merata). Hasil akhirnya adalah secangkir kopi dengan spektrum rasa yang kompleks, menonjolkan tingkat kemanisan (sweetness) alami dan kejelasan (clarity) yang tajam.",
        "isCustom": false,
        "createdAt": now,
        "steps": [
          {"stepOrder": 1, "title": "Blooming", "durationSeconds": 30, "waterAddedGrams": 30},
          {"stepOrder": 2, "title": "Stable Center Pour", "durationSeconds": 80, "waterAddedGrams": 220}
        ]
      },
      // 2019
      {
        "id": 13,
        "title": "Kecepatan Alir Ekstrem (2019 Juara 1)",
        "author": "Du Jianing 🇨🇳",
        "coverImageUrl": "assets/images/avatars/covers/du_jianing.jpg",
        "authorAvatarUrl": "assets/images/avatars/portraits/du_jianing.jpg",
        "authorImageUrl": "assets/images/avatars/covers/du_jianing.jpg",
        "beanName": "Ninety Plus Gesha (Panama, Natural)",
        "method": "Origami Dripper",
        "category": "Origami",
        "waterTempCelsius": 94,
        "grindSize": "Double Grind",
        "coffeeWeightGrams": 16,
        "totalWaterWeightGrams": 240,
        "totalTimeSeconds": 100, // 1:40
        "description": "Du Jianing memenangkan kompetisi dengan kecepatan penyeduhan ekstrem: 1 menit 40 detik menggunakan Origami Dripper. Kunci utamanya adalah teknik penggilingan ganda (double grinding). Jianing pertama-tama menggiling biji secara kasar untuk melepaskan kulit ari tipisnya, meniupnya dengan alat pembersih, lalu menggiling ulang fragmen yang tersisa menjadi ukuran halus. Menggunakan jarum WDT, serbuk diratakan sehingga tidak ada jalur buntu. Aliran air dijatuhkan secara matematis: 6g/detik, 4g/detik, dan 5g/detik.",
        "isCustom": false,
        "createdAt": now,
        "steps": [
          {"stepOrder": 1, "title": "Bloom (6g/s)", "durationSeconds": 30, "waterAddedGrams": 60},
          {"stepOrder": 2, "title": "Slow Pour (4g/s)", "durationSeconds": 40, "waterAddedGrams": 80},
          {"stepOrder": 3, "title": "Fast Pour (5g/s)", "durationSeconds": 30, "waterAddedGrams": 100}
        ]
      },
      {
        "id": 14,
        "title": "Penyangraian Spesifik (2019 Juara 2)",
        "author": "Patrik Rolf 🇸🇪",
        "coverImageUrl": "assets/images/avatars/covers/patrik_rolf.jpg",
        "authorAvatarUrl": "assets/images/avatars/portraits/patrik_rolf.jpg",
        "authorImageUrl": "assets/images/avatars/covers/patrik_rolf.jpg",
        "beanName": "Gesha Natural Anaerobic (Panama)",
        "method": "April Brewer",
        "category": "Flat Bottom",
        "waterTempCelsius": 93,
        "grindSize": "Medium",
        "coffeeWeightGrams": 12,
        "totalWaterWeightGrams": 200,
        "totalTimeSeconds": 130,
        "description": "Patrik Rolf merancang perangkat seduhnya sendiri, April Pour-Over, berdasar datar. Uniknya, Rolf menggiling kopinya satu jam penuh sebelum kompetisi untuk memungkinkan pelepasan karbon dioksida seketika (rapid degassing). Ia kemudian membagi 200ml air seduhnya hanya dalam dua tahap penuangan agresif yang melarutkan kemanisan karamel secara maksimal.",
        "isCustom": false,
        "createdAt": now,
        "steps": [
          {"stepOrder": 1, "title": "Aggressive Pour 1", "durationSeconds": 60, "waterAddedGrams": 100},
          {"stepOrder": 2, "title": "Aggressive Pour 2", "durationSeconds": 70, "waterAddedGrams": 100}
        ]
      },
      {
        "id": 15,
        "title": "Relevansi Kopi Klasik (2019 Juara 3)",
        "author": "Alessandro Galtieri (Italia)",
        "coverImageUrl": "assets/images/avatars/covers/alessandro_galtieri.jpg",
        "authorAvatarUrl": "assets/images/avatars/portraits/alessandro_galtieri.jpg",
        "authorImageUrl": "assets/images/avatars/covers/alessandro_galtieri.jpg",
        "beanName": "Gesha (Panama)",
        "method": "Hario V60",
        "category": "V60 Pour Over",
        "waterTempCelsius": 92,
        "grindSize": "Medium",
        "coffeeWeightGrams": 15,
        "totalWaterWeightGrams": 250,
        "totalTimeSeconds": 150,
        "description": "Integrasi rasio klasik Italia dengan ekstraksi terukur dari kopi Gesha untuk tekstur bulat dan manis. Resep ini menggunakan rasio presisi 1:16.7 yang dirancang untuk menyeimbangkan ekstraksi secara optimal. Dengan memanfaatkan air bersuhu 92°C dan gilingan berukuran Medium to Coarse, teknik penuangan ini mampu memanipulasi turbulensi (agitasi) di dalam alat seduh. Hal ini memastikan pelepasan gas karbon dioksida saat fase blooming berjalan sempurna, serta mencegah terjadinya channeling (aliran air tak merata). Hasil akhirnya adalah secangkir kopi dengan spektrum rasa yang kompleks, menonjolkan tingkat kemanisan (sweetness) alami dan kejelasan (clarity) yang tajam.",
        "isCustom": false,
        "createdAt": now,
        "steps": [
          {"stepOrder": 1, "title": "Blooming", "durationSeconds": 30, "waterAddedGrams": 45},
          {"stepOrder": 2, "title": "Steady Pour", "durationSeconds": 120, "waterAddedGrams": 205}
        ]
      },
      // 2021
      {
        "id": 16,
        "title": "Seni Modulasi Suhu 5-Pour (2021 Juara 1)",
        "author": "Matt Winton 🇨🇭",
        "coverImageUrl": "assets/images/avatars/covers/matt_winton.jpg",
        "authorAvatarUrl": "assets/images/avatars/portraits/matt_winton.jpg",
        "authorImageUrl": "assets/images/avatars/covers/matt_winton.jpg",
        "beanName": "Eugenioides & Catucai (Kolombia)",
        "method": "Hario V60 Logam 02",
        "category": "V60 Pour Over",
        "waterTempCelsius": 93,
        "grindSize": "Medium Coarse",
        "coffeeWeightGrams": 20,
        "totalWaterWeightGrams": 300,
        "totalTimeSeconds": 150,
        "description": "Winton merebut tahta juara dengan mengombinasikan dua spesies berbeda: Eugenioides dan Catucai. Inovasi termalnya sangat krusial: ia menggunakan dua teko dengan suhu berbeda. Dua tuangan pertama menggunakan air 93°C untuk mengekstraksi senyawa buah dari Catucai, sementara tiga tuangan terakhir menggunakan teko kedua bersuhu 88°C untuk mengamankan ketebalan cairan dan menekan kepahitan dari tanin yang terekstraksi berlebih.",
        "isCustom": false,
        "createdAt": now,
        "steps": [
          {"stepOrder": 1, "title": "Bloom (93°C)", "durationSeconds": 30, "waterAddedGrams": 60},
          {"stepOrder": 2, "title": "Pour 2 (93°C)", "durationSeconds": 30, "waterAddedGrams": 60},
          {"stepOrder": 3, "title": "Pour 3 (88°C)", "durationSeconds": 30, "waterAddedGrams": 60},
          {"stepOrder": 4, "title": "Pour 4 (88°C)", "durationSeconds": 30, "waterAddedGrams": 60},
          {"stepOrder": 5, "title": "Pour 5 (88°C)", "durationSeconds": 30, "waterAddedGrams": 60}
        ]
      },
      {
        "id": 17,
        "title": "Pendinginan Kontrol Tanin (2021 Juara 2)",
        "author": "Daiki Hatakeyama 🇯🇵",
        "coverImageUrl": "assets/images/avatars/covers/daiki_hatakeyama.jpg",
        "authorAvatarUrl": "assets/images/avatars/portraits/daiki_hatakeyama.jpg",
        "authorImageUrl": "assets/images/avatars/covers/daiki_hatakeyama.jpg",
        "beanName": "Gesha Blend",
        "method": "Cafec Flower Dripper",
        "category": "Cone",
        "waterTempCelsius": 86,
        "grindSize": "Medium",
        "coffeeWeightGrams": 20,
        "totalWaterWeightGrams": 300,
        "totalTimeSeconds": 150,
        "description": "Menggunakan air bersuhu sangat rendah (85-88°C) dengan lima tahap tuangan. Hasil cangkir bebas kepahitan identik profil teh halus. Resep ini menggunakan rasio presisi 1:15.0 yang dirancang untuk menyeimbangkan ekstraksi secara optimal. Dengan memanfaatkan air bersuhu 86°C dan gilingan berukuran Medium to Coarse, teknik penuangan ini mampu memanipulasi turbulensi (agitasi) di dalam alat seduh. Hal ini memastikan pelepasan gas karbon dioksida saat fase blooming berjalan sempurna, serta mencegah terjadinya channeling (aliran air tak merata). Hasil akhirnya adalah secangkir kopi dengan spektrum rasa yang kompleks, menonjolkan tingkat kemanisan (sweetness) alami dan kejelasan (clarity) yang tajam.",
        "isCustom": false,
        "createdAt": now,
        "steps": [
          {"stepOrder": 1, "title": "Pour 1", "durationSeconds": 30, "waterAddedGrams": 60},
          {"stepOrder": 2, "title": "Pour 2", "durationSeconds": 30, "waterAddedGrams": 60},
          {"stepOrder": 3, "title": "Pour 3", "durationSeconds": 30, "waterAddedGrams": 60},
          {"stepOrder": 4, "title": "Pour 4", "durationSeconds": 30, "waterAddedGrams": 60},
          {"stepOrder": 5, "title": "Pour 5", "durationSeconds": 30, "waterAddedGrams": 60}
        ]
      },
      {
        "id": 18,
        "title": "Pembasmian Channelling (2021 Juara 3)",
        "author": "Elika Liftee 🇺🇸",
        "coverImageUrl": "assets/images/avatars/covers/elika_liftee.jpg",
        "authorAvatarUrl": "assets/images/avatars/portraits/elika_liftee.jpg",
        "authorImageUrl": "assets/images/avatars/covers/elika_liftee.jpg",
        "beanName": "Gesha (Varietas Langka)",
        "method": "V60 + Melodrip",
        "category": "V60 Pour Over",
        "waterTempCelsius": 92,
        "grindSize": "Medium",
        "coffeeWeightGrams": 15,
        "totalWaterWeightGrams": 250,
        "totalTimeSeconds": 160,
        "description": "Elika Liftee mengatasi kelemahan pencampuran biji kopi (blending) dua spesies yang memiliki kepadatan sel berbeda (Sudan Rume dan Eugenioides) dengan merakit seduhan secara berlapis (stacked). Ia meletakkan bubuk Eugenioides di dasar V60, lalu menumpuk Sudan Rume di atasnya tanpa mengaduknya! Dinamika cairan secara otomatis mengekstraksi bagian atas pada porsi tinggi dan bagian bawah pada persentase lebih rendah. Ia juga memanfaatkan alat Melodrip untuk mencegah agitasi kinetik, memastikan air turun seperti tetesan hujan lembut.",
        "isCustom": false,
        "createdAt": now,
        "steps": [
          {"stepOrder": 1, "title": "Melodrip Bloom", "durationSeconds": 40, "waterAddedGrams": 50},
          {"stepOrder": 2, "title": "Melodrip Pulse", "durationSeconds": 120, "waterAddedGrams": 200}
        ]
      },
      // 2022
      {
        "id": 19,
        "title": "Gilingan Pecah & Rentang Kontras (2022 Juara 1)",
        "author": "Shih Yuan Hsu 🇹🇼",
        "coverImageUrl": "assets/images/avatars/covers/shih_yuan_hsu.jpg",
        "authorAvatarUrl": "assets/images/avatars/portraits/shih_yuan_hsu.jpg",
        "authorImageUrl": "assets/images/avatars/covers/shih_yuan_hsu.jpg",
        "beanName": "Finca Mikava Gesha CM",
        "method": "Orea V3",
        "category": "Flat Bottom",
        "waterTempCelsius": 95,
        "grindSize": "Blend",
        "coffeeWeightGrams": 14,
        "totalWaterWeightGrams": 200,
        "totalTimeSeconds": 140,
        "description": "Sherry mengeksekusi geometri pemotongan gilingan dengan taktik presisi. Ia menciptakan 'blend gilingan' dari biji yang sama: mencampurkan 75% bubuk gilingan kasar (1000 mikron) dengan 25% gilingan halus (800 mikron). Trik granulometri ini memungkinkan laju ekstraksi ganda bersamaan. Penuangan pertama diaplikasikan pada suhu rendah 70°C agar floral notes tidak hancur. Tiga tuangan sisanya dihentak pada suhu 95°C yang mendidih untuk melarutkan gula berat menjadi karamel cair pekat.",
        "isCustom": false,
        "createdAt": now,
        "steps": [
          {"stepOrder": 1, "title": "Cold Bloom (70°C)", "durationSeconds": 40, "waterAddedGrams": 50},
          {"stepOrder": 2, "title": "Hot Pour 1 (95°C)", "durationSeconds": 33, "waterAddedGrams": 50},
          {"stepOrder": 3, "title": "Hot Pour 2 (95°C)", "durationSeconds": 33, "waterAddedGrams": 50},
          {"stepOrder": 4, "title": "Hot Pour 3 (95°C)", "durationSeconds": 34, "waterAddedGrams": 50}
        ]
      },
      {
        "id": 20,
        "title": "Resep Lapis Susun (Stacked) (2022 Juara 2)",
        "author": "Elika Liftee 🇺🇸",
        "coverImageUrl": "assets/images/avatars/covers/elika_liftee.jpg",
        "authorAvatarUrl": "assets/images/avatars/portraits/elika_liftee.jpg",
        "authorImageUrl": "assets/images/avatars/covers/elika_liftee.jpg",
        "beanName": "Eugenioides & Sudan Rume",
        "method": "Hario V60",
        "category": "V60 Pour Over",
        "waterTempCelsius": 93,
        "grindSize": "Medium",
        "coffeeWeightGrams": 16,
        "totalWaterWeightGrams": 250,
        "totalTimeSeconds": 160,
        "description": "Elika Liftee mengatasi kelemahan pencampuran biji kopi (blending) dua spesies yang memiliki kepadatan sel berbeda (Sudan Rume dan Eugenioides) dengan merakit seduhan secara berlapis (stacked). Ia meletakkan bubuk Eugenioides di dasar V60, lalu menumpuk Sudan Rume di atasnya tanpa mengaduknya! Dinamika cairan secara otomatis mengekstraksi bagian atas pada porsi tinggi dan bagian bawah pada persentase lebih rendah. Ia juga memanfaatkan alat Melodrip untuk mencegah agitasi kinetik, memastikan air turun seperti tetesan hujan lembut.",
        "isCustom": false,
        "createdAt": now,
        "steps": [
          {"stepOrder": 1, "title": "Stacked Bloom", "durationSeconds": 40, "waterAddedGrams": 50},
          {"stepOrder": 2, "title": "Gentle Pours", "durationSeconds": 120, "waterAddedGrams": 200}
        ]
      },
      {
        "id": 21,
        "title": "Membangun Rumah Liberica (2022 Juara 3)",
        "author": "Elysia Tan 🇸🇬",
        "coverImageUrl": "assets/images/avatars/covers/elysia_tan.jpg",
        "authorAvatarUrl": "assets/images/avatars/portraits/elysia_tan.jpg",
        "authorImageUrl": "assets/images/avatars/covers/elysia_tan.jpg",
        "beanName": "Gesha Panama & Liberica Indonesia",
        "method": "Orea V3 + Sibarist",
        "category": "Flat Bottom",
        "waterTempCelsius": 92,
        "grindSize": "Medium",
        "coffeeWeightGrams": 16,
        "totalWaterWeightGrams": 270,
        "totalTimeSeconds": 150,
        "description": "Menggunakan kertas Sibarist cepat. Analogi membangun rumah: Liberica sebagai fondasi tebal, Gesha sebagai atap bunga melati. Resep ini menggunakan rasio presisi 1:16.9 yang dirancang untuk menyeimbangkan ekstraksi secara optimal. Dengan memanfaatkan air bersuhu 92°C dan gilingan berukuran Medium to Coarse, teknik penuangan ini mampu memanipulasi turbulensi (agitasi) di dalam alat seduh. Hal ini memastikan pelepasan gas karbon dioksida saat fase blooming berjalan sempurna, serta mencegah terjadinya channeling (aliran air tak merata). Hasil akhirnya adalah secangkir kopi dengan spektrum rasa yang kompleks, menonjolkan tingkat kemanisan (sweetness) alami dan kejelasan (clarity) yang tajam.",
        "isCustom": false,
        "createdAt": now,
        "steps": [
          {"stepOrder": 1, "title": "Pondasi (Bloom)", "durationSeconds": 30, "waterAddedGrams": 60},
          {"stepOrder": 2, "title": "Dinding 1", "durationSeconds": 40, "waterAddedGrams": 70},
          {"stepOrder": 3, "title": "Dinding 2", "durationSeconds": 40, "waterAddedGrams": 70},
          {"stepOrder": 4, "title": "Atap", "durationSeconds": 40, "waterAddedGrams": 70}
        ]
      },
      // 2023
      {
        "id": 22,
        "title": "Simetri dan Repetisi Geometri (2023 Juara 1)",
        "author": "Carlos Medina (Chili)",
        "coverImageUrl": "assets/images/avatars/covers/carlos_medina.jpg",
        "authorAvatarUrl": "assets/images/avatars/portraits/carlos_medina.jpg",
        "authorImageUrl": "assets/images/avatars/covers/carlos_medina.jpg",
        "beanName": "Sidra (Granja La Esperanza)",
        "method": "Origami Dripper Air S",
        "category": "Origami",
        "waterTempCelsius": 91,
        "grindSize": "Medium Fine",
        "coffeeWeightGrams": 15.5,
        "totalWaterWeightGrams": 250,
        "totalTimeSeconds": 160,
        "description": "Medina membawa filosofi repetisi. Ia menerapkan simetri geometri yang dingin menggunakan Origami Dripper Air S. Resepnya adalah garis lurus matematis: tuangan dibagi persis sama rata menjadi lima kali masing-masing 50 gram. Setiap tuangan diberikan jeda istirahat eksak selama 30 detik. Dengan air mineral berskala 65 ppm rasio setara Magnesium dan Kalsium, tidak ada ruang bagi variabel tak terkendali, menghasilkan minuman yang dipenuhi asam tartarat dan sisa rasa persik bening.",
        "isCustom": false,
        "createdAt": now,
        "steps": [
          {"stepOrder": 1, "title": "Pour 1", "durationSeconds": 30, "waterAddedGrams": 50},
          {"stepOrder": 2, "title": "Pour 2", "durationSeconds": 30, "waterAddedGrams": 50},
          {"stepOrder": 3, "title": "Pour 3", "durationSeconds": 30, "waterAddedGrams": 50},
          {"stepOrder": 4, "title": "Pour 4", "durationSeconds": 30, "waterAddedGrams": 50},
          {"stepOrder": 5, "title": "Pour 5", "durationSeconds": 40, "waterAddedGrams": 50}
        ]
      },
      {
        "id": 23,
        "title": "Konstruksi Keramik Osmotik (2023 Juara 2)",
        "author": "Savina Giachgia 🇬🇷",
        "coverImageUrl": "assets/images/avatars/covers/savina_giachgia.jpg",
        "authorAvatarUrl": "assets/images/avatars/portraits/savina_giachgia.jpg",
        "authorImageUrl": "assets/images/avatars/covers/savina_giachgia.jpg",
        "beanName": "Campuran 2 Spesies Kopi Spesifik",
        "method": "Modifikasi Kerucut",
        "category": "Cone",
        "waterTempCelsius": 92,
        "grindSize": "Medium",
        "coffeeWeightGrams": 15,
        "totalWaterWeightGrams": 250,
        "totalTimeSeconds": 150,
        "description": "Menggunakan keramik One Drop dengan modifikasi air ditargetkan pada elemen osmotik ekstraksi molekuler. Resep ini menggunakan rasio presisi 1:16.7 yang dirancang untuk menyeimbangkan ekstraksi secara optimal. Dengan memanfaatkan air bersuhu 92°C dan gilingan berukuran Medium to Coarse, teknik penuangan ini mampu memanipulasi turbulensi (agitasi) di dalam alat seduh. Hal ini memastikan pelepasan gas karbon dioksida saat fase blooming berjalan sempurna, serta mencegah terjadinya channeling (aliran air tak merata). Hasil akhirnya adalah secangkir kopi dengan spektrum rasa yang kompleks, menonjolkan tingkat kemanisan (sweetness) alami dan kejelasan (clarity) yang tajam.",
        "isCustom": false,
        "createdAt": now,
        "steps": [
          {"stepOrder": 1, "title": "Osmotic Bloom", "durationSeconds": 40, "waterAddedGrams": 50},
          {"stepOrder": 2, "title": "Extraction Pour", "durationSeconds": 110, "waterAddedGrams": 200}
        ]
      },
      {
        "id": 24,
        "title": "Rapid Chilling Peternakan (2023 Juara 3)",
        "author": "Garam Victor Um (Brasil)",
        "coverImageUrl": "assets/images/avatars/covers/garam_victor_um.jpg",
        "authorAvatarUrl": "assets/images/avatars/portraits/garam_victor_um.jpg",
        "authorImageUrl": "assets/images/avatars/covers/garam_victor_um.jpg",
        "beanName": "Janson Gesha & Pink Bourbon",
        "method": "Tornado Duo",
        "category": "Hybrid",
        "waterTempCelsius": 93,
        "grindSize": "Medium",
        "coffeeWeightGrams": 15,
        "totalWaterWeightGrams": 240,
        "totalTimeSeconds": 140,
        "description": "Menggunakan kopi pertanian sendiri. Tiga tuangan agresif, diseduh ke alat pendingin cepat (rapid chilling) menyematkan intensitas kismis hitam. Resep ini menggunakan rasio presisi 1:16.0 yang dirancang untuk menyeimbangkan ekstraksi secara optimal. Dengan memanfaatkan air bersuhu 93°C dan gilingan berukuran Medium to Coarse, teknik penuangan ini mampu memanipulasi turbulensi (agitasi) di dalam alat seduh. Hal ini memastikan pelepasan gas karbon dioksida saat fase blooming berjalan sempurna, serta mencegah terjadinya channeling (aliran air tak merata). Hasil akhirnya adalah secangkir kopi dengan spektrum rasa yang kompleks, menonjolkan tingkat kemanisan (sweetness) alami dan kejelasan (clarity) yang tajam.",
        "isCustom": false,
        "createdAt": now,
        "steps": [
          {"stepOrder": 1, "title": "Bloom Pour", "durationSeconds": 40, "waterAddedGrams": 60},
          {"stepOrder": 2, "title": "Body Pour", "durationSeconds": 50, "waterAddedGrams": 80},
          {"stepOrder": 3, "title": "Chilling Pour", "durationSeconds": 50, "waterAddedGrams": 100}
        ]
      },
      // 2024
      {
        "id": 25,
        "title": "Laboratorium Cepat Orea V4 (2024 Juara 1)",
        "author": "Martin Wölfl 🇦🇹",
        "coverImageUrl": "assets/images/avatars/covers/martin_wolfl.jpg",
        "authorAvatarUrl": "assets/images/avatars/portraits/martin_wolfl.jpg",
        "authorImageUrl": "assets/images/avatars/covers/martin_wolfl.jpg",
        "beanName": "Finca Maya Gesha Anaerobik",
        "method": "Orea V4 + Melodrip + WDT",
        "category": "Flat Bottom",
        "waterTempCelsius": 93,
        "grindSize": "Medium Fine",
        "coffeeWeightGrams": 17,
        "totalWaterWeightGrams": 270,
        "totalTimeSeconds": 140,
        "description": "Metode Wölfl adalah purwarupa penuangan ultra-modern di mana agitasi fisik secara konseptual 'dibunuh'. Ia menggunakan Orea V4 dengan kertas saring lab Sibarist, dan mendistribusikan kopi (490 mikron seragam) dengan jarum WDT. Aliran cerek dipecah oleh penyebar air Theo Shower Screen. Bubuk kopinya dapat menelan air ekstraksi secepat 2 menit 20 detik tanpa ada celah pelarutan asimetris, mengekstraksi tingkat gula paling murni dan menolak senyawa beraroma kayu.",
        "isCustom": false,
        "createdAt": now,
        "steps": [
          {"stepOrder": 1, "title": "Shower Bloom", "durationSeconds": 40, "waterAddedGrams": 60},
          {"stepOrder": 2, "title": "Pulse 2", "durationSeconds": 40, "waterAddedGrams": 60},
          {"stepOrder": 3, "title": "Pulse 3", "durationSeconds": 40, "waterAddedGrams": 50},
          {"stepOrder": 4, "title": "Final Pulse", "durationSeconds": 20, "waterAddedGrams": 100}
        ]
      },
      {
        "id": 26,
        "title": "Kriogenik Sandwich Dose (2024 Juara 2)",
        "author": "Wataru Iidaka 🇯🇵",
        "coverImageUrl": "assets/images/avatars/covers/wataru_iidaka.jpg",
        "authorAvatarUrl": "assets/images/avatars/portraits/wataru_iidaka.jpg",
        "authorImageUrl": "assets/images/avatars/covers/wataru_iidaka.jpg",
        "beanName": "Tiga Lapis Panama Gesha",
        "method": "V60 + Paragon",
        "category": "V60 Pour Over",
        "waterTempCelsius": 92,
        "grindSize": "Medium",
        "coffeeWeightGrams": 15,
        "totalWaterWeightGrams": 250,
        "totalTimeSeconds": 150,
        "description": "Wataru mengeksekusi mekanika termodinamika kompleks menggunakan dosing tiga lapis (sandwich dose). Ekstraksinya didistribusikan melalui bantalan Melodrip terbalik, lalu mengalir melintasi bola es logam Paragon bertemperatur minus 5°C. Kondensasi kriogenik cepat (rapid chilling) ini menangkap profil Volatile Organic Compounds (VOC) yang umumnya menguap saat terseduh panas, menyegel aroma kembang sepatu langsung ke dalam minumannya.",
        "isCustom": false,
        "createdAt": now,
        "steps": [
          {"stepOrder": 1, "title": "Cryo Bloom", "durationSeconds": 30, "waterAddedGrams": 50},
          {"stepOrder": 2, "title": "Gentle Percolation", "durationSeconds": 120, "waterAddedGrams": 200}
        ]
      },
      {
        "id": 27,
        "title": "Bhinneka Tunggal Ika (2024 Juara 3)",
        "author": "Ryan Wibawa 🇮🇩",
        "coverImageUrl": "assets/images/avatars/covers/ryan_wibawa.jpg",
        "authorAvatarUrl": "assets/images/avatars/portraits/ryan_wibawa.jpg",
        "authorImageUrl": "assets/images/avatars/covers/ryan_wibawa.jpg",
        "beanName": "Gesha, Ombligon, Excelsa Sumedang",
        "method": "Hario Switch + Drip Assist",
        "category": "Hybrid",
        "waterTempCelsius": 86,
        "grindSize": "Coarse",
        "coffeeWeightGrams": 15,
        "totalWaterWeightGrams": 220,
        "totalTimeSeconds": 140,
        "description": "Ryan Wibawa mengunci posisi ketiga lewat pendekatan Bhinneka Tunggal Ika dengan Hario Switch. Ia memasukkan kopi Excelsa dari Sumedang sebagai pengikat tebal (body matrix) untuk spesies Ombligon dan Gesha. Wibawa meniadakan turbulensi dengan penuangan melalui Drip Assist. Pada tuas katup tertutup, ia memberikan imersi suhu 86°C selama 40 detik. Cairan kedua menyusul di 92°C direndam sebelum dilepas bebas. Ini meredam agresi keasaman menjadi harmoni rasa sempurna.",
        "isCustom": false,
        "createdAt": now,
        "steps": [
          {"stepOrder": 1, "title": "Imersi Tertutup (86°C)", "durationSeconds": 40, "waterAddedGrams": 100},
          {"stepOrder": 2, "title": "Perkolasi Terbuka (92°C)", "durationSeconds": 100, "waterAddedGrams": 120}
        ]
      },
      // 2025
      {
        "id": 28,
        "title": "Probe Termal Suhu Transisi (2025 Juara 1)",
        "author": "Peng Jinyang 🇨🇳",
        "coverImageUrl": "assets/images/avatars/covers/peng_jinyang.jpg",
        "authorAvatarUrl": "assets/images/avatars/portraits/peng_jinyang.jpg",
        "authorImageUrl": "assets/images/avatars/covers/peng_jinyang.jpg",
        "beanName": "Mount Totumas Gesha",
        "method": "Solo Dripper",
        "category": "Cone",
        "waterTempCelsius": 96,
        "grindSize": "Medium",
        "coffeeWeightGrams": 15,
        "totalWaterWeightGrams": 210,
        "totalTimeSeconds": 150,
        "description": "Peng Jinyang merombak tradisi dengan menyangrai satu kopi dalam tiga delta suhu berbeda sebelum mencampurnya kembali. Ia menggunakan Solo Dripper dan membawa thermal probe ke meja juri untuk merekam penurunan suhu aktual. Tuangan awal di suhu 96°C mengekstraksi lapisan dasar, lalu tuangan terakhir dihancurkan suhunya menjadi 80°C yang dihantarkan lewat Melodrip untuk mencegah ekstraksi zat astringency (penyebab kering di mulut).",
        "isCustom": false,
        "createdAt": now,
        "steps": [
          {"stepOrder": 1, "title": "Hot Bloom (96°C)", "durationSeconds": 40, "waterAddedGrams": 50},
          {"stepOrder": 2, "title": "Hot Pour (96°C)", "durationSeconds": 50, "waterAddedGrams": 80},
          {"stepOrder": 3, "title": "Cold Melodrip (80°C)", "durationSeconds": 60, "waterAddedGrams": 80}
        ]
      },
      {
        "id": 29,
        "title": "Segitiga Eksposur Kamera (2025 Juara 2)",
        "author": "Bayu Prawiro 🇮🇩",
        "coverImageUrl": "assets/images/avatars/covers/bayu_prawiro.jpg",
        "authorAvatarUrl": "assets/images/avatars/portraits/bayu_prawiro.jpg",
        "authorImageUrl": "assets/images/avatars/covers/bayu_prawiro.jpg",
        "beanName": "Gesha & Excelsa Indonesia",
        "method": "Hario Switch + Drip Assist",
        "category": "Hybrid",
        "waterTempCelsius": 93,
        "grindSize": "Medium",
        "coffeeWeightGrams": 15,
        "totalWaterWeightGrams": 220,
        "totalTimeSeconds": 140,
        "description": "Bayu menggunakan kerangka narasi 'Segitiga Eksposur' kamera mekanis. Agitasi sebagai aperture (lensa), aliran (flow rate) sebagai shutter speed, dan durasi sebagai ISO. Perpaduan biji kopi Excelsa dan Gesha dikelola menggunakan Drip Assist di atas Hario Switch, mengunci rasa asam kompleks ke dalam wadah cairan yang lambat memudar di ujung lidah.",
        "isCustom": false,
        "createdAt": now,
        "steps": [
          {"stepOrder": 1, "title": "Aperture Bloom", "durationSeconds": 40, "waterAddedGrams": 60},
          {"stepOrder": 2, "title": "Shutter Pour", "durationSeconds": 100, "waterAddedGrams": 160}
        ]
      },
      {
        "id": 30,
        "title": "Ragi Bioreaktor Agrikultur (2025 Juara 3)",
        "author": "Carlos Escobar (Kolombia)",
        "coverImageUrl": "assets/images/avatars/covers/carlos_escobar.jpg",
        "authorAvatarUrl": "assets/images/avatars/portraits/carlos_escobar.jpg",
        "authorImageUrl": "assets/images/avatars/covers/carlos_escobar.jpg",
        "beanName": "Maracaturra Peña Blancas (Ragi)",
        "method": "Hario Switch",
        "category": "Hybrid",
        "waterTempCelsius": 90,
        "grindSize": "Medium",
        "coffeeWeightGrams": 14.5,
        "totalWaterWeightGrams": 200,
        "totalTimeSeconds": 150,
        "description": "Fraksi mikrobioma dimaksimalkan dengan wadah selective flow Hario Switch untuk kopi kultur ragi. Resep ini menggunakan rasio presisi 1:13.8 yang dirancang untuk menyeimbangkan ekstraksi secara optimal. Dengan memanfaatkan air bersuhu 90°C dan gilingan berukuran Medium to Coarse, teknik penuangan ini mampu memanipulasi turbulensi (agitasi) di dalam alat seduh. Hal ini memastikan pelepasan gas karbon dioksida saat fase blooming berjalan sempurna, serta mencegah terjadinya channeling (aliran air tak merata). Hasil akhirnya adalah secangkir kopi dengan spektrum rasa yang kompleks, menonjolkan tingkat kemanisan (sweetness) alami dan kejelasan (clarity) yang tajam.",
        "isCustom": false,
        "createdAt": now,
        "steps": [
          {"stepOrder": 1, "title": "Selective Bloom", "durationSeconds": 45, "waterAddedGrams": 50},
          {"stepOrder": 2, "title": "Bioreactor Flow", "durationSeconds": 105, "waterAddedGrams": 150}
        ]
      },
      // 2026
      {
        "id": 31,
        "title": "Dinamika Gesekan & Nol Bypass (2026 Juara 1)",
        "author": "Nas Jaafar 🇲🇾",
        "coverImageUrl": "assets/images/avatars/covers/nas_jaafar.jpg",
        "authorAvatarUrl": "assets/images/avatars/portraits/nas_jaafar.jpg",
        "authorImageUrl": "assets/images/avatars/covers/nas_jaafar.jpg",
        "beanName": "Genetika Gesha Khusus",
        "method": "UFO V3 + Switch Base",
        "category": "Hybrid",
        "waterTempCelsius": 92,
        "grindSize": "Medium Coarse",
        "coffeeWeightGrams": 15,
        "totalWaterWeightGrams": 200,
        "totalTimeSeconds": 140,
        "description": "Nas Jaafar menciptakan alat hibrida dengan menempelkan corong UFO V3 berdinding datar 80 derajat di atas dasar karet Hario Switch berkatup. Temanya adalah 'Perlawanan' (Resistance). UFO V3 menyebarkan bubuk sedemikian lebarnya hingga perlawanan aliran cairan hampir nol (zero bypass). Setelah perkolasi pertama menembus, Nas menutup tuas, memaksa 100 gram air kedua mengalami imersi statis untuk membentuk rantai tekstur body struktur yang tebal.",
        "isCustom": false,
        "createdAt": now,
        "steps": [
          {"stepOrder": 1, "title": "Zero Resistance Pour", "durationSeconds": 50, "waterAddedGrams": 100},
          {"stepOrder": 2, "title": "Static Immersion", "durationSeconds": 90, "waterAddedGrams": 100}
        ]
      },
      {
        "id": 32,
        "title": "Kejernihan Mutlak Tabung (2026 Juara 2)",
        "author": "Simon Gautherin 🇦🇺",
        "coverImageUrl": "assets/images/avatars/covers/simon_gautherin.jpg",
        "authorAvatarUrl": "assets/images/avatars/portraits/simon_gautherin.jpg",
        "authorImageUrl": "assets/images/avatars/covers/simon_gautherin.jpg",
        "beanName": "Nuguo & Gesha Penas Blancas",
        "method": "NextLevel Pulsar",
        "category": "Hybrid",
        "waterTempCelsius": 92,
        "grindSize": "Medium",
        "coffeeWeightGrams": 15,
        "totalWaterWeightGrams": 200,
        "totalTimeSeconds": 150,
        "description": "Zero bypass dengan air kalibrasi konsentrat mineral murni 155ppm. Perendaman dingin lalu dilepas untuk manis buah aprikot mutlak. Resep ini menggunakan rasio presisi 1:13.3 yang dirancang untuk menyeimbangkan ekstraksi secara optimal. Dengan memanfaatkan air bersuhu 92°C dan gilingan berukuran Medium to Coarse, teknik penuangan ini mampu memanipulasi turbulensi (agitasi) di dalam alat seduh. Hal ini memastikan pelepasan gas karbon dioksida saat fase blooming berjalan sempurna, serta mencegah terjadinya channeling (aliran air tak merata). Hasil akhirnya adalah secangkir kopi dengan spektrum rasa yang kompleks, menonjolkan tingkat kemanisan (sweetness) alami dan kejelasan (clarity) yang tajam.",
        "isCustom": false,
        "createdAt": now,
        "steps": [
          {"stepOrder": 1, "title": "Immersion Phase", "durationSeconds": 60, "waterAddedGrams": 100},
          {"stepOrder": 2, "title": "Release Phase", "durationSeconds": 90, "waterAddedGrams": 100}
        ]
      },
      {
        "id": 33,
        "title": "Isolasi Debu Sandwich (2026 Juara 3)",
        "author": "Bavis Kwong 🇭🇰",
        "coverImageUrl": "assets/images/avatars/covers/bavis_kwong.jpg",
        "authorAvatarUrl": "assets/images/avatars/portraits/bavis_kwong.jpg",
        "authorImageUrl": "assets/images/avatars/covers/bavis_kwong.jpg",
        "beanName": "Kolaborasi Spesifik",
        "method": "V60",
        "category": "V60 Pour Over",
        "waterTempCelsius": 92,
        "grindSize": "Medium",
        "coffeeWeightGrams": 15,
        "totalWaterWeightGrams": 250,
        "totalTimeSeconds": 150,
        "description": "Membongkar migrasi debu kopi dengan sandwich dosing: bubuk halus dikubur di tengah dinding kasar untuk mencegah sumbatan gravitasi. Resep ini menggunakan rasio presisi 1:16.7 yang dirancang untuk menyeimbangkan ekstraksi secara optimal. Dengan memanfaatkan air bersuhu 92°C dan gilingan berukuran Medium to Coarse, teknik penuangan ini mampu memanipulasi turbulensi (agitasi) di dalam alat seduh. Hal ini memastikan pelepasan gas karbon dioksida saat fase blooming berjalan sempurna, serta mencegah terjadinya channeling (aliran air tak merata). Hasil akhirnya adalah secangkir kopi dengan spektrum rasa yang kompleks, menonjolkan tingkat kemanisan (sweetness) alami dan kejelasan (clarity) yang tajam.",
        "isCustom": false,
        "createdAt": now,
        "steps": [
          {"stepOrder": 1, "title": "Sandwich Bloom", "durationSeconds": 40, "waterAddedGrams": 50},
          {"stepOrder": 2, "title": "Gravity Pours", "durationSeconds": 110, "waterAddedGrams": 200}
        ]
      }
    ];
  }

  static List<Map<String, dynamic>> getDefaultBasecamps() {
    return [
      {
        "id": 1,
        "name": "WBrC Champions Club",
        "description": "Eksklusif diskusi teknik Juara Dunia WBrC. Resep ini menggunakan rasio presisi 1:16.7 yang dirancang untuk menyeimbangkan ekstraksi secara optimal. Dengan memanfaatkan air bersuhu 92°C dan gilingan berukuran Medium to Coarse, teknik penuangan ini mampu memanipulasi turbulensi (agitasi) di dalam alat seduh. Hal ini memastikan pelepasan gas karbon dioksida saat fase blooming berjalan sempurna, serta mencegah terjadinya channeling (aliran air tak merata). Hasil akhirnya adalah secangkir kopi dengan spektrum rasa yang kompleks, menonjolkan tingkat kemanisan (sweetness) alami dan kejelasan (clarity) yang tajam.",
        "isPrivate": false
      },
      {
        "id": 2,
        "name": "Hybrid Dripper Enthusiast",
        "description": "Pecinta Hario Switch & Pulsar. Resep ini menggunakan rasio presisi 1:16.7 yang dirancang untuk menyeimbangkan ekstraksi secara optimal. Dengan memanfaatkan air bersuhu 92°C dan gilingan berukuran Medium to Coarse, teknik penuangan ini mampu memanipulasi turbulensi (agitasi) di dalam alat seduh. Hal ini memastikan pelepasan gas karbon dioksida saat fase blooming berjalan sempurna, serta mencegah terjadinya channeling (aliran air tak merata). Hasil akhirnya adalah secangkir kopi dengan spektrum rasa yang kompleks, menonjolkan tingkat kemanisan (sweetness) alami dan kejelasan (clarity) yang tajam.",
        "isPrivate": false
      }
    ];
  }
}
