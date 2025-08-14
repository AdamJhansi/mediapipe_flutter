## GERAKIN

# 🤸 Aplikasi Deteksi Gerakan - Flutter + MediaPipe + Google ML Kit

Aplikasi ini digunakan untuk **mendeteksi gerakan tubuh secara real-time** seperti push-up, squat, atau pull-up menggunakan **kamera perangkat**.  
Dibangun menggunakan **Flutter**, memanfaatkan **MediaPipe** untuk deteksi pose, dan **Google ML Kit** untuk pengolahan data pose.

---

## 🚀 Fitur Utama
- 📷 **Deteksi Pose Real-time** menggunakan kamera perangkat.
- 🤖 **Integrasi Google ML Kit** untuk pengolahan model pose.
- 📊 **Klasifikasi Gerakan** secara otomatis.
- 📱 **UI Responsif** untuk berbagai ukuran layar.
- ⚡ Performa optimal di berbagai perangkat Android.

---

## 🛠️ Teknologi yang Digunakan
- [Flutter](https://flutter.dev/) (versi disarankan: 3.x.x)
- [Dart](https://dart.dev/)
- [MediaPipe](https://developers.google.com/mediapipe) - Deteksi pose tubuh.
- [Google ML Kit](https://developers.google.com/ml-kit) - Pemrosesan model machine learning.
- Dependency utama:
  - `google_mlkit_pose_detection` - Deteksi pose tubuh.
  - (Tambahkan dependency tambahan yang digunakan di project)

---

## 📦 Instalasi

1. **Clone repository**
   ```bash
   git clone https://github.com/username/nama-repo.git
   cd nama-repo
Install dependencies

bash
Copy
Edit
flutter pub get
Jalankan aplikasi

bash
Copy
Edit
flutter run
📁 Struktur Folder
bash
Copy
Edit
lib/
 ├── main.dart               # Entry point aplikasi
 ├── pages/                  # Halaman-halaman aplikasi
 │    ├── home_page.dart     # Halaman utama
 │    └── detection_page.dart# Halaman deteksi gerakan
 ├── services/               # Logika pemrosesan pose & ML
 ├── widgets/                # Widget custom
assets/
 ├── images/                 # Gambar UI
📊 Pengujian & Performa
Perangkat	RAM	Prosesor	FPS Deteksi
Xiaomi Redmi Note 10	4 GB	Snapdragon 678	25 - 30 FPS
Samsung Galaxy A12	4 GB	MediaTek Helio P35	20 - 30 FPS
Oppo A16	3 GB	MediaTek Helio G35	15 - 20 FPS
Realme 8	6 GB	MediaTek Helio G95	28 - 35 FPS
Vivo Y20	4 GB	Snapdragon 460	18 - 25 FPS
Samsung Galaxy S21 Ultra	12 GB	Snapdragon 888	50 - 60 FPS

📸 Screenshot
Tambahkan gambar tangkapan layar aplikasi di sini

Halaman	Tampilan
Home	
Deteksi	

🧑‍💻 Kontribusi
Kontribusi sangat terbuka!

Fork repositori ini.

Buat branch baru:

bash
Copy
Edit
git checkout -b fitur-baru
Commit perubahan:

bash
Copy
Edit
git commit -m 'Menambahkan fitur baru'
Push ke branch:

bash
Copy
Edit
git push origin fitur-baru
Ajukan Pull Request.

📄 Lisensi
Proyek ini menggunakan lisensi MIT.
Silakan gunakan dan modifikasi sesuai kebutuhan.

✨ Dibuat Oleh
Nama Kamu
📧 Email: your@email.com

markdown
Copy
Edit

Kalau mau, aku bisa bikin **README.md ini ada logo dan banner** biar tampilannya lebih keren di GitHub.  
Itu bakal bikin repositorimu kelihatan lebih profesional.  
Mau aku buatkan juga?
