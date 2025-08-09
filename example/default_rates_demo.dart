// Example showing how the new default utility rates feature works
// This demonstrates the key functionality added to address issue #11

import '../lib/entities/property.dart';

void main() {
  print('=== Flat Bill Go - Default Utility Rates Demo ===\n');

  // 1. Creating a property with default utility rates
  print('1. Setting up property with default rates:');
  final property = Property(
    name: 'Sunset Apartments Unit 4B',
    address: '123 Sunset Drive, Cape Town',
    defaultElectricityRate: 3.40,
    defaultWaterRate0to6: 20.80,
    defaultWaterRate7to15: 34.20,
    defaultWaterRate16to30: 48.50,
    defaultSanitationRate0to6: 25.50,
    defaultSanitationRate7to15: 20.50,
    defaultSanitationRate16to30: 29.80,
  );

  print('   Property: ${property.name}');
  print('   Address: ${property.address}');
  print('   Electricity Rate: R${property.defaultElectricityRate}/kWh');
  print('   Water Rates: R${property.defaultWaterRate0to6}/R${property.defaultWaterRate7to15}/R${property.defaultWaterRate16to30}');
  print('   Sanitation Rates: R${property.defaultSanitationRate0to6}/R${property.defaultSanitationRate7to15}/R${property.defaultSanitationRate16to30}');

  // 2. Serializing to JSON (for storage)
  print('\n2. Saving property data:');
  final json = property.toJson();
  print('   JSON contains ${json.keys.length} fields including default rates');
  print('   Sample: defaultElectricityRate = ${json['defaultElectricityRate']}');

  // 3. Loading from JSON (backward compatibility)
  print('\n3. Loading legacy property (without defaults):');
  final legacyJson = {
    'name': 'Old Property',
    'address': '456 Old Street',
    // No default rates in legacy data
  };

  final legacyProperty = Property.fromJson(legacyJson);
  print('   Name: ${legacyProperty.name}');
  print('   Address: ${legacyProperty.address}');
  print('   Has defaults: ${legacyProperty.defaultElectricityRate != null}');

  // 4. Loading property with defaults (for new bill creation)
  print('\n4. Using defaults for new bill:');
  final loadedProperty = Property.fromJson(json);
  print('   When creating a new bill, these rates will be pre-filled:');
  print('   - Electricity: R${loadedProperty.defaultElectricityRate}/kWh');
  print('   - Water 0-6kl: R${loadedProperty.defaultWaterRate0to6}');
  print('   - Water 7-15kl: R${loadedProperty.defaultWaterRate7to15}');
  print('   - Water 16-30kl: R${loadedProperty.defaultWaterRate16to30}');
  print('   - Sanitation 0-6kl: R${loadedProperty.defaultSanitationRate0to6}');
  print('   - Sanitation 7-15kl: R${loadedProperty.defaultSanitationRate7to15}');
  print('   - Sanitation 16-30kl: R${loadedProperty.defaultSanitationRate16to30}');

  print('\n=== Demo Complete ===');
  print('Key benefits:');
  print('• Users no longer need to enter rates manually every time');
  print('• Rates can be set once in property details');
  print('• New bills automatically use property defaults');
  print('• Users can still override rates for specific bills');
  print('• Backward compatible with existing data');
}