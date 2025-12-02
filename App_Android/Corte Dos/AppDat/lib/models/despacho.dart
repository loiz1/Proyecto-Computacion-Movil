class Despacho {
  final String id;
  final String? userId;
  final String cliente;
  final String ciudad;
  final DateTime fecha;
  final int cajas;
  final double peso;
  final double costo;
  final double volumen;
  final String? mes;
  final int? dia;

  Despacho({
    required this.id,
    this.userId,
    required this.cliente,
    required this.ciudad,
    required this.fecha,
    required this.cajas,
    required this.peso,
    required this.costo,
    required this.volumen,
    this.mes,
    this.dia,
  });

  factory Despacho.fromJson(Map<String, dynamic> json) {
    return Despacho(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      cliente: json['cliente'] as String,
      ciudad: json['ciudad'] as String,
      fecha: DateTime.parse(json['fecha'] as String),
      cajas: json['cajas'] as int,
      peso: (json['peso'] as num).toDouble(),
      costo: (json['costo'] as num).toDouble(),
      volumen: (json['volumen'] as num).toDouble(),
      mes: json['mes'] as String?,
      dia: json['dia'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'cliente': cliente,
      'ciudad': ciudad,
      'fecha': fecha.toIso8601String(),
      'cajas': cajas,
      'peso': peso,
      'costo': costo,
      'volumen': volumen,
      'mes': mes,
      'dia': dia,
    };
  }
}

