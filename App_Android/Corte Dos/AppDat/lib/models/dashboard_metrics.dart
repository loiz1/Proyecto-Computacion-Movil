class DashboardMetrics {
  final int totalCajas;
  final double totalPeso;
  final double totalCosto;
  final double totalVolumen;
  final double promedioCajas;
  final double promedioPeso;

  DashboardMetrics({
    required this.totalCajas,
    required this.totalPeso,
    required this.totalCosto,
    required this.totalVolumen,
    required this.promedioCajas,
    required this.promedioPeso,
  });

  factory DashboardMetrics.fromJson(Map<String, dynamic> json) {
    return DashboardMetrics(
      totalCajas: json['totalCajas'] as int,
      totalPeso: (json['totalPeso'] as num).toDouble(),
      totalCosto: (json['totalCosto'] as num).toDouble(),
      totalVolumen: (json['totalVolumen'] as num).toDouble(),
      promedioCajas: (json['promedioCajas'] as num).toDouble(),
      promedioPeso: (json['promedioPeso'] as num).toDouble(),
    );
  }
}

