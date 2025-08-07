class MeterReading {
  final int opening;
  final int closing;
  
  const MeterReading({required this.opening, required this.closing}) : assert(closing >= opening);
  
  int get unitsUsed => closing - opening;
  
  Map<String, dynamic> toJson() => {
    'opening': opening,
    'closing': closing,
  };
  
  factory MeterReading.fromJson(Map<String, dynamic> json) => MeterReading(
    opening: json['opening'],
    closing: json['closing'],
  );
}
