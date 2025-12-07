# Hotel Management System (Finpro PSD Kelompok 23)

Repository ini berisi implementasi VHDL untuk **Hotel Management System** sebagai Final Project mata kuliah Perancangan Sistem Digital (PSD). Sistem ini mensimulasikan operasional hotel yang mencakup kontrol akses kamar, manajemen waktu, dan penjadwalan kebersihan otomatis.

## Deskripsi Proyek

Sistem ini dirancang menggunakan *Finite State Machine* (FSM) untuk mengatur status dan keamanan kamar hotel. Sistem mampu menangani banyak kamar di berbagai lantai dan mensimulasikan perjalanan waktu untuk memicu kejadian (seperti penguncian malam hari).

### Fitur Utama

1. **Sistem Keamanan Kamar (Access Control)**
   - **Validasi PIN:** Akses kamar memerlukan input PIN 16-bit. Logika keamanan menggunakan validasi unik di mana PIN yang benar adalah kebalikan (*reversed*) dari ID kamar.
   - **Kunci & Buka Kunci:** Penghuni dapat mengunci atau membuka kunci kamar secara manual setelah akses diberikan.
   - **Emergency Lock All:** Fitur keamanan darurat untuk mengunci seluruh kamar di hotel secara instan.

2. **Simulasi Waktu & Hari**
   - Sistem memiliki penghitung waktu internal yang mensimulasikan siklus hari:
     - **Waktu:** Pagi (*Morning*), Siang (*Noon*), Sore (*Afternoon*), Malam (*Night*).
     - **Hari:** Minggu (*Sunday*) s.d. Sabtu (*Saturday*).

3. **Otomatisasi Cerdas**
   - **Auto-Lock Night Mode:** Semua kamar akan terkunci secara otomatis saat waktu menunjukkan **Malam (Night)** demi keamanan.
   - **Jadwal Kebersihan Otomatis:** Sistem secara otomatis menandai kamar sedang dibersihkan pada hari **Rabu** dan **Sabtu** di waktu Pagi.

4. **Manajemen Kamar**
   - Monitoring status kamar (Terisi, Terkunci, Butuh Dibersihkan, Sedang Dibersihkan).
   - Permintaan pembersihan manual (*Manual Clean Request*).

## Struktur Kode

- **Entity Utama:** `Hotel_Management_System`
  - Mengelola logika utama, state machine akses, dan array data seluruh kamar.
  - Parameter *Generic*: Jumlah lantai (`FLOORS`) dan kamar per lantai (`ROOMS_PER_FLOOR`).
- **Testbench:** `Hotel_Management_System_TB`
  - Berfungsi untuk memverifikasi fitur seperti akses PIN benar/salah, fitur *emergency*, dan transisi waktu otomatis.

## Cara Menggunakan (Simulasi)

1. **Clone Repository:**
   ```bash
   git clone https://github.com/alwahibrr/Finpro-PSD-Kelompok-23.git
   ```

2. **Buka Project:**
   Gunakan software simulator VHDL:
   - ModelSim
   - Xilinx Vivado
   - Intel Quartus

3. **Compile Source Code:**
   Compile file utama, kemudian file testbench.

4. **Jalankan Testbench:**
   Simulasikan `Hotel_Management_System_TB`.
   - Sinyal `room_status` untuk melihat perubahan status kamar.
   - Sinyal `current_time_of_day` dan `current_day` untuk melihat pergantian waktu.

## Author

**Kelompok 23 - Proyek Sistem Digital**
- Michael Christian (https://github.com/Mishaws)
- Abram Adrian (https://github.com/AbramAdrian404)
- Alwahib Raffi Raihan (https://github.com/alwahibrr)
- Putu Arkana (https://github.com/Allmeerage)