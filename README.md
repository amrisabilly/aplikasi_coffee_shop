# Kopi Kelana - Aplikasi E-Commerce (Flutter & Laravel)

![Kopi Kelana Banner](GANTI_DENGAN_LINK_BANNER_ANDA_JIKA_ADA)

**Kopi Kelana** adalah prototipe aplikasi *e-commerce* *full-stack* yang dibangun sebagai bagian dari [Sebutkan Tujuan Anda, misal: Laporan Rekayasa Perangkat Lunak]. Aplikasi ini menggabungkan fungsionalitas toko online (katalog, *checkout*) dengan serangkaian fitur interaktif unik yang berfokus pada pengalaman pengguna, seperti penjadwalan, konversi mata uang, dan sistem poin berbasis sensor.

---

## 📸 Tampilan Aplikasi (WIP)

| Halaman Utama | Detail Produk | Fitur "Janjian Kopi" |
| :---: | :---: | :---: |
| _[Ganti dengan Screenshot]_ | _[Ganti dengan Screenshot]_ | _[Ganti dengan Screenshot]_ |
| **Asisten Belanja** | **Sistem Poin (Sensor)** | **Checkout (Manual)** |
| _[Ganti dengan Screenshot]_ | _[Ganti dengan Screenshot]_ | _[Ganti dengan Screenshot]_ |

---

## ✨ Fitur Utama

Aplikasi ini dibagi menjadi dua bagian: Aplikasi Klien (Flutter) dan Backend (Laravel API).

### Fitur Klien (Flutter)
* **Autentikasi Pengguna:** Registrasi dan Login (Email/Password) berbasis Token JWT.
* **Katalog Produk:** Menampilkan daftar produk dan kategori yang diambil dari API.
* **Detail Produk:** Menampilkan rincian, deskripsi, dan harga produk.
* **Keranjang Belanja:** Logika penambahan dan pengelolaan item keranjang (dikelola di sisi klien/Provider).
* **Checkout Manual:** Alur pemesanan dengan metode pembayaran statis (COD, Transfer Bank).
* **Asisten Belanja Global:** Fitur konversi mata uang statis (*hardcoded*) untuk membantu pengguna asing memperkirakan harga dalam mata uang mereka (misal: USD ke IDR).
* **Janjian Kopi Lintas Waktu:** Fitur "Bland Jadwal" yang menggunakan **Geolocator** untuk mendeteksi zona waktu (WIB/WITA/WIT) dan merekomendasikan waktu janji temu.
* **Sistem Poin (Sensor Gerak):** Pengguna bisa "menggoyangkan" (shake) perangkat untuk mendapatkan poin. Fitur ini menggunakan *package* **`sensors_plus`** (Accelerometer).
* **Redeem Voucher:** Pengguna dapat menukar poin (misal: 50 poin) dengan voucher diskon yang bisa digunakan saat *checkout*.
* **Upload Foto Profil:** Menggunakan **`image_picker`** untuk mengunggah gambar dari galeri/kamera ke *backend*.
* **Notifikasi Lokal:** Menggunakan **`awesome_notifications`** untuk membuat pengingat lokal (misal: untuk "Janjian Kopi").
* **Riwayat Pesanan:** Menampilkan daftar transaksi yang pernah dilakukan pengguna (Status: *Known Bug*).

### Fitur Backend (Laravel API)
* **API Autentikasi:** *Endpoint* untuk `register`, `login`, dan `logout` menggunakan **Tymon JWT-Auth**.
* **Validasi Server-Side:** Validasi semua *request* yang masuk (Registrasi, Checkout, dll).
* **Manajemen Produk & Kategori:** *Endpoint* CRUD (Create, Read, Update, Delete) untuk produk dan kategori.
* **Manajemen Pesanan:** *Endpoint* `checkout` yang menerima keranjang, menerapkan diskon, dan menyimpan ke tabel `orders` & `order_items` dengan status "pending".
* **Manajemen Poin:** *Endpoint* terproteksi (`/api/auth/profile/add-point`) untuk memvalidasi dan menambah poin pengguna di *database* (mencegah *cheating* dari sisi klien).
* **Manajemen Profil:** *Endpoint* untuk *upload* foto profil dan mengambil data pengguna.

---

## 🛠️ Tumpukan Teknologi (Tech Stack)

| Kategori | Teknologi | Keterangan |
| :--- | :--- | :--- |
| **Frontend (Klien)** | **Flutter (Dart)** | Framework utama aplikasi *mobile cross-platform*. |
| | **Provider** | *State Management* untuk mengelola data (status login, keranjang). |
| | **http** | *Package* untuk melakukan panggilan ke REST API Laravel. |
| | **geolocator** | Mendeteksi lokasi GPS untuk zona waktu. |
| | **sensors_plus** | Mengakses sensor Accelerometer untuk fitur "Shake to Add Point". |
| | **image_picker** | Mengambil gambar dari galeri/kamera. |
| | **awesome_notifications** | Menampilkan notifikasi lokal. |
| **Backend (Server)** | **Laravel (PHP)** | Framework *backend* untuk membangun REST API. |
| | **Tymon JWT-Auth**| *Package* untuk menangani autentikasi berbasis Token JWT. |
| | **MySQL** | Sistem *database* relasional. |
| **Tools** | **Postman** | Pengujian *endpoint* API secara terisolasi. |
| | **VS Code** | Editor kode utama. |
| | **Android Studio** | Menjalankan emulator dan *build tools*. |

---

## 🚀 Arsitektur

Aplikasi ini menggunakan arsitektur **Client-Server**.

* **Client (Flutter):** Bertanggung jawab atas seluruh Tampilan (UI) dan Pengalaman Pengguna (UX). Aplikasi ini bersifat *stateless* dalam hal data bisnis, yang sepenuhnya bergantung pada API.
* **Server (Laravel API):** Bertindak sebagai *backend* yang menangani semua logika bisnis, validasi, dan interaksi dengan *database*. Ini memastikan bahwa data tetap konsisten dan aman.

---

## ⚙️ Instalasi dan Menjalankan Proyek

Proyek ini terdiri dari dua repositori (atau dua folder dalam satu mono-repo): `backend-laravel` dan `frontend-flutter`.

### 1. Backend (Laravel API)

1.  **Clone repositori backend:**
    ```bash
    git clone [LINK_REPOSITORI_BACKEND_ANDA]
    cd backend-kopi-kelana
    ```
2.  **Install dependencies:**
    ```bash
    composer install
    ```
3.  **Buat file `.env`:**
    ```bash
    cp .env.example .env
    ```
4.  **Generate key aplikasi:**
    ```bash
    php artisan key:generate
    ```
5.  **Konfigurasi Database:**
    Buka file `.env` dan atur koneksi *database* MySQL Anda (`DB_DATABASE`, `DB_USERNAME`, `DB_PASSWORD`).
6.  **Jalankan Migrasi Database:**
    ```bash
    php artisan migrate
    ```
    *(Opsional: Jika Anda punya Seeder untuk data dummy)*
    `php artisan db:seed`
7.  **Setup JWT:**
    ```bash
    php artisan jwt:secret
    ```
8.  **Jalankan server:**
    ```bash
    php artisan serve
    ```
    *Server akan berjalan di `http://127.0.0.1:8000`*

### 2. Frontend (Aplikasi Flutter)

1.  **Clone repositori frontend:**
    ```bash
    git clone [LINK_REPOSITORI_FRONTEND_ANDA]
    cd frontend-kopi-kelana
    ```
2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```
3.  **Ubah URL API:**
    Buka file konfigurasi API Anda (misal: `lib/services/api_service.dart` atau `lib/utils/constants.dart`).
    
    Cari `baseUrl` dan ubah agar sesuai dengan alamat server Laravel Anda.
    * **PENTING:** Jika menggunakan **Emulator Android**, gunakan `http://10.0.2.2:8000/api` (bukan `localhost`).
    * Jika menggunakan perangkat fisik, gunakan alamat IP lokal Anda (misal: `http://192.168.1.5:8000/api`).

4.  **Jalankan Aplikasi:**
    ```bash
    flutter run
    ```

---

## 🗺️ Dokumentasi API (Ringkasan)

API Kopi Kelana menyediakan beberapa *endpoint* utama:

| Method | Endpoint | Deskripsi | Auth? |
| :--- | :--- | :--- | :--- |
| POST | `/auth/register` | Registrasi pengguna baru. | ✕ |
| POST | `/auth/login` | Login pengguna (Email/Password). | ✕ |
| POST | `/auth/logout` | Logout pengguna. | ✓ |
| GET | `/categories` | Mendapat semua kategori. | ✕ |
| GET | `/products` | Mendapat semua produk (bisa filter). | ✕ |
| GET | `/products/{id}` | Mendapat detail satu produk. | ✕ |
| POST | `/checkout` | Memproses *checkout* keranjang. | ✓ |
| GET | `/orders` | Mendapat riwayat pesanan pengguna. | ✓ |
| POST | `/auth/profile/add-point` | Menambah poin (via sensor). | ✓ |
| PUT | `/auth/profile/upload-photo` | Unggah foto profil. | ✓ |

---

## 📊 Status Proyek

**Status:** 🚀 **Selesai (Prototipe untuk Laporan)**

Aplikasi ini telah menyelesaikan semua fungsionalitas utama yang direncanakan untuk laporan.

**Known Bugs / Catatan:**
* **Riwayat Pesanan (TC-13):** Fitur "Riwayat Pesanan" saat ini mengalami *bug* dan **GAGAL** memuat data (menampilkan *loading* tanpa henti). Ini memerlukan investigasi lebih lanjut di sisi API atau *state management* Flutter.
