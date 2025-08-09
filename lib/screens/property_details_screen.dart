import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/property_controller.dart';
import '../entities/property.dart';
import 'main_bill_list_screen.dart';

class PropertyDetailsScreen extends ConsumerStatefulWidget {
  const PropertyDetailsScreen({super.key});

  @override
  ConsumerState<PropertyDetailsScreen> createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends ConsumerState<PropertyDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  
  // Default utility rate controllers
  final _electricityRateController = TextEditingController();
  final _waterRate0to6Controller = TextEditingController();
  final _waterRate7to15Controller = TextEditingController();
  final _waterRate16to30Controller = TextEditingController();
  final _sanitationRate0to6Controller = TextEditingController();
  final _sanitationRate7to15Controller = TextEditingController();
  final _sanitationRate16to30Controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProperty();
  }

  void _loadProperty() {
    final propertyAsync = ref.read(propertyControllerProvider);
    propertyAsync.whenData((property) {
      if (property != null) {
        _nameController.text = property.name;
        _addressController.text = property.address;
        _electricityRateController.text = property.defaultElectricityRate?.toString() ?? '';
        _waterRate0to6Controller.text = property.defaultWaterRate0to6?.toString() ?? '';
        _waterRate7to15Controller.text = property.defaultWaterRate7to15?.toString() ?? '';
        _waterRate16to30Controller.text = property.defaultWaterRate16to30?.toString() ?? '';
        _sanitationRate0to6Controller.text = property.defaultSanitationRate0to6?.toString() ?? '';
        _sanitationRate7to15Controller.text = property.defaultSanitationRate7to15?.toString() ?? '';
        _sanitationRate16to30Controller.text = property.defaultSanitationRate16to30?.toString() ?? '';
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _electricityRateController.dispose();
    _waterRate0to6Controller.dispose();
    _waterRate7to15Controller.dispose();
    _waterRate16to30Controller.dispose();
    _sanitationRate0to6Controller.dispose();
    _sanitationRate7to15Controller.dispose();
    _sanitationRate16to30Controller.dispose();
    super.dispose();
  }

  Future<void> _saveProperty() async {
    if (_formKey.currentState!.validate()) {
      final property = Property(
        name: _nameController.text.trim(),
        address: _addressController.text.trim(),
        defaultElectricityRate: double.tryParse(_electricityRateController.text.trim()),
        defaultWaterRate0to6: double.tryParse(_waterRate0to6Controller.text.trim()),
        defaultWaterRate7to15: double.tryParse(_waterRate7to15Controller.text.trim()),
        defaultWaterRate16to30: double.tryParse(_waterRate16to30Controller.text.trim()),
        defaultSanitationRate0to6: double.tryParse(_sanitationRate0to6Controller.text.trim()),
        defaultSanitationRate7to15: double.tryParse(_sanitationRate7to15Controller.text.trim()),
        defaultSanitationRate16to30: double.tryParse(_sanitationRate16to30Controller.text.trim()),
      );
      await ref.read(propertyControllerProvider.notifier).saveProperty(property);
      if (mounted) {
        // Navigate back to main screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const MainBillListScreen(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Property Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.home, color: Colors.blue.shade700),
                          const SizedBox(width: 8),
                          const Text(
                            'Property Information',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Property Name',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a property name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Property Address',
                        ),
                        validator: (value) {
                          // Address is optional, so no validation needed
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Electricity Default Rates Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.electric_bolt, color: Colors.orange.shade700),
                          const SizedBox(width: 8),
                          const Text(
                            'Default Electricity Rate',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _electricityRateController,
                        decoration: const InputDecoration(
                          labelText: 'Rate (R/kWh)',
                          prefixText: 'R',
                          helperText: 'Optional - will be used as default when creating new bills',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                        ],
                        validator: (value) {
                          if (value != null && value.trim().isNotEmpty && double.tryParse(value) == null) {
                            return 'Invalid amount';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Water Default Rates Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.water_drop, color: Colors.blue.shade700),
                          const SizedBox(width: 8),
                          const Text(
                            'Default Water Rates',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Tiered Rates:',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _waterRate0to6Controller,
                              decoration: const InputDecoration(
                                labelText: '0-6kl (R)',
                                prefixText: 'R',
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                              ],
                              validator: (value) {
                                if (value != null && value.trim().isNotEmpty && double.tryParse(value) == null) {
                                  return 'Invalid amount';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: _waterRate7to15Controller,
                              decoration: const InputDecoration(
                                labelText: '7-15kl (R)',
                                prefixText: 'R',
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                              ],
                              validator: (value) {
                                if (value != null && value.trim().isNotEmpty && double.tryParse(value) == null) {
                                  return 'Invalid amount';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: _waterRate16to30Controller,
                              decoration: const InputDecoration(
                                labelText: '16-30kl (R)',
                                prefixText: 'R',
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                              ],
                              validator: (value) {
                                if (value != null && value.trim().isNotEmpty && double.tryParse(value) == null) {
                                  return 'Invalid amount';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Sanitation Default Rates Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.cleaning_services, color: Colors.green.shade700),
                          const SizedBox(width: 8),
                          const Text(
                            'Default Sanitation Rates',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Tiered Rates:',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _sanitationRate0to6Controller,
                              decoration: const InputDecoration(
                                labelText: '0-6kl (R)',
                                prefixText: 'R',
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                              ],
                              validator: (value) {
                                if (value != null && value.trim().isNotEmpty && double.tryParse(value) == null) {
                                  return 'Invalid amount';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: _sanitationRate7to15Controller,
                              decoration: const InputDecoration(
                                labelText: '7-15kl (R)',
                                prefixText: 'R',
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                              ],
                              validator: (value) {
                                if (value != null && value.trim().isNotEmpty && double.tryParse(value) == null) {
                                  return 'Invalid amount';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: _sanitationRate16to30Controller,
                              decoration: const InputDecoration(
                                labelText: '16-30kl (R)',
                                prefixText: 'R',
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                              ],
                              validator: (value) {
                                if (value != null && value.trim().isNotEmpty && double.tryParse(value) == null) {
                                  return 'Invalid amount';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveProperty,
                  child: const Text('Save Property'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
