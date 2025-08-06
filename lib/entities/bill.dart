class MeterReading {
  final int opening;
  final int closing;
  const MeterReading({required this.opening, required this.closing}) : assert(closing >= opening);
  int get unitsUsed => closing - opening;
  Map<String, dynamic> toJson() => {'opening': opening, 'closing': closing};
  factory MeterReading.fromJson(Map<String, dynamic> json) => MeterReading(opening: json['opening'], closing: json['closing']);
}

class Tariff {
  final List<TariffStep> steps;
  const Tariff({required this.steps});
  Map<String, dynamic> toJson() => {'steps': steps.map((e) => e.toJson()).toList()};
  factory Tariff.fromJson(Map<String, dynamic> json) => Tariff(steps: (json['steps'] as List).map((e) => TariffStep.fromJson(e)).toList());
}

class TariffStep {
  final int upToUnits;
  final double rate;
  const TariffStep({required this.upToUnits, required this.rate});
  Map<String, dynamic> toJson() => {'upToUnits': upToUnits, 'rate': rate};
  factory TariffStep.fromJson(Map<String, dynamic> json) => TariffStep(upToUnits: json['upToUnits'], rate: json['rate']);
}

class Bill {
  final String id;
  final DateTime periodStart;
  final DateTime periodEnd;
  final MeterReading electricityReading;
  final MeterReading waterReading;
  final MeterReading sanitationReading;
  final Tariff electricityTariff;
  final Tariff waterTariff;
  final Tariff sanitationTariff;
  const Bill({required this.id, required this.periodStart, required this.periodEnd, required this.electricityReading, required this.waterReading, required this.sanitationReading, required this.electricityTariff, required this.waterTariff, required this.sanitationTariff});
  Map<String, dynamic> toJson() => {'id': id, 'periodStart': periodStart.toIso8601String(), 'periodEnd': periodEnd.toIso8601String(), 'electricityReading': electricityReading.toJson(), 'waterReading': waterReading.toJson(), 'sanitationReading': sanitationReading.toJson(), 'electricityTariff': electricityTariff.toJson(), 'waterTariff': waterTariff.toJson(), 'sanitationTariff': sanitationTariff.toJson()};
  factory Bill.fromJson(Map<String, dynamic> json) => Bill(id: json['id'], periodStart: DateTime.parse(json['periodStart']), periodEnd: DateTime.parse(json['periodEnd']), electricityReading: MeterReading.fromJson(json['electricityReading']), waterReading: MeterReading.fromJson(json['waterReading']), sanitationReading: MeterReading.fromJson(json['sanitationReading']), electricityTariff: Tariff.fromJson(json['electricityTariff']), waterTariff: Tariff.fromJson(json['waterTariff']), sanitationTariff: Tariff.fromJson(json['sanitationTariff']));
}