class TariffStep {
  final int upToUnits;
  final double rate;
  
  const TariffStep({required this.upToUnits, required this.rate});
  
  Map<String, dynamic> toJson() => {
    'upToUnits': upToUnits,
    'rate': rate,
  };
  
  factory TariffStep.fromJson(Map<String, dynamic> json) => TariffStep(
    upToUnits: json['upToUnits'],
    rate: json['rate'],
  );
}
