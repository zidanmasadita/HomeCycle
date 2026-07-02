class UnitConverter {
  static double toKg({
    required double quantity,
    required String unit,
    double? avgWeightPerUnitGram,
  }) {
    switch (unit) {
      case 'kg':
        return quantity;
      case 'gram':
        return quantity / 1000;
      case 'pcs':
      case 'ikat':
        final weight = avgWeightPerUnitGram ?? 0;
        return (quantity * weight) / 1000;
      default:
        return quantity;
    }
  }
}
