import 'package:flutter/material.dart';
import '../entities/bill.dart';

class BillSummaryScreen extends StatelessWidget {
  final Bill bill;
  final double electricityCost;
  final double waterCost;
  final double sanitationCost;
  final double subtotal;
  final double vat;
  final double total;

  const BillSummaryScreen({
    super.key,
    required this.bill,
    required this.electricityCost,
    required this.waterCost,
    required this.sanitationCost,
    required this.subtotal,
    required this.vat,
    required this.total,
  });

  String _formatCurrency(double amount) {
    return 'R${amount.toStringAsFixed(2)}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bill Summary'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Period: ${_formatDate(bill.periodStart)} to ${_formatDate(bill.periodEnd)}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Bill Details Table
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Expanded(flex: 2, child: Text('Utility', style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(child: Text('Opening', style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(child: Text('Closing', style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(child: Text('Units Used', style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(child: Text('Cost (ZAR)', style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                    ),
                  ),
                  
                  // Electricity Row
                  _buildTableRow(
                    'Electricity',
                    bill.electricityReading.opening.toString(),
                    bill.electricityReading.closing.toString(),
                    bill.electricityReading.unitsUsed.toString(),
                    _formatCurrency(electricityCost),
                  ),
                  
                  // Water Row
                  _buildTableRow(
                    'Water',
                    bill.waterReading.opening.toString(),
                    bill.waterReading.closing.toString(),
                    bill.waterReading.unitsUsed.toString(),
                    _formatCurrency(waterCost),
                  ),
                  
                  // Sanitation Row
                  _buildTableRow(
                    'Sanitation',
                    bill.sanitationReading.opening.toString(),
                    bill.sanitationReading.closing.toString(),
                    bill.sanitationReading.unitsUsed.toString(),
                    _formatCurrency(sanitationCost),
                  ),
                  
                  // Subtotal Row
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      border: Border(top: BorderSide(color: Colors.grey.shade300)),
                    ),
                    child: Row(
                      children: [
                        const Expanded(flex: 4, child: Text('Subtotal', style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(child: Text(_formatCurrency(subtotal), style: const TextStyle(fontWeight: FontWeight.bold))),
                      ],
                    ),
                  ),
                  
                  // VAT Row
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      border: Border(top: BorderSide(color: Colors.grey.shade300)),
                    ),
                    child: Row(
                      children: [
                        const Expanded(flex: 4, child: Text('VAT (15%)', style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(child: Text(_formatCurrency(vat), style: const TextStyle(fontWeight: FontWeight.bold))),
                      ],
                    ),
                  ),
                  
                  // Total Row
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Expanded(flex: 4, child: Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                        Expanded(child: Text(_formatCurrency(total), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bill saved successfully!')),
                  );
                  Navigator.of(context).pop();
                },
                child: const Text('Save Bill'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableRow(String utility, String opening, String closing, String unitsUsed, String cost) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(utility)),
          Expanded(child: Text(opening)),
          Expanded(child: Text(closing)),
          Expanded(child: Text(unitsUsed)),
          Expanded(child: Text(cost)),
        ],
      ),
    );
  }
}
