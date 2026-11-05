# ☕ Coffee Labs Mobile (`coffee_hub_mobile`)

<div align="center">

![Coffee Labs Banner](https://raw.githubusercontent.com/rusdifn08/coffe-labs-mobile/main/assets/images/logo.png)

**The Ultimate Precision Specialty Coffee Platform & Cognitive Brewing Companion**  
*Seduh Kopi Presisi, Standar Barista Juara Dunia.*

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.11+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![State Management](https://img.shields.io/badge/State-Riverpod%203.x-29B6F6)](https://riverpod.dev)
[![OTA](https://img.shields.io/badge/OTA-Shorebird%202.x-FF6F00)](https://shorebird.dev)
[![ML Kit](https://img.shields.io/badge/AI%2FOCR-Google%20ML%20Kit-4285F4?logo=google&logoColor=white)](https://developers.google.com/ml-kit)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-3DDC84?logo=android&logoColor=white)](https://github.com/rusdifn08/coffe-labs-mobile)
[![License](https://img.shields.io/badge/License-Proprietary-red)](#license)
[![Tests](https://img.shields.io/badge/Tests-86%20Passed-brightgreen)](#testing--verification)

[Fitur Unggulan](#-fitur-unggulan--sistem) •
[Arsitektur](#-arsitektur--desain-sistem) •
[Tech Stack & Dependencies](#-tech-stack--dependencies) •
[Instalasi & Setup](#-panduan-instalasi--setup) •
[Hardware Integration](#-integrasi-hardware--iot) •
[Testing](#-testing--quality-assurance)

---

### 📲 Download Aplikasi Resmi
| Platform | Link Unduhan Langsung |
| :--- | :--- |
| **Android (arm64-v8a APK)** | [Unduh CoffeeLabs-arm64-v8a.apk](https://github.com/rusdifn08/coffe-labs-mobile/releases/download/v1.0.0-20261105-0251/CoffeeLabs-arm64-v8a.apk) |
| **iOS (Release IPA)** | [Unduh CoffeeLabs-iOS-Release.ipa](https://github.com/rusdifn08/coffe-labs-mobile/releases/download/v1.0.0-20261105-0251/CoffeeLabs-iOS-Release.ipa) |

</div>

---

## 📖 Ringkasan Proyek (Overview)

**Coffee Labs Mobile** adalah ekosistem aplikasi *mobile specialty coffee* terlengkap yang dirancang untuk barista profesional, pemilik kedai kopi (slow bar & specialty roastery), dan antusias seduh rumahan (*home brewer*). 

Aplikasi ini menggabungkan sains ekstraksi kopi presisi (*SCA Golden Cup Standard*), kecerdasan buatan visi komputer (*Cognitive Sommelier AI & OCR*), kontrol hardware *Internet of Things* (IoT Bluetooth Scale & Thermal ESC/POS Printer), serta platform sosial komunitas dan sistem POS bisnis roastery dalam satu pengalaman mobile yang elegan dan modern.

---

## 🚀 Fitur Unggulan & Sistem

### 1. 🧠 Smart Coffee Bag Scanner (Cognitive Sommelier AI & ML Kit Vision OCR)
* **On-Device Vision OCR & Object Detection**: Memanfaatkan `google_mlkit_text_recognition` dan `google_mlkit_object_detection` untuk membaca kemasan kopi secara *real-time*.
* **Cognitive Knowledge Graph**:
  * **Roastery Detection**: Mengetahui nama-nama roastery terkemuka (Otten Coffee, BAK Coffee Bean, Space Roastery, Dua Kopi, Fugol, Tanamera, dll.).
  * **Origin & Terroir Mapping**: Pengenalan otomatis ribuan daerah penghasil kopi dunia dan nusantara (Malabar, Gunung Halu, Wamena Bpiri, Gayo, Ijen, Sidikalang, Yirgacheffe, Huila, Gesha Village).
  * **Post-Harvest Processing Extraction**: Mengidentifikasi proses pasca-panen (*Washed, Natural, Wine / Anaerobic Natural, Honey, Carbonic Maceration, Thermal Shock*).
  * **Variety & Elevation Detection**: Menemukan varietas kopi (*Typica, Bourbon, Geisha, SL28, Kartika, Sigarar Utang*) dan ketinggian tanam (*masl*).
  * **Jaro-Winkler Fuzzy Tasting Notes Matching**: Mendeteksi tasting notes dari SCA Flavor Wheel dengan toleransi kesalahan ketik/baca (*threshold* $\ge 0.83$).
  * **Dynamic Cross-Inference**: Jika mendeteksi proses *Wine*, secara cerdas menginferensikan profil rasa khas seperti *Winey, Fermented Grapes, Dark Cherry, Rum*.
* **Interactive Bounding Box Overlays**: Menampilkan kotak batas deteksi berwarna interaktif di layar kamera:
  * 🟡 **Kuning Emas (`#D4AF37`)**: Nama Roastery / Brand
  * 🟢 **Hijau Forest (`#4E8752`)**: Origin / Terroir
  * 🔴 **Merah Marun (`#9E2A3B`)**: Proses Pasca-Panen
  * 🔵 **Biru Navy (`#3B82A6`)**: Tasting Notes
* **Interactive Plotting Card**: Barista dapat meninjau, mengedit nama, proses, ketinggian, dan menambah/menghapus tag rasa (*+ Tambah Note*) sebelum disimpan ke rak kopi (*Bean Cellar*).

---

### 2. ⏱️ Precision Guided Brew Timer & Stage Controller
* **Millisecond Precision Countdown**: Pelacakan waktu seduh dengan presisi milidetik.
* **Multi-Stage Pour Guide**: Panduan visual untuk setiap interval tuangan (*Blooming, First Pour, Second Pour, Final Drawdown*).
* **Barista Voice Assistant (TTS)**: Suara pemandu interaktif (`flutter_tts`) yang mengumumkan setiap langkah penuangan tanpa perlu memandang layar terus-menerus.
* **Audio Ducking System**: Musik latar otomatis mengecil saat audio asisten barista berbicara (`just_audio`).
* **Wakelock & Screen Management**: Layar tetap menyala aktif selama sesi seduh berlangsung (`wakelock_plus` & `screen_brightness`).

---

### 3. 🏆 200+ Resep Barista Juara Dunia & Recipe Builder
* **Koleksi Resep Juara Dunia**:
  * **Tetsu Kasuya** (World Brewers Cup 2016) — *Metode 4:6*.
  * **James Hoffmann** — *The Ultimate V60 Single-Pour Technique*.
  * **Mikael Jasin** (World Barista Champion 2024) — *Specialty Aeropress & Thermal Shock Extraction*.
  * **Chad Wang, Lance Hedrick, Matt Winton, Sherry Hsu**, dan banyak lagi.
* **Dukungan Multi-Alat Seduh**: V60, Origami Dripper, Kalita Wave, AeroPress, Chemex, Clever Dripper, Hario Switch, French Press, Syphon, Cold Drip, Espresso.
* **Custom Recipe Editor**: Bangun resep racikan sendiri dengan kalkulasi rasio dinamis (1:12 hingga 1:18) dan tahapan gramasi tuangan otomatis.

---

### 4. 🩺 Brew Doctor (Diagnosis Sensori & Dial-In Engine)
* **Sensory Trouble Diagnosis**: Diagnosis rasa seduhan ketika kopi terasa terlalu pahit (*astringent / over-extracted*), terlalu asam tajam (*sour / under-extracted*), atau hambar (*weak / channeling*).
* **Prescriptive Corrections**: Memberikan instruksi presisi perbaikan klik grinder, rasio seduh, agitasi, dan suhu air untuk seduhan berikutnya.
* **Dial-In History**: Riwayat catatan kalibrasi rasa untuk setiap kantong kopi.

---

### 5. 🔬 Barista Extraction & Chemistry Toolkit
* **SCA Extraction Yield & TDS Calculator**: Menghitung persentase ekstraksi ideal (18% - 22%) berdasarkan gramasi kopi, berat air, dan pembacaan refraktometer TDS (Total Dissolved Solids).
* **Water Chemistry & Buffer Balance**: Kalkulator profil air seduh, rasio Kesadahan Umum (GH) & Kesadahan Karbonat (KH) standar SCA (*Calcium, Magnesium, Bicarbonate*).
* **Bean Freshness & Degassing Tracker**: Memantau waktu optimal *resting* biji kopi dari tanggal sangrai (*Roasting Date*) hingga masa puncak rasa (*Flavor Peak*).
* **Universal Grinder Converter**: Database konversi klik untuk 50+ grinder komersial dan manual:
  * *Comandante C40 MK3/MK4 (Red Clix support)*
  * *Timemore C2, C3, Chestnut X*
  * *1Zpresso J-Max, K-Ultra, Q2*
  * *Mahlkönig EK43, EK43S*
  * *Fellow Ode Gen 1 & Gen 2, Opus*
  * *Baratza Encore, Sette 270, DF64, Niche Zero*
* **Interactive SCA 92-Flavor Wheel**: Roda rasa interaktif standar Specialty Coffee Association untuk mengevaluasi *Acidity, Body, Sweetness, Clean Cup, Aftertaste*.

---

### 6. 📱 Specialty Coffee POS & Bluetooth Thermal Printer
* **Slow Bar Point-of-Sale (POS)**: Manajemen menu kopi harian, pesanan pelanggan, nomor meja, opsi grind size, dan metode seduh.
* **Hardware ESC/POS Printing (`flutter_blue_plus`)**: Cetak struk pesanan secara nirkabel melalui Bluetooth ke printer termal standar (58mm dan 80mm).
* **Struk Ekstraksi Slow Bar**: Mencetak detail teknis ekstraksi (Nama Roastery, Varietas, TDS, Rasio, Suhu Air, Nama Barista) langsung ke kertas struk untuk pengalaman pelanggan premium.

---

### 7. ⚖️ Bluetooth LE Smart Scale Integration
* **Real-time Telemetry**: Koneksi langsung via Bluetooth Low Energy (BLE) ke timbangan kopi pintar (*Smart Scale*).
* **Flow Rate & Weight Graph**: Grafik laju aliran air (*flow rate* gram/detik) dan berat bersih secara *real-time* saat penuangan berlangsung.

---

### 8. 🌐 Komunitas Seduh: Social Coffee & Basecamp
* **Community Recipe Feed**: Telusuri dan bagikan resep seduh favorit dari barista di seluruh dunia.
* **1-Tap Recipe Duplicator ("Copy Resep")**: Duplikasi resep komunitas langsung ke brew timer pribadi dengan satu ketukan.
* **Basecamp Groups**: Grup komunitas eksklusif roastery, kedai lokal, dan forum kalibrasi seduh.

---

### 9. 🎮 Gamification, XP & Masterclass
* **Barista XP & Leveling**: Dapatkan XP setiap kali menyeduh dan mengevaluasi kopi. Raih rank dari *Novice Brewer* hingga *Grandmaster Brewer*.
* **Brew Streak & Achievements**: Lacak konsistensi seduh harian dan raih lencana pencapaian eksklusif dengan selebrasi konfeti interaktif (`confetti`).
* **Interactive Masterclass**: Modul edukasi teknik penuangan, dasar sains ekstraksi, dan kalibrasi grinder.

---

### 10. ⚡ Shorebird OTA Code Push Engine
* **Instant Over-The-Air Updates**: Pembaruan perbaikan *bug*, penambahan resep, dan penyempurnaan model kecerdasan buatan secara instan tanpa perlu menunggu waktu persetujuan App Store / Google Play Store melalui `shorebird_code_push`.

---

## 🏛️ Arsitektur & Desain Sistem

Aplikasi ini dibangun menggunakan arsitektur **Clean Architecture + Feature-First (Domain-Driven Structure)** dengan manajemen state reaktif modern bertenaga **Riverpod 3**.

```
lib/
├── core/                       # Infrastruktur global & konfigurasi inti
│   ├── constants/              # Variabel konstanta aplikasi (warna, API, URL)
│   ├── network/                # Klien HTTP (Dio & Http) dan interceptors
│   ├── theme/                  # Desain visual, tipografi, palet barista
│   └── utils/                  # Helper fungsi waktu, matematika ekstraksi, string
│
├── features/                   # Arsitektur Berbasis Fitur (Feature-First)
│   ├── bean_scanner/           # OCR & Vision Cognitive Sommelier AI
│   │   ├── data/               # Model ML Kit, dataset roastery & kamus rasa
│   │   ├── domain/             # CognitiveBeanAnalyzer, model deteksi & entitas
│   │   └── presentation/       # ScannerScreen, BoundingBoxOverlay, EditSheet
│   ├── brew/                   # Timer seduh presisi & panduan langkah tuang
│   ├── four_six/               # Algoritma rasio Tetsu Kasuya 4:6
│   ├── bean_dial_in/           # Diagnosis sensori rasa & perbaikan grinder
│   ├── smart_scale/            # Integrasi BLE Smart Scale
│   ├── business_pos/           # POS Kedai & Pencetakan Struk Bluetooth ESC/POS
│   ├── flavor_wheel/           # Roda rasa interaktif SCA 92-flavor
│   ├── tds/                    # Kalkulator ekstraksi & refraktometer
│   ├── water/                  # Kalkulator kimia air seduh (GH & KH)
│   ├── grinder/                # Database konversi klik 50+ grinder
│   ├── bean_freshness/         # Pelacak resting & degassing biji kopi
│   ├── recipes/                # Katalog resep juara dunia & recipe editor
│   ├── social/                 # Feed resep, komunitas, & grup basecamp
│   ├── marketplace/            # Toko biji kopi & peralatan seduh
│   ├── gamification/           # Leveling XP, streak harian, & badges
│   └── masterclass/            # Video tutorial & modul edukasi
│
├── models/                     # Shared immutable data models (Freezed / JSON)
├── providers/                  # StateNotifier & Riverpod Providers
├── services/                   # Layanan perangkat keras (Audio, BLE, TTS, Camera)
├── theme/                      # Definisi tema gelap/terang khas Specialty Coffee
└── widgets/                    # Komponen UI modular & reusable
```

---

## 🛠️ Tech Stack & Dependencies

### Core Framework & Language
* **Dart**: `^3.11.5` (Null Safety, Pattern Matching, Records)
* **Flutter SDK**: `3.x+` (Material 3 & iOS Cupertino support)

### State Management & Architecture
| Package | Versi | Deskripsi & Kegunaan |
| :--- | :--- | :--- |
| `flutter_riverpod` | `^3.4.3` | Reactive caching dan state management |
| `riverpod_annotation`| `^4.0.7` | Kode anotasi untuk generator Riverpod |
| `go_router` | `^18.1.2` | Navigasi declarative berbasis URL dengan deep linking |
| `freezed_annotation` | `^3.1.0` | Pembuatan data model immutable dengan copyWith & equality |
| `json_annotation` | `^4.12.0` | Serialisasi JSON otomatis berkinerja tinggi |

### Computer Vision & Artificial Intelligence
| Package | Versi | Deskripsi & Kegunaan |
| :--- | :--- | :--- |
| `google_mlkit_text_recognition` | `^0.17.1` | Pengenalan karakter teks OCR pada kemasan kopi secara on-device |
| `google_mlkit_object_detection` | `^0.17.1` | Deteksi objek kemasan kopi dan tata letak spasial bounding box |
| `camera` | `^0.12.2` | Kontrol kamera langsung dengan fokus presisi dan resolusi tinggi |
| `image` | `^4.12.0` | Pemrosesan citra digital, manipulasi raster, dan cropping gambar |
| `image_picker` | `^1.2.3` | Pemilih gambar dari galeri foto atau file storage |

### Hardware, IoT & Device Services
| Package | Versi | Deskripsi & Kegunaan |
| :--- | :--- | :--- |
| `flutter_blue_plus` | `^2.3.14` | Konektivitas Bluetooth Low Energy (BLE) untuk Smart Scale & Printer |
| `flutter_tts` | `^4.2.5` | Text-to-Speech pemandu suara barista saat sesi seduhan berjalan |
| `wakelock_plus` | `^1.8.0` | Mencegah layar smartphone mati saat timer sedang menyeduh |
| `screen_brightness` | `^2.1.11` | Pengatur kecerahan layar dinamis saat timer aktif |
| `haptic_feedback` | `^0.5.1+1`| Respon getaran haptic presisi pada transisi tuangan dan timer |

### Audio & Multimedia
| Package | Versi | Deskripsi & Kegunaan |
| :--- | :--- | :--- |
| `just_audio` | `^0.9.46` | Pemutar audio canggih dengan audio ducking dan background playback |
| `audioplayers` | `^6.7.1` | Pemutar efek suara klik dan timer |
| `flutter_ringtone_player` | `^4.0.0+4` | Notifikasi dering alarm akhir ekstraksi seduhan |

### UI & Animasi Interaktif
| Package | Versi | Deskripsi & Kegunaan |
| :--- | :--- | :--- |
| `google_fonts` | `^6.2.1` | Tipografi elegan (Plus Jakarta Sans, Playfair Display) |
| `flutter_animate` | `^4.5.2` | Animasi deklaratif mikro yang halus pada widget dan transisi |
| `rive` | `0.14.11` | Animasi vektor interaktif untuk indikator aliran seduhan |
| `confetti` | `^0.8.0` | Efek selebrasi konfeti saat mencapai milestone seduhan baru |
| `flutter_svg` | `^2.3.2` | Rendering aset grafis SVG beresolusi tinggi tanpa penurunan kualitas |
| `cached_network_image` | `^4.0.3` | Caching gambar kemasan kopi dan avatar komunitas di memori & disk |
| `flag` | `^7.0.2` | Ikon bendera negara asal biji kopi (*Origin Terroirs*) |

### Jaringan, Penyimpanan & OTA Engine
| Package | Versi | Deskripsi & Kegunaan |
| :--- | :--- | :--- |
| `dio` | `^5.11.1` | Klien HTTP berkemampuan interceptor, retry, dan upload multipart |
| `http` | `^1.6.0` | Klien HTTP ringan untuk panggilan endpoint mikro |
| `shared_preferences` | `^2.5.5` | Penyimpanan lokal persisten untuk preferensi dan cache offline |
| `path_provider` | `^2.1.6` | Akses direktori file sistem internal perangkat |
| `shorebird_code_push`| `^2.0.7` | Distribusi pembaruan aplikasi OTA (*Over-The-Air*) tanpa rilis ulang toko |
| `package_info_plus` | `^10.2.2` | Pengecekan versi rilis dan build aplikasi |
| `url_launcher` | `^6.3.3` | Membuka tautan eksternal ke website roastery dan media sosial |
| `intl` | `^0.20.2` | Internasionalisasi, penanggalan, dan pemformatan mata uang |

### Development & Code Generation Tools
| Package | Versi | Deskripsi & Kegunaan |
| :--- | :--- | :--- |
| `build_runner` | `^2.15.1` | Task runner untuk kompilasi kode generasi Dart |
| `riverpod_generator` | `^4.0.9` | Generator kode otomatis untuk provider Riverpod |
| `freezed` | `^4.0.0-dev.3`| Generator kode data class, union types, dan pattern matching |
| `json_serializable` | `^6.15.2` | Generator kode parsing JSON ke object Dart |
| `flutter_lints` | `^6.0.0` | Aturan penulisan kode (*linting standards*) resmi Flutter |
| `flutter_launcher_icons` | `^0.14.4`| Generator otomatis ikon aplikasi untuk Android dan iOS |

---

## 🔌 Integrasi Hardware & IoT

### 1. Bluetooth Low Energy (BLE) Smart Coffee Scale
Aplikasi secara otomatis mendeteksi dan melakukan pairing dengan timbangan kopi pintar berprotokol BLE:
* Pembacaan berat otomatis (*Auto-Tare* saat server mendeteksi server/dripper diletakkan).
* Telemetri laju aliran air tuangan (*Pour Flow Rate* dalam gram per detik).
* Pelacakan rasio kopi terhadap air aktual secara *real-time*.

### 2. Printer Termal ESC/POS (58mm / 80mm)
Modul `business_pos` mendukung pencetakan langsung struk barista:
* Protokol standar ESC/POS melalui Bluetooth SPP / BLE.
* Format struk *Slow Bar Log*:
  ```text
  ================================
            COFFEE LABS           
       SLOW BAR EXTRACTION LOG    
  ================================
  Tanggal  : 23 Okt 2026 10:15
  Barista  : Rusdi Barista
  Metode   : Hario V60 02
  Beans    : Malabar Wine Process
  Roastery : BAK Coffee Beans
  Grind    : Comandante #24 Clicks
  Dose     : 15.0g  |  Water: 225.0g
  Rasio    : 1:15.0 |  Suhu : 93°C
  Time     : 02:45  |  TDS  : 1.38%
  Yield    : 20.70% (Gold Cup Standard)
  Notes    : Winey, Dark Cherry, Rum
  ================================
    Master Your Brew with CoffeeLabs
  ```

---

## 💻 Panduan Instalasi & Setup

### Prasyarat Sistem
* **Flutter SDK**: `3.24.x` atau lebih baru
* **Dart SDK**: `^3.11.5`
* **Android**: Android Studio dengan SDK API Level 26+ (Android 8.0 Oreo ke atas)
* **iOS**: macOS dengan Xcode 15+ dan CocoaPods terpasang
* **Git**: `git` versi terbaru

### 1. Klon Repositori
```bash
git clone https://github.com/rusdifn08/coffe-labs-mobile.git
cd coffe-labs-mobile
```

### 2. Unduh Dependensi
```bash
flutter pub get
```

### 3. Jalankan Code Generator (Build Runner)
Untuk menghasilkan model Freezed, Riverpod Providers, dan serialisasi JSON:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 4. Konfigurasi Ikon Aplikasi (Opsional jika memperbarui aset)
```bash
dart run flutter_launcher_icons
```

### 5. Jalankan Aplikasi
Jalankan di perangkat fisik atau emulator Android/iOS:
```bash
# Mode Debug
flutter run

# Mode Release (untuk pengujian performa maksimal dan camera OCR)
flutter run --release
```

---

## 🧪 Testing & Quality Assurance

Aplikasi dilengkapi rangkaian unit test dan widget test yang komprehensif untuk menjamin keandalan algoritma seduh, scanner kecerdasan buatan, dan logika bisnis.

```bash
flutter test
```

### Lingkup Pengujian:
* `bean_scanner_test.dart`: Validasi Jaro-Winkler fuzzy matching dan parsing AI Cognitive Sommelier.
* `bean_recommendation_test.dart`: Pengujian algoritma rekomendasi resep berdasarkan proses dan varietas.
* `recipe_filter_and_sort_test.dart`: Verifikasi filter resep juara dunia dan metode seduh.
* `gamification_test.dart`: Uji kenaikan level XP, streak harian, dan ledger pencapaian.
* `user_brew_usage_test.dart`: Validasi pelacakan konsumsi dan riwayat seduhan.
* `voice_tts_test.dart`: Verifikasi siklus pemandu suara barista dan audio ducking.
* `toolkit_icons_test.dart` & `toolkit_upgrades_test.dart`: Validasi kalkulator ekstraksi dan formula SCA.
* `business_menu_asset_image_test.dart`: Verifikasi integritas katalog aset POS kedai kopi.

---

## 📦 Panduan Build & Rilis

### 1. Build APK Android (Release)
```bash
flutter build apk --release --split-per-abi
```
File APK biner arm64 akan tersedia di:
`build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`

### 2. Build Android App Bundle (Google Play Store)
```bash
flutter build appbundle --release
```
File AAB akan tersedia di:
`build/app/outputs/bundle/release/app-release.aab`

### 3. Build iOS (Archive & IPA)
```bash
flutter build ipa --release
```

### 4. Rilis Pembaruan Instan OTA (Shorebird)
```bash
# Rilis Patch OTA tanpa rilis ulang ke toko aplikasi
shorebird patch android
shorebird patch ios
```

---

## 🎨 Panduan Kontribusi & Standar Kode

1. **Fork Repositori** dan buat *branch* fitur Anda (`git checkout -b feature/FiturKeren`).
2. **Ikuti Gaya Kode Resmi**:
   * Jalankan `flutter analyze` untuk memastikan tidak ada *warning* atau *lint error*.
   * Terapkan arsitektur *Feature-First* di dalam direktori `lib/features/`.
3. **Tambahkan Pengujian**: Tulis *unit test* di folder `test/` untuk setiap logika baru yang ditambahkan.
4. **Commit & Push**: Gunakan format pesan *Conventional Commits* (`feat:`, `fix:`, `refactor:`, `docs:`).
5. **Kirim Pull Request**.

---

## 📄 Lisensi & Hak Cipta

Hak Cipta © 2026 **Coffee Labs**. Seluruh hak cipta dilindungi undang-undang (*All Rights Reserved*).  
Dikembangkan dengan penuh dedikasi untuk memajukan industri kopi spesialti Indonesia dan dunia.

Dikelola dan dipelihara oleh: **[@rusdifn08](https://github.com/rusdifn08)**  
Email Kontak: `rusdifn08@gmail.com`
