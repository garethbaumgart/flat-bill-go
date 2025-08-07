import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/bill_controller.dart';
import '../entities/bill.dart';

class NewBillScreen extends ConsumerStatefulWidget {
  const NewBillScreen({super.key});

  @override
  ConsumerState<NewBillScreen> createState() => _NewBillScreenState();
}

class _NewBillScreenState extends ConsumerState<NewBillScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _periodStart;
  DateTime? _periodEnd;
  
  // Electricity
  final _electricityOpenController = TextEditingController();
  final _electricityCloseController = TextEditingController();
  final _electricityTariffController = TextEditingController();
  
  // Water
  final _waterOpenController = TextEditingController();
  final _waterCloseController = TextEditingController();
  final _waterTariff0to6Controller = TextEditingController();
  final _waterTariff7to15Controller = TextEditingController();
  final _waterTariff16to30Controller = TextEditingController();
  
  // Sanitation
  final _sanitationOpenController = TextEditingController();
  final _sanitationCloseController = TextEditingController();
  final _sanitationTariff0to6Controller = TextEditingController();
  final _sanitationTariff7to15Controller = TextEditingController();
  final _sanitationTariff16to30Controller = TextEditingController();

  @override
  void dispose() {
    _electricityOpenController.dispose();
    _electricityCloseController.dispose();
    _electricityTariffController.dispose();
    _waterOpenController.dispose();
    _waterCloseController.dispose();
    _waterTariff0to6Controller.dispose();
    _waterTariff7to15Controller.dispose();
    _waterTariff16to30Controller.dispose();
    _sanitationOpenController.dispose();
    _sanitationCloseController.dispose();
    _sanitationTariff0to6Controller.dispose();
    _sanitationTariff7to15Controller.dispose();
    _sanitationTariff16to30Controller.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? DateTime.now() : (_periodStart ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _periodStart = picked;
        } else {
          _periodEnd = picked;
        }
      });
    }
  }

  String _formatCurrency(String value) {
    if (value.isEmpty) return '';
    final double? number = double.tryParse(value);
    if (number == null) return value;
    return 'R${number.toStringAsFixed(2)}';
  }

  String _parseCurrency(String value) {
    return value.replaceAll('R', '').replaceAll(',', '');
  }

  Future<void> _calculateBill() async {
    if (_formKey.currentState!.validate() && _periodStart != null && _periodEnd != null) {
      // TODO: Implement bill calculation logic
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bill calculation coming soon!')),
      );
    } else if (_periodStart == null || _periodEnd == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both start and end dates')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Bill'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Period
              const Text('Period:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context, true),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _periodStart != null 
                            ? '${_periodStart!.day}/${_periodStart!.month}/${_periodStart!.year}'
                            : 'Select Start Date',
                          style: TextStyle(
                            color: _periodStart != null ? Colors.black : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context, false),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _periodEnd != null 
                            ? '${_periodEnd!.day}/${_periodEnd!.month}/${_periodEnd!.year}'
                            : 'Select End Date',
                          style: TextStyle(
                            color: _periodEnd != null ? Colors.black : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Electricity
              const Text('Electricity:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _electricityOpenController,
                      decoration: const InputDecoration(
                        labelText: 'Open Reading',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _electricityCloseController,
                      decoration: const InputDecoration(
                        labelText: 'Close Reading',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _electricityTariffController,
                decoration: const InputDecoration(
                  labelText: 'Tariff (R/kWh)',
                  border: OutlineInputBorder(),
                  prefixText: 'R',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Required';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Invalid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              // Water
              const Text('Water:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _waterOpenController,
                      decoration: const InputDecoration(
                        labelText: 'Open Reading',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _waterCloseController,
                      decoration: const InputDecoration(
                        labelText: 'Close Reading',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text('Tariffs:'),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _waterTariff0to6Controller,
                      decoration: const InputDecoration(
                        labelText: '0-6kl (R)',
                        border: OutlineInputBorder(),
                        prefixText: 'R',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Invalid amount';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _waterTariff7to15Controller,
                      decoration: const InputDecoration(
                        labelText: '7-15kl (R)',
                        border: OutlineInputBorder(),
                        prefixText: 'R',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Invalid amount';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _waterTariff16to30Controller,
                      decoration: const InputDecoration(
                        labelText: '16-30kl (R)',
                        border: OutlineInputBorder(),
                        prefixText: 'R',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Invalid amount';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Sanitation
              const Text('Sanitation:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _sanitationOpenController,
                      decoration: const InputDecoration(
                        labelText: 'Open Reading',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _sanitationCloseController,
                      decoration: const InputDecoration(
                        labelText: 'Close Reading',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text('Tariffs:'),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _sanitationTariff0to6Controller,
                      decoration: const InputDecoration(
                        labelText: '0-6kl (R)',
                        border: OutlineInputBorder(),
                        prefixText: 'R',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Invalid amount';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _sanitationTariff7to15Controller,
                      decoration: const InputDecoration(
                        labelText: '7-15kl (R)',
                        border: OutlineInputBorder(),
                        prefixText: 'R',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Invalid amount';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _sanitationTariff16to30Controller,
                      decoration: const InputDecoration(
                        labelText: '16-30kl (R)',
                        border: OutlineInputBorder(),
                        prefixText: 'R',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Invalid amount';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _calculateBill,
                  child: const Text('Calculate Bill'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
