import re

file_path = 'E:/APPS From Agent/Mobile-Flutter/Coffee Hub/coffee_hub_mobile/lib/services/seed_data.dart'

with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Detailed mappings based on the PDF text
specific_data = {
    "Odd-Steinar Tøllefsen": {
        "grindSize": "Sangat Seragam (Sifting)",
        "desc": "Pada tahun 2015, Odd-Steinar mendobrak dogma dengan menggunakan kopi proses natural (Ninety Plus Nekisse) yang menonjolkan profil buah tropis yang pekat namun luar biasa bersih. Ekstraksi dimulai dengan masa pra-infusi (blooming) selama 45 detik, menghasilkan total waktu seduh 3 menit 30 detik. Keputusan krusialnya terletak pada penggunaan air mineral alami dari pantai barat Norwegia yang memiliki kandungan mineral sangat rendah. Hal ini memberikan tekstur lembut yang menonjolkan profil rasa mangga, markisa, dan aprikot."
    },
    "Konstantinos Iatridis": {
        "grindSize": "Kasar Seragam (Biji Dibekukan)",
        "desc": "Konstantinos memperkenalkan teknik mekanis prapanggung yang sangat inovatif. Ia menyadari selaput perak (silver skin) sering menyumbangkan rasa sepat. Ia menggiling bijinya secara manual dan meniup sisa selaput perak tersebut. Lebih jauh lagi, ia membekukan biji kopinya di dalam lemari es sebelum digiling! Penurunan suhu ini mengubah biji kopi menjadi sangat rapuh (brittle), sehingga saat digiling, biji pecah dengan lebih seragam dan menghasilkan jauh lebih sedikit debu kopi (fines). Ini mencegah penyumbatan filter dan membangkitkan rasa pepaya dan bunga jeruk."
    },
    "Benjamin Prager": {
        "grindSize": "250-350 Mikron (Diayak)",
        "desc": "Prager mengisolasi ukuran partikel kopinya dengan saringan baja tahan karat berukuran 350 mikron dan 250 mikron. Secara kinetik, alih-alih menuangkan air dalam beberapa tahap, ia menuangkan seluruh volume air 236 gram sekaligus setelah blooming! Keputusan ini dirancang untuk menciptakan kurva penurunan suhu yang stabil di dalam slurry (campuran air dan kopi), yang secara termodinamika membantu memperlambat ekstraksi komponen tanin yang pahit, menghasilkan profil cangkir yang mirip teh buah dengan body sehalus sutra."
    },
    "Tetsu Kasuya": {
        "grindSize": "Sangat Kasar (Very Coarse)",
        "desc": "Tahun 2016 menjadi titik balik historis dengan diperkenalkannya Metode 4:6. Teori ini membagi air seduhan menjadi dua fraksi utama. Fraksi pertama (40% air) difokuskan pada pelarutan asam dan gula, di mana Kasuya menuangkan 50g air pertama dan 70g air kedua untuk memanipulasi rasio keasaman terhadap rasa manis. Fraksi kedua (60% air) dibagi menjadi tiga tuangan berturut-turut untuk mengatur intensitas konsentrasi (strength). Metodologi ini bergantung mutlak pada gilingan kopi yang sangat kasar untuk memastikan air turun dengan cepat, mengekstraksi tingkat kejernihan ekstrem tanpa over-ekstraksi."
    },
    "Mikaela Wallgren": {
        "grindSize": "Menengah Halus (Tanpa Fines)",
        "desc": "Mikaela membawa semangat realisme kedai kopi ke panggung dunia. Menggunakan Kalita Wave 155 berbahan logam, dasar Kalita yang datar memberikan ekstraksi yang lebih merata tanpa harus memanipulasi air terlalu banyak. Setelah memisahkan fines (debu kopi) dengan saringan, Mikaela melakukan tuangan spiral secara perlahan dan terus-menerus hingga mencapai target 250 gram air pada menit 1:45. Air yang digunakan adalah hasil manipulasi Reverse Osmosis yang mengoptimalkan daya tarik senyawa rasa manis."
    },
    "Chad Wang": {
        "grindSize": "Menengah Kasar (Medium Coarse)",
        "desc": "Chad Wang memenangkan kompetisi dengan presisi tinggi. Ia tidak melakukan pergerakan memutar saat menuang, melainkan menjaga aliran air jatuh persis di tengah dripper secara statis. Pendekatan ini menjaga suhu slurry sangat panas dan stabil, mendorong tingkat ekstraksi yang seragam. Rutinitas ini mendeskripsikan transisi presisi dari rasa persik saat panas, bunga jeruk pada suhu hangat, dan likur pisang ketika kopi mendingin."
    },
    "Sam Corra": {
        "grindSize": "Kasar (Coarse)",
        "desc": "Sam Corra mencatatkan sejarah dengan kopi proses Carbonic Maceration (CM), teknik pinjaman dari industri winemaking. Corra menggunakan gilingan kasar dan membagi 300ml air menjadi lima tuangan agresif secara cepat. Presentasinya secara gamblang memisahkan elemen terroir (pengaruh alam) dan profil yang sengaja direkayasa melalui intervensi mikrobiologi fermentasi."
    },
    "Emi Fukahori": {
        "grindSize": "Menengah (Medium)",
        "desc": "Fukahori mengguncang tatanan dengan varietas Laurina, sebuah mutasi dari pohon Bourbon yang memiliki kandungan kafein dan asam klorogenat 50% lebih rendah. Hal ini membuatnya hampir mustahil diekstraksi menjadi pahit. Ia menggunakan alat seduh GINA. Ia menutup katup bawah untuk fase imersi dengan air 80°C selama 45 detik (menarik molekul gula), lalu membuka katup dengan air 95°C (menarik asam buah), dan menutupnya kembali di tahap akhir untuk menambah bobot tekstur."
    },
    "Du Jianing": {
        "grindSize": "Penggilingan Ganda (Double Grind)",
        "desc": "Du Jianing memenangkan kompetisi dengan kecepatan penyeduhan ekstrem: 1 menit 40 detik menggunakan Origami Dripper. Kunci utamanya adalah teknik penggilingan ganda (double grinding). Jianing pertama-tama menggiling biji secara kasar untuk melepaskan kulit ari tipisnya, meniupnya dengan alat pembersih, lalu menggiling ulang fragmen yang tersisa menjadi ukuran halus. Menggunakan jarum WDT, serbuk diratakan sehingga tidak ada jalur buntu. Aliran air dijatuhkan secara matematis: 6g/detik, 4g/detik, dan 5g/detik."
    },
    "Patrik Rolf": {
        "grindSize": "Menengah (Rapid Degassing)",
        "desc": "Patrik Rolf merancang perangkat seduhnya sendiri, April Pour-Over, berdasar datar. Uniknya, Rolf menggiling kopinya satu jam penuh sebelum kompetisi untuk memungkinkan pelepasan karbon dioksida seketika (rapid degassing). Ia kemudian membagi 200ml air seduhnya hanya dalam dua tahap penuangan agresif yang melarutkan kemanisan karamel secara maksimal."
    },
    "Matt Winton": {
        "grindSize": "Kasar-Menengah (Medium Coarse)",
        "desc": "Winton merebut tahta juara dengan mengombinasikan dua spesies berbeda: Eugenioides dan Catucai. Inovasi termalnya sangat krusial: ia menggunakan dua teko dengan suhu berbeda. Dua tuangan pertama menggunakan air 93°C untuk mengekstraksi senyawa buah dari Catucai, sementara tiga tuangan terakhir menggunakan teko kedua bersuhu 88°C untuk mengamankan ketebalan cairan dan menekan kepahitan dari tanin yang terekstraksi berlebih."
    },
    "Shih Yuan Hsu": {
        "grindSize": "Blend (75% Kasar, 25% Halus)",
        "desc": "Sherry mengeksekusi geometri pemotongan gilingan dengan taktik presisi. Ia menciptakan 'blend gilingan' dari biji yang sama: mencampurkan 75% bubuk gilingan kasar (1000 mikron) dengan 25% gilingan halus (800 mikron). Trik granulometri ini memungkinkan laju ekstraksi ganda bersamaan. Penuangan pertama diaplikasikan pada suhu rendah 70°C agar floral notes tidak hancur. Tiga tuangan sisanya dihentak pada suhu 95°C yang mendidih untuk melarutkan gula berat menjadi karamel cair pekat."
    },
    "Elika Liftee": {
        "grindSize": "Berlapis (Stacked Dosing)",
        "desc": "Elika Liftee mengatasi kelemahan pencampuran biji kopi (blending) dua spesies yang memiliki kepadatan sel berbeda (Sudan Rume dan Eugenioides) dengan merakit seduhan secara berlapis (stacked). Ia meletakkan bubuk Eugenioides di dasar V60, lalu menumpuk Sudan Rume di atasnya tanpa mengaduknya! Dinamika cairan secara otomatis mengekstraksi bagian atas pada porsi tinggi dan bagian bawah pada persentase lebih rendah. Ia juga memanfaatkan alat Melodrip untuk mencegah agitasi kinetik, memastikan air turun seperti tetesan hujan lembut."
    },
    "Carlos Medina": {
        "grindSize": "Menengah Halus (Medium Fine)",
        "desc": "Medina membawa filosofi repetisi. Ia menerapkan simetri geometri yang dingin menggunakan Origami Dripper Air S. Resepnya adalah garis lurus matematis: tuangan dibagi persis sama rata menjadi lima kali masing-masing 50 gram. Setiap tuangan diberikan jeda istirahat eksak selama 30 detik. Dengan air mineral berskala 65 ppm rasio setara Magnesium dan Kalsium, tidak ada ruang bagi variabel tak terkendali, menghasilkan minuman yang dipenuhi asam tartarat dan sisa rasa persik bening."
    },
    "Martin Wölfl": {
        "grindSize": "490 Mikron (Sangat Seragam)",
        "desc": "Metode Wölfl adalah purwarupa penuangan ultra-modern di mana agitasi fisik secara konseptual 'dibunuh'. Ia menggunakan Orea V4 dengan kertas saring lab Sibarist, dan mendistribusikan kopi (490 mikron seragam) dengan jarum WDT. Aliran cerek dipecah oleh penyebar air Theo Shower Screen. Bubuk kopinya dapat menelan air ekstraksi secepat 2 menit 20 detik tanpa ada celah pelarutan asimetris, mengekstraksi tingkat gula paling murni dan menolak senyawa beraroma kayu."
    },
    "Wataru Iidaka": {
        "grindSize": "Berlapis 3 (Sandwich Dose)",
        "desc": "Wataru mengeksekusi mekanika termodinamika kompleks menggunakan dosing tiga lapis (sandwich dose). Ekstraksinya didistribusikan melalui bantalan Melodrip terbalik, lalu mengalir melintasi bola es logam Paragon bertemperatur minus 5°C. Kondensasi kriogenik cepat (rapid chilling) ini menangkap profil Volatile Organic Compounds (VOC) yang umumnya menguap saat terseduh panas, menyegel aroma kembang sepatu langsung ke dalam minumannya."
    },
    "Ryan Wibawa": {
        "grindSize": "Kasar (Coarse)",
        "desc": "Ryan Wibawa mengunci posisi ketiga lewat pendekatan Bhinneka Tunggal Ika dengan Hario Switch. Ia memasukkan kopi Excelsa dari Sumedang sebagai pengikat tebal (body matrix) untuk spesies Ombligon dan Gesha. Wibawa meniadakan turbulensi dengan penuangan melalui Drip Assist. Pada tuas katup tertutup, ia memberikan imersi suhu 86°C selama 40 detik. Cairan kedua menyusul di 92°C direndam sebelum dilepas bebas. Ini meredam agresi keasaman menjadi harmoni rasa sempurna."
    },
    "Peng Jinyang": {
        "grindSize": "Menengah (Medium)",
        "desc": "Peng Jinyang merombak tradisi dengan menyangrai satu kopi dalam tiga delta suhu berbeda sebelum mencampurnya kembali. Ia menggunakan Solo Dripper dan membawa thermal probe ke meja juri untuk merekam penurunan suhu aktual. Tuangan awal di suhu 96°C mengekstraksi lapisan dasar, lalu tuangan terakhir dihancurkan suhunya menjadi 80°C yang dihantarkan lewat Melodrip untuk mencegah ekstraksi zat astringency (penyebab kering di mulut)."
    },
    "Bayu Prawiro": {
        "grindSize": "Menengah (Medium)",
        "desc": "Bayu menggunakan kerangka narasi 'Segitiga Eksposur' kamera mekanis. Agitasi sebagai aperture (lensa), aliran (flow rate) sebagai shutter speed, dan durasi sebagai ISO. Perpaduan biji kopi Excelsa dan Gesha dikelola menggunakan Drip Assist di atas Hario Switch, mengunci rasa asam kompleks ke dalam wadah cairan yang lambat memudar di ujung lidah."
    },
    "Nas Jaafar": {
        "grindSize": "Menengah Kasar (Medium Coarse)",
        "desc": "Nas Jaafar menciptakan alat hibrida dengan menempelkan corong UFO V3 berdinding datar 80 derajat di atas dasar karet Hario Switch berkatup. Temanya adalah 'Perlawanan' (Resistance). UFO V3 menyebarkan bubuk sedemikian lebarnya hingga perlawanan aliran cairan hampir nol (zero bypass). Setelah perkolasi pertama menembus, Nas menutup tuas, memaksa 100 gram air kedua mengalami imersi statis untuk membentuk rantai tekstur body struktur yang tebal."
    }
}

lines = content.split('\n')
new_lines = []
current_author = ""
current_desc = ""

i = 0
while i < len(lines):
    line = lines[i]
    
    if '"author":' in line:
        current_author = re.search(r'"author":\s*"(.*?)"', line).group(1)
        # clean current author
        current_author = re.sub(r'\s*\(.*?\)', '', current_author).strip()
        
    if '"grindSize":' in line:
        if current_author in specific_data:
            new_grind = specific_data[current_author]["grindSize"]
            line = re.sub(r'"grindSize":\s*".*?"', f'"grindSize": "{new_grind}"', line)
            
    if '"description":' in line:
        if current_author in specific_data:
            new_desc = specific_data[current_author]["desc"]
            line = re.sub(r'"description":\s*".*?"', f'"description": "{new_desc}"', line)
            
    new_lines.append(line)
    i += 1

with open(file_path, 'w', encoding='utf-8') as f:
    f.write('\n'.join(new_lines))
