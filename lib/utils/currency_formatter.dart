class CurrencyFormatter {
  static String formatPemasukan(double value) {
    final intValue = value.round();
    final str = intValue.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < str.length; i++) {
      if (i != 0 && (str.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
    }

    return 'Rp ${buffer.toString()}';
  }
}