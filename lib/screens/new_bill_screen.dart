import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/bill_controller.dart';
import '../controllers/property_controller.dart';
import '../entities/bill.dart';
import '../entities/meter_reading.dart';
import '../entities/tariff.dart';
import '../entities/tariff_step.dart';
import '../screens/bill_summary_screen.dart';
import '../utils/invoice_number_generator.dart';

class NewBillScreen extends ConsumerStatefulWidget {
  final Bill? billToEdit;
  
  const NewBillScreen({super.key, this.billToEdit});

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
  void initState() {
    super.initState();
    if (widget.billToEdit != null) {
      _populateFormForEdit();
    } else {
      _loadPropertyDefaults();
    }
  }

  void _loadPropertyDefaults() async {
    final propertyAsync = ref.read(propertyControllerProvider);
    propertyAsync.whenData((property) {
      if (property != null) {
        if (property.defaultElectricityRate != null) {
          _electricityTariffController.text = property.defaultElectricityRate.toString();
        }
        if (property.defaultWaterRate0to6 != null) {
          _waterTariff0to6Controller.text = property.defaultWaterRate0to6.toString();
        }
        if (property.defaultWaterRate7to15 != null) {
          _waterTariff7to15Controller.text = property.defaultWaterRate7to15.toString();
        }
        if (property.defaultWaterRate16to30 != null) {
          _waterTariff16to30Controller.text = property.defaultWaterRate16to30.toString();
        }
        if (property.defaultSanitationRate0to6 != null) {
          _sanitationTariff0to6Controller.text = property.defaultSanitationRate0to6.toString();
        }
        if (property.defaultSanitationRate7to15 != null) {
          _sanitationTariff7to15Controller.text = property.defaultSanitationRate7to15.toString();
        }
        if (property.defaultSanitationRate16to30 != null) {
          _sanitationTariff16to30Controller.text = property.defaultSanitationRate16to30.toString();
        }
      }
    });
  }

  void _populateFormForEdit() {
    final bill = widget.billToEdit!;
    
    // Set dates
    setState(() {
      _periodStart = bill.periodStart;
      _periodEnd = bill.periodEnd;
    });
    
    // Electricity data
    _electricityOpenController.text = bill.electricityReading.opening.toString();
    _electricityCloseController.text = bill.electricityReading.closing.toString();
    _electricityTariffController.text = bill.electricityTariff.steps.first.rate.toString();
    
    // Water data
    _waterOpenController.text = bill.waterReading.opening.toString();
    _waterCloseController.text = bill.waterReading.closing.toString();
    _waterTariff0to6Controller.text = bill.waterTariff.steps[0].rate.toString();
    _waterTariff7to15Controller.text = bill.waterTariff.steps[1].rate.toString();
    _waterTariff16to30Controller.text = bill.waterTariff.steps[2].rate.toString();
    
    // Sanitation data
    _sanitationOpenController.text = bill.sanitationReading.opening.toString();
    _sanitationCloseController.text = bill.sanitationReading.closing.toString();
    _sanitationTariff0to6Controller.text = bill.sanitationTariff.steps[0].rate.toString();
    _sanitationTariff7to15Controller.text = bill.sanitationTariff.steps[1].rate.toString();
    _sanitationTariff16to30Controller.text = bill.sanitationTariff.steps[2].rate.toString();
  }

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
          // Set default end date to same day next month - 1 day
          final DateTime defaultEndDate = DateTime(picked.year, picked.month + 1, picked.day - 1);
          _periodEnd = defaultEndDate;
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

  void _fillTestData() {
    // Set dates
    setState(() {
      _periodStart = DateTime(2024, 4, 1);
      _periodEnd = DateTime(2024, 4, 30);
    });
    
    // Electricity data
    _electricityOpenController.text = '12720';
    _electricityCloseController.text = '12850';
    _electricityTariffController.text = '3.40';
    
    // Water data
    _waterOpenController.text = '222';
    _waterCloseController.text = '230';
    _waterTariff0to6Controller.text = '20.80';
    _waterTariff7to15Controller.text = '34.20';
    _waterTariff16to30Controller.text = '48.50';
    
    // Sanitation data
    _sanitationOpenController.text = '222';
    _sanitationCloseController.text = '230';
    _sanitationTariff0to6Controller.text = '25.50';
    _sanitationTariff7to15Controller.text = '20.50';
    _sanitationTariff16to30Controller.text = '29.80';
  }

  Future<void> _calculateBill() async {
    if (_formKey.currentState!.validate() && _periodStart != null && _periodEnd != null) {
      try {
        // Parse meter readings
        final int electricityOpen = int.parse(_electricityOpenController.text);
        final int electricityClose = int.parse(_electricityCloseController.text);
        final int waterOpen = int.parse(_waterOpenController.text);
        final int waterClose = int.parse(_waterCloseController.text);
        final int sanitationOpen = int.parse(_sanitationOpenController.text);
        final int sanitationClose = int.parse(_sanitationCloseController.text);

        // Parse tariffs
        final double electricityTariff = double.parse(_electricityTariffController.text);
        final double waterTariff0to6 = double.parse(_waterTariff0to6Controller.text);
        final double waterTariff7to15 = double.parse(_waterTariff7to15Controller.text);
        final double waterTariff16to30 = double.parse(_waterTariff16to30Controller.text);
        final double sanitationTariff0to6 = double.parse(_sanitationTariff0to6Controller.text);
        final double sanitationTariff7to15 = double.parse(_sanitationTariff7to15Controller.text);
        final double sanitationTariff16to30 = double.parse(_sanitationTariff16to30Controller.text);

        // Calculate units used
        final int electricityUnits = electricityClose - electricityOpen;
        final int waterUnits = waterClose - waterOpen;
        final int sanitationUnits = sanitationClose - sanitationOpen;

        // Calculate costs with sliding scale
        final double electricityCost = electricityUnits * electricityTariff;
        
        // Water sliding scale calculation
        double waterCost = 0;
        int remainingUnits = waterUnits;
        if (remainingUnits > 0) {
          final int firstTier = remainingUnits > 6 ? 6 : remainingUnits;
          waterCost += firstTier * waterTariff0to6;
          remainingUnits -= firstTier;
        }
        if (remainingUnits > 0) {
          final int secondTier = remainingUnits > 9 ? 9 : remainingUnits;
          waterCost += secondTier * waterTariff7to15;
          remainingUnits -= secondTier;
        }
        if (remainingUnits > 0) {
          waterCost += remainingUnits * waterTariff16to30;
        }

        // Sanitation sliding scale calculation
        double sanitationCost = 0;
        remainingUnits = sanitationUnits;
        if (remainingUnits > 0) {
          final int firstTier = remainingUnits > 6 ? 6 : remainingUnits;
          sanitationCost += firstTier * sanitationTariff0to6;
          remainingUnits -= firstTier;
        }
        if (remainingUnits > 0) {
          final int secondTier = remainingUnits > 9 ? 9 : remainingUnits;
          sanitationCost += secondTier * sanitationTariff7to15;
          remainingUnits -= secondTier;
        }
        if (remainingUnits > 0) {
          sanitationCost += remainingUnits * sanitationTariff16to30;
        }

        // Calculate totals
        final double subtotal = electricityCost + waterCost + sanitationCost;
        final double vat = subtotal * 0.15; // 15% VAT
        final double total = subtotal + vat;

        // Create meter readings
        final electricityReading = MeterReading(opening: electricityOpen, closing: electricityClose);
        final waterReading = MeterReading(opening: waterOpen, closing: waterClose);
        final sanitationReading = MeterReading(opening: sanitationOpen, closing: sanitationClose);

        // Create tariffs
        final electricityTariffSteps = [TariffStep(upToUnits: electricityUnits, rate: electricityTariff)];
        final electricityTariffObj = Tariff(steps: electricityTariffSteps);
        
        final waterTariffSteps = [
          TariffStep(upToUnits: 6, rate: waterTariff0to6),
          TariffStep(upToUnits: 15, rate: waterTariff7to15),
          TariffStep(upToUnits: 30, rate: waterTariff16to30),
        ];
        final waterTariffObj = Tariff(steps: waterTariffSteps);
        
        final sanitationTariffSteps = [
          TariffStep(upToUnits: 6, rate: sanitationTariff0to6),
          TariffStep(upToUnits: 15, rate: sanitationTariff7to15),
          TariffStep(upToUnits: 30, rate: sanitationTariff16to30),
        ];
        final sanitationTariffObj = Tariff(steps: sanitationTariffSteps);

        // Create bill
        final invoiceNumber = await InvoiceNumberGenerator.generateNextInvoiceNumber();
        final bill = Bill(
          id: widget.billToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
          invoiceNumber: widget.billToEdit?.invoiceNumber ?? invoiceNumber,
          periodStart: _periodStart!,
          periodEnd: _periodEnd!,
          electricityReading: electricityReading,
          waterReading: waterReading,
          sanitationReading: sanitationReading,
          electricityTariff: electricityTariffObj,
          waterTariff: waterTariffObj,
          sanitationTariff: sanitationTariffObj,
        );

        // Save bill
        await ref.read(billControllerProvider.notifier).saveBill(bill);

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.billToEdit != null ? 'Bill updated successfully!' : 'Bill calculated and saved successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }

        // Navigate to bill summary
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => BillSummaryScreen(
                bill: bill,
                electricityCost: electricityCost,
                waterCost: waterCost,
                sanitationCost: sanitationCost,
                subtotal: subtotal,
                vat: vat,
                total: total,
              ),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error calculating bill: $e')),
        );
      }
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
        title: Text(widget.billToEdit != null ? 'Edit Bill' : 'New Bill'),
        actions: [
          // Load defaults button
          if (widget.billToEdit == null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                _loadPropertyDefaults();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Property defaults loaded!')),
                );
              },
              tooltip: 'Load Property Defaults',
            ),
          // Debug button for pre-filling test data
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () {
              _fillTestData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Test data filled!')),
              );
            },
            tooltip: 'Fill Test Data (Debug)',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Period Card
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_today, color: Colors.blue.shade700),
                          const SizedBox(width: 8),
                          const Text(
                            'Billing Period',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => _selectDate(context, true),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(8),
                                  color: _periodStart != null ? Colors.blue.shade50 : Colors.grey.shade50,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Start Date',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _periodStart != null 
                                        ? '${_periodStart!.day}/${_periodStart!.month}/${_periodStart!.year}'
                                        : 'Select Date',
                                      style: TextStyle(
                                        color: _periodStart != null ? Colors.black : Colors.grey,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: InkWell(
                              onTap: () => _selectDate(context, false),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(8),
                                  color: _periodEnd != null ? Colors.blue.shade50 : Colors.grey.shade50,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'End Date',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _periodEnd != null 
                                        ? '${_periodEnd!.day}/${_periodEnd!.month}/${_periodEnd!.year}'
                                        : 'Select Date',
                                      style: TextStyle(
                                        color: _periodEnd != null ? Colors.black : Colors.grey,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Electricity Card
              Card(
                elevation: 2,
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
                            'Electricity',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _electricityOpenController,
                              decoration: InputDecoration(
                                labelText: 'Open Reading',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
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
                              decoration: InputDecoration(
                                labelText: 'Close Reading',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
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
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _electricityTariffController,
                        decoration: InputDecoration(
                          labelText: 'Tariff (R/kWh)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixText: 'R',
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          helperText: 'Loaded from property defaults if available',
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
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Water Card
              Card(
                elevation: 2,
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
                            'Water',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _waterOpenController,
                              decoration: InputDecoration(
                                labelText: 'Open Reading',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
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
                              decoration: InputDecoration(
                                labelText: 'Close Reading',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
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
                      const SizedBox(height: 16),
                      const Text(
                        'Tariffs:',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _waterTariff0to6Controller,
                              decoration: InputDecoration(
                                labelText: '0-6kl (R)',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixText: 'R',
                                filled: true,
                                fillColor: Colors.grey.shade50,
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
                              decoration: InputDecoration(
                                labelText: '7-15kl (R)',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixText: 'R',
                                filled: true,
                                fillColor: Colors.grey.shade50,
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
                              decoration: InputDecoration(
                                labelText: '16-30kl (R)',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixText: 'R',
                                filled: true,
                                fillColor: Colors.grey.shade50,
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
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Sanitation Card
              Card(
                elevation: 2,
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
                            'Sanitation',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _sanitationOpenController,
                              decoration: InputDecoration(
                                labelText: 'Open Reading',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
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
                              decoration: InputDecoration(
                                labelText: 'Close Reading',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
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
                      const SizedBox(height: 16),
                      const Text(
                        'Tariffs:',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _sanitationTariff0to6Controller,
                              decoration: InputDecoration(
                                labelText: '0-6kl (R)',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixText: 'R',
                                filled: true,
                                fillColor: Colors.grey.shade50,
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
                              decoration: InputDecoration(
                                labelText: '7-15kl (R)',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixText: 'R',
                                filled: true,
                                fillColor: Colors.grey.shade50,
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
                              decoration: InputDecoration(
                                labelText: '16-30kl (R)',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixText: 'R',
                                filled: true,
                                fillColor: Colors.grey.shade50,
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
                    ],
                  ),
                ),
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
