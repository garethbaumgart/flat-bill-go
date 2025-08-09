import 'package:flutter_test/flutter_test.dart';
import 'package:flat_bill_go/entities/property.dart';

void main() {
  group('Property Entity Tests', () {
    test('Property can be created with default rates', () {
      final property = Property(
        name: 'Test Property',
        address: '123 Test Street',
        defaultElectricityRate: 3.40,
        defaultWaterRate0to6: 20.80,
        defaultWaterRate7to15: 34.20,
        defaultWaterRate16to30: 48.50,
        defaultSanitationRate0to6: 25.50,
        defaultSanitationRate7to15: 20.50,
        defaultSanitationRate16to30: 29.80,
      );

      expect(property.name, 'Test Property');
      expect(property.address, '123 Test Street');
      expect(property.defaultElectricityRate, 3.40);
      expect(property.defaultWaterRate0to6, 20.80);
      expect(property.defaultWaterRate7to15, 34.20);
      expect(property.defaultWaterRate16to30, 48.50);
      expect(property.defaultSanitationRate0to6, 25.50);
      expect(property.defaultSanitationRate7to15, 20.50);
      expect(property.defaultSanitationRate16to30, 29.80);
    });

    test('Property can be created without default rates (backward compatibility)', () {
      final property = Property(
        name: 'Simple Property',
        address: '456 Simple Street',
      );

      expect(property.name, 'Simple Property');
      expect(property.address, '456 Simple Street');
      expect(property.defaultElectricityRate, isNull);
      expect(property.defaultWaterRate0to6, isNull);
      expect(property.defaultWaterRate7to15, isNull);
      expect(property.defaultWaterRate16to30, isNull);
      expect(property.defaultSanitationRate0to6, isNull);
      expect(property.defaultSanitationRate7to15, isNull);
      expect(property.defaultSanitationRate16to30, isNull);
    });

    test('Property serializes to JSON correctly with default rates', () {
      final property = Property(
        name: 'Test Property',
        address: '123 Test Street',
        defaultElectricityRate: 3.40,
        defaultWaterRate0to6: 20.80,
        defaultWaterRate7to15: 34.20,
        defaultWaterRate16to30: 48.50,
        defaultSanitationRate0to6: 25.50,
        defaultSanitationRate7to15: 20.50,
        defaultSanitationRate16to30: 29.80,
      );

      final json = property.toJson();

      expect(json['name'], 'Test Property');
      expect(json['address'], '123 Test Street');
      expect(json['defaultElectricityRate'], 3.40);
      expect(json['defaultWaterRate0to6'], 20.80);
      expect(json['defaultWaterRate7to15'], 34.20);
      expect(json['defaultWaterRate16to30'], 48.50);
      expect(json['defaultSanitationRate0to6'], 25.50);
      expect(json['defaultSanitationRate7to15'], 20.50);
      expect(json['defaultSanitationRate16to30'], 29.80);
    });

    test('Property deserializes from JSON correctly with default rates', () {
      final json = {
        'name': 'Test Property',
        'address': '123 Test Street',
        'defaultElectricityRate': 3.40,
        'defaultWaterRate0to6': 20.80,
        'defaultWaterRate7to15': 34.20,
        'defaultWaterRate16to30': 48.50,
        'defaultSanitationRate0to6': 25.50,
        'defaultSanitationRate7to15': 20.50,
        'defaultSanitationRate16to30': 29.80,
      };

      final property = Property.fromJson(json);

      expect(property.name, 'Test Property');
      expect(property.address, '123 Test Street');
      expect(property.defaultElectricityRate, 3.40);
      expect(property.defaultWaterRate0to6, 20.80);
      expect(property.defaultWaterRate7to15, 34.20);
      expect(property.defaultWaterRate16to30, 48.50);
      expect(property.defaultSanitationRate0to6, 25.50);
      expect(property.defaultSanitationRate7to15, 20.50);
      expect(property.defaultSanitationRate16to30, 29.80);
    });

    test('Property deserializes from legacy JSON without default rates', () {
      final json = {
        'name': 'Legacy Property',
        'address': '789 Legacy Street',
      };

      final property = Property.fromJson(json);

      expect(property.name, 'Legacy Property');
      expect(property.address, '789 Legacy Street');
      expect(property.defaultElectricityRate, isNull);
      expect(property.defaultWaterRate0to6, isNull);
      expect(property.defaultWaterRate7to15, isNull);
      expect(property.defaultWaterRate16to30, isNull);
      expect(property.defaultSanitationRate0to6, isNull);
      expect(property.defaultSanitationRate7to15, isNull);
      expect(property.defaultSanitationRate16to30, isNull);
    });

    test('Property handles mixed JSON with some default rates', () {
      final json = {
        'name': 'Mixed Property',
        'address': '321 Mixed Street',
        'defaultElectricityRate': 2.50,
        'defaultWaterRate0to6': 15.00,
        // Missing other rates should be null
      };

      final property = Property.fromJson(json);

      expect(property.name, 'Mixed Property');
      expect(property.address, '321 Mixed Street');
      expect(property.defaultElectricityRate, 2.50);
      expect(property.defaultWaterRate0to6, 15.00);
      expect(property.defaultWaterRate7to15, isNull);
      expect(property.defaultWaterRate16to30, isNull);
      expect(property.defaultSanitationRate0to6, isNull);
      expect(property.defaultSanitationRate7to15, isNull);
      expect(property.defaultSanitationRate16to30, isNull);
    });
  });
}