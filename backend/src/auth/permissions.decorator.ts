import { SetMetadata } from '@nestjs/common';

export const PERMISSIONS_KEY = 'requiredPermissions';

/**
 * Menandai izin yang wajib dimiliki pemanggil, mis.
 * `@RequirePermission('SHIPMENT_BUAT')`. Kode mengikuti kolom
 * `permissions.code` di basis data: `MODUL_AKSI`
 * (DASHBOARD | SHIPMENT | REVENUE | COST | LAPORAN | CUSTOMER | PENGATURAN
 *  x LIHAT | BUAT | UBAH | HAPUS).
 *
 * Bila beberapa kode diberikan, pemanggil cukup memiliki salah satunya.
 * Rute tanpa dekorator ini tetap terbuka untuk siapa pun yang sudah masuk.
 */
export const RequirePermission = (...codes: string[]) =>
  SetMetadata(PERMISSIONS_KEY, codes);
