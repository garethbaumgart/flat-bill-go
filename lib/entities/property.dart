class Property {
  final String name;
  final String address;
  
  // Default utility rates
  final double? defaultElectricityRate;
  final double? defaultWaterRate0to6;
  final double? defaultWaterRate7to15;
  final double? defaultWaterRate16to30;
  final double? defaultSanitationRate0to6;
  final double? defaultSanitationRate7to15;
  final double? defaultSanitationRate16to30;

  Property({
    required this.name, 
    this.address = '',
    this.defaultElectricityRate,
    this.defaultWaterRate0to6,
    this.defaultWaterRate7to15,
    this.defaultWaterRate16to30,
    this.defaultSanitationRate0to6,
    this.defaultSanitationRate7to15,
    this.defaultSanitationRate16to30,
  }) : assert(name.isNotEmpty, 'Property name cannot be empty');

  Map<String, dynamic> toJson() => {
    'name': name, 
    'address': address,
    'defaultElectricityRate': defaultElectricityRate,
    'defaultWaterRate0to6': defaultWaterRate0to6,
    'defaultWaterRate7to15': defaultWaterRate7to15,
    'defaultWaterRate16to30': defaultWaterRate16to30,
    'defaultSanitationRate0to6': defaultSanitationRate0to6,
    'defaultSanitationRate7to15': defaultSanitationRate7to15,
    'defaultSanitationRate16to30': defaultSanitationRate16to30,
  };

  factory Property.fromJson(Map<String, dynamic> json) {
    final String name = json['name'] ?? '';
    final String address = json['address'] ?? '';
    assert(name.isNotEmpty);
    return Property(
      name: name, 
      address: address,
      defaultElectricityRate: json['defaultElectricityRate']?.toDouble(),
      defaultWaterRate0to6: json['defaultWaterRate0to6']?.toDouble(),
      defaultWaterRate7to15: json['defaultWaterRate7to15']?.toDouble(),
      defaultWaterRate16to30: json['defaultWaterRate16to30']?.toDouble(),
      defaultSanitationRate0to6: json['defaultSanitationRate0to6']?.toDouble(),
      defaultSanitationRate7to15: json['defaultSanitationRate7to15']?.toDouble(),
      defaultSanitationRate16to30: json['defaultSanitationRate16to30']?.toDouble(),
    );
  }
}