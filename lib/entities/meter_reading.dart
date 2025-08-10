class MeterReading {
  final double opening;
  final double closing;
  
  const MeterReading({required this.opening, required this.closing}) : assert(closing >= opening);
  
  double get unitsUsed => closing - opening;
  
  Map<String, dynamic> toJson() => {
    'opening': opening,
    'closing': closing,
  };
  
  factory MeterReading.fromJson(Map<String, dynamic> json) => MeterReading(
    opening: (json['opening'] as num).toDouble(),
    closing: (json['closing'] as num).toDouble(),
  );
}
