// Data layer Pengaturan (demo, in-memory). Perubahan hilang saat app ditutup.
// Ganti dengan call API saat backend siap. Semua data terikat satu perusahaan
// aktif (BR isolasi data antar perusahaan, FR-CMP-05).

class Company {
  final String id, nama, npwp, alamat, mataUang;
  final double ppnPersen;
  const Company({
    required this.id,
    required this.nama,
    required this.npwp,
    required this.alamat,
    this.mataUang = 'IDR',
    this.ppnPersen = 11,
  });

  Company copyWith({
    String? nama,
    String? npwp,
    String? alamat,
    String? mataUang,
    double? ppnPersen,
  }) =>
      Company(
        id: id,
        nama: nama ?? this.nama,
        npwp: npwp ?? this.npwp,
        alamat: alamat ?? this.alamat,
        mataUang: mataUang ?? this.mataUang,
        ppnPersen: ppnPersen ?? this.ppnPersen,
      );
}

class Branch {
  final String nama, kota;
  final bool pusat;
  final int pengguna;
  const Branch(this.nama, this.kota, {this.pusat = false, this.pengguna = 0});
}

/// Enam peran bawaan (FR-USR-02).
const kRoles = <String>[
  'Super Admin',
  'Owner / Direktur',
  'Finance Manager',
  'Operational Manager',
  'Sales / Marketing',
  'Staff',
];

/// Modul yang dikontrol RBAC (FR-USR-03, FR-USR-04).
const kModules = <String>[
  'Shipment',
  'Revenue',
  'Cost',
  'Laporan',
  'Customer',
  'Vendor',
  'Pengguna',
];

const kActions = <String>['Lihat', 'Buat', 'Ubah', 'Hapus'];

class AppUser {
  final String nama, email, peran, cabang;
  final bool aktif;
  const AppUser(this.nama, this.email, this.peran, this.cabang,
      {this.aktif = true});

  AppUser copyWith({bool? aktif, String? peran}) =>
      AppUser(nama, email, peran ?? this.peran, cabang,
          aktif: aktif ?? this.aktif);

  String get initials {
    final p = nama.split(' ');
    return (p.length > 1 ? p[0][0] + p[1][0] : nama.substring(0, 2))
        .toUpperCase();
  }
}

enum FieldType { teks, angka, mataUang, tanggal, pilihan, centang, berkas }

extension FieldTypeLabel on FieldType {
  String get label => switch (this) {
        FieldType.teks => 'Teks',
        FieldType.angka => 'Angka',
        FieldType.mataUang => 'Mata uang',
        FieldType.tanggal => 'Tanggal',
        FieldType.pilihan => 'Pilihan',
        FieldType.centang => 'Centang',
        FieldType.berkas => 'Berkas',
      };
}

/// Entitas tempat custom field dipasang (FR-CF-03).
const kFieldTargets = <String>[
  'Shipment',
  'Revenue',
  'Cost',
  'Customer',
  'Vendor',
];

class CustomField {
  final String nama, target;
  final FieldType tipe;
  final bool wajib, bisaDicari;
  const CustomField(this.nama, this.target, this.tipe,
      {this.wajib = false, this.bisaDicari = true});
}

class ActivityEntry {
  final String aktor, aksi, detail;
  final DateTime waktu;
  const ActivityEntry(this.aktor, this.aksi, this.detail, this.waktu);
}

class SettingsRepository {
  SettingsRepository._();
  static final instance = SettingsRepository._();

  // --- Perusahaan & cabang -------------------------------------------------
  final List<Company> companies = [
    const Company(
      id: 'c1',
      nama: 'PT Nusantara Freight',
      npwp: '01.234.567.8-091.000',
      alamat: 'Jl. Yos Sudarso No. 12, Jakarta Utara',
    ),
    const Company(
      id: 'c2',
      nama: 'PT Samudra Kargo Mandiri',
      npwp: '02.887.123.4-052.000',
      alamat: 'Jl. Perak Timur No. 88, Surabaya',
    ),
  ];
  String activeCompanyId = 'c1';
  Company get active =>
      companies.firstWhere((c) => c.id == activeCompanyId);

  void updateActive(Company c) {
    final i = companies.indexWhere((e) => e.id == c.id);
    if (i >= 0) companies[i] = c;
  }

  final List<Branch> branches = [
    const Branch('Kantor Pusat', 'Jakarta', pusat: true, pengguna: 9),
    const Branch('Cabang Surabaya', 'Surabaya', pengguna: 5),
    const Branch('Cabang Medan', 'Medan', pengguna: 3),
  ];

  // --- Pengguna ------------------------------------------------------------
  final List<AppUser> users = [
    const AppUser('Budi Santoso', 'budi@nusantara.co.id', 'Owner / Direktur',
        'Kantor Pusat'),
    const AppUser('Rina Wijaya', 'rina@nusantara.co.id', 'Finance Manager',
        'Kantor Pusat'),
    const AppUser('Agus Pratama', 'agus@nusantara.co.id',
        'Operational Manager', 'Cabang Surabaya'),
    const AppUser('Dewi Lestari', 'dewi@nusantara.co.id', 'Sales / Marketing',
        'Kantor Pusat'),
    const AppUser('Hendra Kurnia', 'hendra@nusantara.co.id', 'Staff',
        'Cabang Medan', aktif: false),
  ];

  // --- Izin per peran (FR-USR-04) -----------------------------------------
  /// peran -> modul -> set aksi yang diizinkan.
  final Map<String, Map<String, Set<String>>> permissions = {
    for (final r in kRoles)
      r: {
        for (final m in kModules)
          m: switch (r) {
            'Super Admin' || 'Owner / Direktur' => {...kActions},
            'Finance Manager' => m == 'Revenue' || m == 'Cost' || m == 'Laporan'
                ? {...kActions}
                : m == 'Pengguna'
                    ? <String>{}
                    : {'Lihat'},
            'Operational Manager' => m == 'Shipment' || m == 'Vendor'
                ? {...kActions}
                : m == 'Pengguna'
                    ? <String>{}
                    : {'Lihat'},
            'Sales / Marketing' => m == 'Customer' || m == 'Revenue'
                ? {'Lihat', 'Buat', 'Ubah'}
                : m == 'Pengguna'
                    ? <String>{}
                    : {'Lihat'},
            _ => m == 'Pengguna' ? <String>{} : {'Lihat'},
          }
      }
  };

  // --- Custom field --------------------------------------------------------
  final List<CustomField> fields = [
    const CustomField('Nomor kontainer', 'Shipment', FieldType.teks),
    const CustomField('Jenis kontainer', 'Shipment', FieldType.pilihan),
    const CustomField('ETD', 'Shipment', FieldType.tanggal, wajib: true),
    const CustomField('ETA', 'Shipment', FieldType.tanggal),
    const CustomField('Nomor PO customer', 'Revenue', FieldType.teks),
    const CustomField('Bukti bayar', 'Cost', FieldType.berkas,
        bisaDicari: false),
    const CustomField('Limit kredit', 'Customer', FieldType.mataUang),
    const CustomField('Vendor terverifikasi', 'Vendor', FieldType.centang),
  ];

  // --- Log aktivitas (FR-USR-06) ------------------------------------------
  List<ActivityEntry> get activity => [
        ActivityEntry('Rina Wijaya', 'Catat pembayaran',
            'INV/2610/009 · Rp 40 jt', DateTime(2026, 11, 10, 9, 42)),
        ActivityEntry('Agus Pratama', 'Ubah status shipment',
            'FI-2610-021 → In Transit', DateTime(2026, 11, 10, 8, 15)),
        ActivityEntry('Budi Santoso', 'Masuk', 'Perangkat Android · Jakarta',
            DateTime(2026, 11, 10, 7, 58)),
        ActivityEntry('Dewi Lestari', 'Tambah customer', 'PT Bahari Timur',
            DateTime(2026, 11, 9, 16, 30)),
        ActivityEntry('Rina Wijaya', 'Export laporan', 'Oktober 2026 · PDF',
            DateTime(2026, 11, 9, 14, 5)),
        ActivityEntry('Budi Santoso', 'Ubah izin peran',
            'Staff · Laporan: Lihat', DateTime(2026, 11, 8, 11, 20)),
      ];
}
