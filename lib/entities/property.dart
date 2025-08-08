class Property {
  final String name;
  final String address;

  Property({required this.name, this.address = ''}) : assert(name.isNotEmpty, 'Property name cannot be empty');

  Map<String, dynamic> toJson() => {'name': name, 'address': address};

  factory Property.fromJson(Map<String, dynamic> json) {
    final String name = json['name'] ?? '';
    final String address = json['address'] ?? '';
    assert(name.isNotEmpty);
    return Property(name: name, address: address);
  }
}