import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../entities/bill.dart';
import '../controllers/bill_controller.dart';
import 'new_bill_screen.dart';
import 'dart:convert';
import 'package:universal_html/html.dart' as html;
import '../utils/pdf_export_generator.dart';







class BillSummaryScreen extends ConsumerStatefulWidget {
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

  @override
  ConsumerState<BillSummaryScreen> createState() => _BillSummaryScreenState();
}

class _BillSummaryScreenState extends ConsumerState<BillSummaryScreen> {

  String _formatCurrency(double amount) {
    return 'R${amount.toStringAsFixed(2)}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _exportToPDF(BuildContext context) async {
    try {
      print('🔧 Debug: Starting PDF export...');
      
      // Generate detailed PDF using the new generator
      final pdf = PdfExportGenerator.generateDetailedBillPdf(
        bill: widget.bill,
        electricityCost: widget.electricityCost,
        waterCost: widget.waterCost,
        sanitationCost: widget.sanitationCost,
        subtotal: widget.subtotal,
        vat: widget.vat,
        total: widget.total,
      );
      
      // Generate filename
      final fileName = widget.bill.invoiceNumber.isNotEmpty 
          ? '${widget.bill.invoiceNumber}_${widget.bill.periodStart.year}_${widget.bill.periodStart.month.toString().padLeft(2, '0')}_${widget.bill.periodStart.day.toString().padLeft(2, '0')}.pdf'
          : 'bill_${widget.bill.id}_${widget.bill.periodStart.year}_${widget.bill.periodStart.month.toString().padLeft(2, '0')}_${widget.bill.periodStart.day.toString().padLeft(2, '0')}.pdf';
      
      // Save PDF bytes
      final bytes = await pdf.save();
      
      if (kIsWeb) {
        // For web, trigger download using universal_html
        print('🔧 Debug: Triggering web download...');
        
        if (context.mounted) {
          // Create blob and download the PDF using universal_html
          final blob = html.Blob([bytes], 'application/pdf');
          final url = html.Url.createObjectUrlFromBlob(blob);
          final anchor = html.AnchorElement(href: url)
            ..setAttribute('download', fileName)
            ..click();
          html.Url.revokeObjectUrl(url);
          
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('PDF downloaded: $fileName'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        // For mobile platforms, save to file
        print('🔧 Debug: PDF document created, preparing for download...');
        
        // For mobile platforms, save to file
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$fileName');
        
        print('🔧 Debug: Saving PDF to ${file.path}');
        
        await file.writeAsBytes(bytes);
        
        print('🔧 Debug: PDF saved successfully');
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('PDF exported successfully to: $fileName'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      print('🔧 Debug: PDF export error: $e');
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

  void _editBill(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NewBillScreen(
          billToEdit: widget.bill,
        ),
      ),
    );
  }



  Future<void> _showDeleteDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Bill'),
          content: Text('Are you sure you want to delete this bill for ${_formatDate(widget.bill.periodStart)} - ${_formatDate(widget.bill.periodEnd)}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Close the dialog
                Navigator.of(context).pop();
                // Perform deletion via controller
                await ref.read(billControllerProvider.notifier).deleteBill(widget.bill.id);
                if (!mounted) return;
                // Navigate back to the list
                Navigator.of(context).pop();
                // Notify
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Bill deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.bill.invoiceNumber.isNotEmpty ? '${widget.bill.invoiceNumber} - Bill Summary' : 'Bill Summary'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () => _editBill(context),
            tooltip: 'Edit Bill',
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _showDeleteDialog(context),
            tooltip: 'Delete Bill',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
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
                        'Period: ${_formatDate(widget.bill.periodStart)} to ${_formatDate(widget.bill.periodEnd)}',
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
                    widget.bill.electricityReading.opening.toString(),
                    widget.bill.electricityReading.closing.toString(),
                    widget.bill.electricityReading.unitsUsed.toString(),
                    _formatCurrency(widget.electricityCost),
                  ),
                  
                  // Water Row
                  _buildTableRow(
                    'Water',
                    widget.bill.waterReading.opening.toString(),
                    widget.bill.waterReading.closing.toString(),
                    widget.bill.waterReading.unitsUsed.toString(),
                    _formatCurrency(widget.waterCost),
                  ),
                  
                  // Sanitation Row
                  _buildTableRow(
                    'Sanitation',
                    widget.bill.sanitationReading.opening.toString(),
                    widget.bill.sanitationReading.closing.toString(),
                    widget.bill.sanitationReading.unitsUsed.toString(),
                    _formatCurrency(widget.sanitationCost),
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
                        Expanded(child: Text(_formatCurrency(widget.subtotal), style: const TextStyle(fontWeight: FontWeight.bold))),
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
                        Expanded(child: Text(_formatCurrency(widget.vat), style: const TextStyle(fontWeight: FontWeight.bold))),
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
                        Expanded(child: Text(_formatCurrency(widget.total), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Tariff Details Section
            Card(
              child: ExpansionTile(
                leading: Icon(Icons.settings, color: Colors.orange.shade700),
                title: const Text(
                  'Tariff Details',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Electricity Tariff
                        _buildTariffSection(
                          'Electricity',
                          Icons.electric_bolt,
                          Colors.orange,
                          [
                            'Rate: R${widget.bill.electricityTariff.steps.first.rate.toStringAsFixed(2)}/kWh',
                            'Units: ${widget.bill.electricityReading.unitsUsed} kWh',
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Water Tariff
                        _buildTariffSection(
                          'Water',
                          Icons.water_drop,
                          Colors.blue,
                          [
                            '0-6 kl: R${widget.bill.waterTariff.steps[0].rate.toStringAsFixed(2)}/kl',
                            '7-15 kl: R${widget.bill.waterTariff.steps[1].rate.toStringAsFixed(2)}/kl',
                            '16-30 kl: R${widget.bill.waterTariff.steps[2].rate.toStringAsFixed(2)}/kl',
                            'Units: ${widget.bill.waterReading.unitsUsed} kl',
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Sanitation Tariff
                        _buildTariffSection(
                          'Sanitation',
                          Icons.cleaning_services,
                          Colors.green,
                          [
                            '0-6 kl: R${widget.bill.sanitationTariff.steps[0].rate.toStringAsFixed(2)}/kl',
                            '7-15 kl: R${widget.bill.sanitationTariff.steps[1].rate.toStringAsFixed(2)}/kl',
                            '16-30 kl: R${widget.bill.sanitationTariff.steps[2].rate.toStringAsFixed(2)}/kl',
                            'Units: ${widget.bill.sanitationReading.unitsUsed} kl',
                          ],
                        ),
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
                onPressed: () => _exportToPDF(context),
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
    ));
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

  Widget _buildTariffSection(String title, IconData icon, Color color, List<String> details) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...details.map((detail) => Padding(
            padding: const EdgeInsets.only(left: 28.0, bottom: 4.0),
            child: Text(
              detail,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
              ),
            ),
          )),
        ],
      ),
    );
  }

  void _triggerPrintDialog() {
    if (kIsWeb) {
      // For web, show instructions to use browser's print function
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please use Ctrl+P (or Cmd+P) to print and save as PDF.'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 5),
        ),
      );
    }
  }
}
