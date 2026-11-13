import { SetMetadata } from '@nestjs/common';

/// Menandai rute yang boleh diakses tanpa token (login & health check).
export const IS_PUBLIC_KEY = 'isPublic';
export const Public = () => SetMetadata(IS_PUBLIC_KEY, true);
