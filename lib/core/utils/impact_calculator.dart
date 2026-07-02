class ImpactCalculator {
  static double calculateCo2Saved({
    required double quantityKg,
    required double co2FactorPerKg,
  }) {
    return quantityKg * co2FactorPerKg;
  }

  static double calculateMoneySaved({
    required double quantity,
    required double avgPricePerUnit,
  }) {
    return quantity * avgPricePerUnit;
  }

  // Menggunakan 0,1 kg CO2/km sebagai tolak ukur yang mudah dipahami untuk perjalanan umum menggunakan sepeda motor atau mobil.
  static String getRelatableComparison(double co2Kg) {
    if (co2Kg <= 0) return '0 km perjalanan motor';
    
    final kmEquivalent = co2Kg / 0.1;
    return '${kmEquivalent.toStringAsFixed(1)} km perjalanan motor';
  }
}
