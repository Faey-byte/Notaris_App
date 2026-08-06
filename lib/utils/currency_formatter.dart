class CurrencyFormatter {
  static String formatPemasukan(double value) {
    if (value >= 1000000) {
      final m = value / 1000000;
      final formatted =
          m % 1 == 0 ? m.toStringAsFixed(0) : m.toStringAsFixed(1);
      return 'Rp ${formatted}M';
    } else if (value >= 1000) {
      final k = value / 1000;
      return 'Rp ${k.toStringAsFixed(0)}K';
    }
    return 'Rp ${value.toStringAsFixed(0)}';
  }
}