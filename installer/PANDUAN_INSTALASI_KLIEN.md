# Panduan Instalasi & Review — FreightIntel AI (v1.0.1)

> ### ⚠️ Status paket v1.0.1
> | Paket | Status | Cara dibuat |
> |---|---|---|
> | `FreightIntel-AI-v1.0.1-release.apk` | **SIAP** | sudah dibangun & diverifikasi (`versionCode=2`) |
> | `FreightIntel-AI-v1.0.1-iOS.ipa` | **BELUM** | dibangun GitHub Actions saat push, lalu di-sign & dipasang ke iPhone pakai `xtool` |
>
> **Langkah `.ipa` (belum dikerjakan, jangan sampai terlewat):**
> 1. Push branch -> workflow `.github/workflows/build-ios.yml` jalan di macOS.
> 2. Unduh artefak `.ipa` dari GitHub Release.
> 3. Simpan ke `installer/FreightIntel-AI-v1.0.1-iOS.ipa`.
> 4. Pasang ke iPhone: `xtool install "installer/FreightIntel-AI-v1.0.1-iOS.ipa"`.
>
> Selama langkah ini belum dilakukan, `.ipa` yang ada di folder masih **v1.0.0**
> dan Dashboard-nya masih menampilkan angka contoh.

> **Perubahan v1.0.1 (13 Nov 2026):** Dashboard kini menampilkan angka dari
> server, bukan angka contoh. Saat aplikasi belum terhubung server, kini ada
> penanda jelas "Angka contoh, belum terhubung server" di bawah sapaan, supaya
> tidak tertukar dengan data sungguhan.
### Support Android (`.apk`) & iOS iPhone (`.ipa` via `xtool` + iOS Web App)

Folder `installer/` ini berisi paket instalasi untuk **Android** dan **iOS (iPhone)**:
1. **Android:** `FreightIntel-AI-v1.0.1-release.apk` (~59,7 MB)
2. **iOS (iPhone Native `.ipa`):** `FreightIntel-AI-v1.0.1-iOS.ipa` (dibangun otomatis oleh GitHub Actions macOS & siap di-sign/install ke iPhone menggunakan **`xtool`** dengan akun Apple ID).

---

## A. Cara Install di iPhone (iOS) Menggunakan `xtool`
Dengan [`xtool`](https://github.com/xtool-org/xtool) yang sudah terpasang di Linux (`~/.local/bin/xtool`):

1. **Login Akun Apple ID (cukup sekali):**
   ```bash
   xtool auth login
   ```
   *(Masukkan Apple ID & password akun iPhone, lalu masukkan kode 2FA yang muncul di layar iPhone).*

2. **Hubungkan iPhone via Kabel USB:**
   - Colok iPhone ke laptop dan ketuk **"Trust This Computer" (Percayai Komputer Ini)** di layar iPhone.
   - Cek apakah iPhone sudah terbaca:
     ```bash
     xtool devices
     ```

3. **Sign & Install `.ipa` ke iPhone:**
   ```bash
   xtool install "installer/FreightIntel-AI-v1.0.1-iOS.ipa"
   ```
4. **Aktifkan Developer Mode & Trust Sertifikat di iPhone:**
   - Buka **Settings (Pengaturan) $\to$ General (Umum) $\to$ VPN & Device Management**, pilih akun Apple ID Anda, lalu ketuk **Trust (Percayai)**.
   - Jika memakai iOS 16+, buka **Settings $\to$ Privacy & Security $\to$ Developer Mode** lalu aktifkan.

> **Alternatif Tanpa Kabel untuk iPhone Klien Jarak Jauh (Safari iOS PWA):**
> Jika klien berada di luar kota dan menggunakan iPhone tanpa akses ke komputer, klien juga dapat membuka tautan **Web App iOS** di browser **Safari iPhone** $\to$ ketuk tombol **Share (Bagikan)** $\to$ pilih **Add to Home Screen (Tambahkan ke Layar Utama)**. Aplikasi akan terpasang di layar utama iPhone dan berjalan *full-screen* persis seperti aplikasi native.

---

## B. Cara Install `.apk` di HP Android
1. Unduh berkas **`FreightIntel-AI-v1.0.1-release.apk`** dari Google Drive ke HP Android.
2. Ketuk berkas `.apk` yang sudah diunduh.
3. Jika muncul peringatan keamanan *"Install unknown apps"* / *"Izinkan instalasi dari sumber ini"*, pilih **Setelan (Settings)** $\to$ aktifkan **Izinkan dari sumber ini** $\to$ ketuk **Install**.
4. Jika muncul pop-up *Google Play Protect*, ketuk **Detail lainnya (More details)** $\to$ **Tetap install (Install anyway)**.

---

## C. Cara Masuk & Menjelajahi Aplikasi
1. Pada halaman **Login**, akun bawaan sudah terisi otomatis:
   - **Email:** `owner@nusantara.co.id`
   - **Password:** `demo1234`
2. Langsung ketuk tombol **Masuk** berwarna *lime*.
3. **Mode Mandiri (Offline-Ready) vs Server:**
   - Aplikasi langsung berjalan penuh tanpa konfigurasi tambahan.
   - Untuk menyambungkan ke server/database live, ketuk **"Ketuk untuk atur server"** di bawah tombol Masuk pada halaman Login.
