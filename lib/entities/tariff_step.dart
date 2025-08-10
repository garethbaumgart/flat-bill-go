class TariffStep {
  final double upToUnits;
  final double rate;
  
  const TariffStep({required this.upToUnits, required this.rate});
  
  Map<String, dynamic> toJson() => {
    'upToUnits': upToUnits,
    'rate': rate,
  };
  
  factory TariffStep.fromJson(Map<String, dynamic> json) => TariffStep(
    upToUnits: (json['upToUnits'] as num).toDouble(),
    rate: (json['rate'] as num).toDouble(),
  );
}
