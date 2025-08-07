import 'tariff_step.dart';

class Tariff {
  final List<TariffStep> steps;
  
  const Tariff({required this.steps});
  
  Map<String, dynamic> toJson() => {
    'steps': steps.map((e) => e.toJson()).toList(),
  };
  
  factory Tariff.fromJson(Map<String, dynamic> json) => Tariff(
    steps: (json['steps'] as List).map((e) => TariffStep.fromJson(e)).toList(),
  );
}
