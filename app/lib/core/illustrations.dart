/// Path aset ilustrasi (flat vector, lihat assets/illustrations).
class Illus {
  static const _b = 'assets/illustrations/';

  static const loginHero = '${_b}login_hero.png';
  static const insightHero = '${_b}insight_hero.png';
  static const emptyShipments = '${_b}empty_shipments.png';
  static const emptyFinance = '${_b}empty_finance.png';
  static const patternRoutes = '${_b}pattern_routes.png';
  static const avatarOwner = '${_b}avatar_owner.png';

  static const modeOcean = '${_b}mode_ocean.png';
  static const modeAir = '${_b}mode_air.png';
  static const modeTrucking = '${_b}mode_trucking.png';
  static const modeHandling = '${_b}mode_handling.png';

  /// Ilustrasi disc sesuai mode pengiriman.
  static String mode(String type) {
    switch (type) {
      case 'Ocean Freight':
        return modeOcean;
      case 'Air Freight':
        return modeAir;
      case 'Handling':
        return modeHandling;
      default:
        return modeTrucking;
    }
  }
}
