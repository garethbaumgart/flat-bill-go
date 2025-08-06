class Property {
  final String name;
  final String address;

  const Property({required this.name, required this.address}) : assert(name != ''), assert(address != '');

  Map<String, dynamic> toJson() => {'name': name, 'address': address};

  factory Property.fromJson(Map<String, dynamic> json) {
    final String name = json['name'] ?? '';
    final String address = json['address'] ?? '';
    assert(name != '');
    assert(address != '');
    return Property(name: name, address: address);
  }
}