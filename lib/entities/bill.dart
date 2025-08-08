import 'meter_reading.dart';
import 'tariff.dart';

class Bill {
  final String id;
  final String invoiceNumber;
  final DateTime periodStart;
  final DateTime periodEnd;
  final MeterReading electricityReading;
  final MeterReading waterReading;
  final MeterReading sanitationReading;
  final Tariff electricityTariff;
  final Tariff waterTariff;
  final Tariff sanitationTariff;
  
  const Bill({
    required this.id,
    required this.invoiceNumber,
    required this.periodStart,
    required this.periodEnd,
    required this.electricityReading,
    required this.waterReading,
    required this.sanitationReading,
    required this.electricityTariff,
    required this.waterTariff,
    required this.sanitationTariff,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'invoiceNumber': invoiceNumber,
    'periodStart': periodStart.toIso8601String(),
    'periodEnd': periodEnd.toIso8601String(),
    'electricityReading': electricityReading.toJson(),
    'waterReading': waterReading.toJson(),
    'sanitationReading': sanitationReading.toJson(),
    'electricityTariff': electricityTariff.toJson(),
    'waterTariff': waterTariff.toJson(),
    'sanitationTariff': sanitationTariff.toJson(),
  };
  
  factory Bill.fromJson(Map<String, dynamic> json) => Bill(
    id: json['id'],
    invoiceNumber: json['invoiceNumber'] ?? 'INV-0001', // Default for backward compatibility
    periodStart: DateTime.parse(json['periodStart']),
    periodEnd: DateTime.parse(json['periodEnd']),
    electricityReading: MeterReading.fromJson(json['electricityReading']),
    waterReading: MeterReading.fromJson(json['waterReading']),
    sanitationReading: MeterReading.fromJson(json['sanitationReading']),
    electricityTariff: Tariff.fromJson(json['electricityTariff']),
    waterTariff: Tariff.fromJson(json['waterTariff']),
    sanitationTariff: Tariff.fromJson(json['sanitationTariff']),
  );
}