import 'package:flutter/material.dart';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
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

  Future<void> _exportToPDF() async {
    try {
      // Create PDF document
      final pdf = pw.Document();
      
      // Add page to PDF
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Header(
                  level: 0,
                  child: pw.Text('Utility Bill Summary', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                ),
                pw.SizedBox(height: 20),
                
                // Period
                pw.Text('Billing Period: ${_formatDate(bill.periodStart)} to ${_formatDate(bill.periodEnd)}', 
                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 20),
                
                // Bill details table
                pw.Table(
                  border: pw.TableBorder.all(),
                  children: [
                    // Header row
                    pw.TableRow(
                      children: [
                        pw.Text('Utility', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text('Opening', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text('Closing', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text('Units Used', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text('Cost (ZAR)', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                    // Electricity row
                    pw.TableRow(
                      children: [
                        pw.Text('Electricity'),
                        pw.Text(bill.electricityReading.opening.toString()),
                        pw.Text(bill.electricityReading.closing.toString()),
                        pw.Text(bill.electricityReading.unitsUsed.toString()),
                        pw.Text(_formatCurrency(electricityCost)),
                      ],
                    ),
                    // Water row
                    pw.TableRow(
                      children: [
                        pw.Text('Water'),
                        pw.Text(bill.waterReading.opening.toString()),
                        pw.Text(bill.waterReading.closing.toString()),
                        pw.Text(bill.waterReading.unitsUsed.toString()),
                        pw.Text(_formatCurrency(waterCost)),
                      ],
                    ),
                    // Sanitation row
                    pw.TableRow(
                      children: [
                        pw.Text('Sanitation'),
                        pw.Text(bill.sanitationReading.opening.toString()),
                        pw.Text(bill.sanitationReading.closing.toString()),
                        pw.Text(bill.sanitationReading.unitsUsed.toString()),
                        pw.Text(_formatCurrency(sanitationCost)),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),
                
                // Totals
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Subtotal:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text(_formatCurrency(subtotal)),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('VAT (15%):', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text(_formatCurrency(vat)),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Total:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                    pw.Text(_formatCurrency(total), style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ],
            );
          },
        ),
      );
      
      // Get the documents directory
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'bill_${bill.id}_${_formatDate(bill.periodStart)}.pdf';
      final file = File('${directory.path}/$fileName');
      
      // Write PDF to file
      await file.writeAsBytes(await pdf.save());
      
      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF exported successfully to: $fileName'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting PDF: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
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
            
            // Export to PDF Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _exportToPDF,
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Export to PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                ),
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
