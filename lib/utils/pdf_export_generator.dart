import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:math';
import '../entities/bill.dart';
import '../entities/property.dart';

class PdfExportGenerator {
  static String _formatCurrency(double amount) {
    return 'R${amount.toStringAsFixed(2)}';
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}';
  }

  static String _formatYear(DateTime date) {
    return date.year.toString();
  }

  // Helper method to truncate to specified decimal places (no rounding)
  static String _truncateToDecimals(num value, int decimals) {
    final factor = pow(10, decimals);
    final truncated = (value * factor).floor() / factor;
    return truncated.toStringAsFixed(decimals);
  }

  // Calculate water cost using sliding scale (same logic as bill summary)
  static double _calculateWaterCost(Bill bill) {
    final units = bill.waterReading.unitsUsed;
    final rate0to6 = bill.waterTariff.steps[0].rate;
    final rate7to15 = bill.waterTariff.steps[1].rate;
    final rate16to30 = bill.waterTariff.steps[2].rate;
    
    double remainingUnits = units;
    double totalCost = 0;
    
    // First tier (0-6 kl)
    if (remainingUnits > 0) {
      final firstTier = remainingUnits > 6 ? 6 : remainingUnits;
      totalCost += firstTier * rate0to6;
      remainingUnits -= firstTier;
    }
    
    // Second tier (7-15 kl)
    if (remainingUnits > 0) {
      final secondTier = remainingUnits > 9 ? 9 : remainingUnits;
      totalCost += secondTier * rate7to15;
      remainingUnits -= secondTier;
    }
    
    // Third tier (16+ kl)
    if (remainingUnits > 0) {
      totalCost += remainingUnits * rate16to30;
    }
    
    return totalCost;
  }

  // Calculate sanitation cost using sliding scale (same logic as bill summary)
  static double _calculateSanitationCost(Bill bill) {
    final units = bill.sanitationReading.unitsUsed;
    final rate0to6 = bill.sanitationTariff.steps[0].rate;
    final rate7to15 = bill.sanitationTariff.steps[1].rate;
    final rate16to30 = bill.sanitationTariff.steps[2].rate;
    
    double remainingUnits = units;
    double totalCost = 0;
    
    // First tier (0-6 kl)
    if (remainingUnits > 0) {
      final firstTier = remainingUnits > 6 ? 6 : remainingUnits;
      totalCost += firstTier * rate0to6;
      remainingUnits -= firstTier;
    }
    
    // Second tier (7-15 kl)
    if (remainingUnits > 0) {
      final secondTier = remainingUnits > 9 ? 9 : remainingUnits;
      totalCost += secondTier * rate7to15;
      remainingUnits -= secondTier;
    }
    
    // Third tier (16+ kl)
    if (remainingUnits > 0) {
      totalCost += remainingUnits * rate16to30;
    }
    
    return totalCost;
  }

  static pw.Document generateDetailedBillPdf({
    required Bill bill,
    required double electricityCost,
    required double waterCost,
    required double sanitationCost,
    required double subtotal,
    required double vat,
    required double total,
    Property? property,
  }) {
    print('🔧 Debug: Generating PDF with costs - Electricity: $electricityCost, Water: $waterCost, Sanitation: $sanitationCost');
    print('🔧 Debug: Sanitation reading - Opening: ${bill.sanitationReading.opening}, Closing: ${bill.sanitationReading.closing}, Units: ${bill.sanitationReading.unitsUsed}');
    
    // Calculate costs using the same logic as bill summary
    final calculatedWaterCost = _calculateWaterCost(bill);
    final calculatedSanitationCost = _calculateSanitationCost(bill);
    final calculatedElectricityCost = bill.electricityReading.unitsUsed * bill.electricityTariff.steps.first.rate;
    
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20), // Further reduced margins
        header: (context) => pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 8), // Minimal padding
          decoration: pw.BoxDecoration(
            border: pw.Border(
              bottom: pw.BorderSide(color: PdfColors.grey300, width: 1),
            ),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'UTILITY BILL',
                    style: pw.TextStyle(
                      fontSize: 18, // Smaller title
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue900,
                    ),
                  ),
                  pw.Text(
                    '${bill.invoiceNumber} | ${DateTime.now().day.toString().padLeft(2, '0')}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().year}',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue900,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 4),
              // Add property address if available
              if (property != null && property.address.isNotEmpty) ...[
                pw.Text(
                  property.address,
                  style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.normal,
                    color: PdfColors.grey700,
                  ),
                ),
                pw.SizedBox(height: 2),
              ],
              pw.Text(
                'Period: ${_formatDate(bill.periodStart)} to ${_formatDate(bill.periodEnd)} ${_formatYear(bill.periodStart)}',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.normal,
                  color: PdfColors.grey800,
                ),
              ),
            ],
          ),
        ),
        build: (pw.Context context) => [
          
          // Compact utility sections in a more condensed layout
          _buildCompactUtilitySection(
            title: 'ELECTRICITY',
            openingReading: bill.electricityReading.opening,
            closingReading: bill.electricityReading.closing,
            unitsUsed: bill.electricityReading.unitsUsed,
            unitType: 'kWh',
            costPerUnit: bill.electricityTariff.steps.first.rate,
            calculatedCost: calculatedElectricityCost,
            vatAmount: calculatedElectricityCost * 0.15,
            totalCost: calculatedElectricityCost + (calculatedElectricityCost * 0.15),
            isSlidingScale: false,
            utilityColor: PdfColors.orange,
          ),
          pw.SizedBox(height: 8),

          _buildCompactUtilitySection(
            title: 'WATER',
            openingReading: bill.waterReading.opening,
            closingReading: bill.waterReading.closing,
            unitsUsed: bill.waterReading.unitsUsed,
            unitType: 'kl',
            costPerUnit: bill.waterTariff.steps.first.rate,
            calculatedCost: calculatedWaterCost,
            vatAmount: calculatedWaterCost * 0.15,
            totalCost: calculatedWaterCost + (calculatedWaterCost * 0.15),
            isSlidingScale: true,
            tariffSteps: bill.waterTariff.steps,
            utilityColor: PdfColors.blue,
          ),
          pw.SizedBox(height: 8),

          _buildCompactUtilitySection(
            title: 'SANITATION',
            openingReading: bill.sanitationReading.opening,
            closingReading: bill.sanitationReading.closing,
            unitsUsed: bill.sanitationReading.unitsUsed,
            unitType: 'kl',
            costPerUnit: bill.sanitationTariff.steps.first.rate,
            calculatedCost: calculatedSanitationCost,
            vatAmount: calculatedSanitationCost * 0.15,
            totalCost: calculatedSanitationCost + (calculatedSanitationCost * 0.15),
            isSlidingScale: true,
            tariffSteps: bill.sanitationTariff.steps,
            utilityColor: PdfColors.green,
          ),
          pw.SizedBox(height: 12),

          // Final total
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.blue50,
              border: pw.Border.all(color: PdfColors.blue200, width: 2),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'TOTAL AMOUNT DUE',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue900,
                  ),
                ),
                pw.Text(
                  _formatCurrency(calculatedElectricityCost + calculatedWaterCost + calculatedSanitationCost + 
                    (calculatedElectricityCost + calculatedWaterCost + calculatedSanitationCost) * 0.15),
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return pdf;
  }

  static pw.Widget _buildCompactUtilitySection({
    required String title,
    required double openingReading,
    required double closingReading,
    required double unitsUsed,
    required String unitType,
    required double costPerUnit,
    required double calculatedCost,
    required double vatAmount,
    required double totalCost,
    required bool isSlidingScale,
    List? tariffSteps,
    PdfColor? utilityColor,
  }) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(8), // Very compact padding
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        border: pw.Border.all(color: utilityColor ?? PdfColors.grey400, width: 1),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Compact header
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(6),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: const pw.BorderRadius.only(
                topLeft: pw.Radius.circular(6),
                topRight: pw.Radius.circular(6),
              ),
            ),
            child: pw.Text(
              title,
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: utilityColor ?? PdfColors.blue900,
              ),
            ),
          ),
          pw.SizedBox(height: 8),

          // Compact readings and calculations in a table format
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            columnWidths: const {
              0: pw.FlexColumnWidth(2),
              1: pw.FlexColumnWidth(1),
            },
            children: [
              // Readings row
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('Readings', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                      '${openingReading.toStringAsFixed(1)} - ${closingReading.toStringAsFixed(1)} (${unitsUsed.toStringAsFixed(1)} $unitType)',
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(fontSize: 9),
                    ),
                  ),
                ],
              ),
              // Rate row
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                      isSlidingScale ? 'Rate Type' : 'Rate per unit',
                      style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                      isSlidingScale ? 'Sliding Scale' : 'R${_truncateToDecimals(costPerUnit, 4)}',
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(fontSize: 9),
                    ),
                  ),
                ],
              ),
              // Base cost row
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('Base cost', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                      _formatCurrency(calculatedCost),
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                ],
              ),
              // VAT row
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text('VAT (15%)', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                      _formatCurrency(vatAmount),
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(fontSize: 9, color: PdfColors.red700),
                    ),
                  ),
                ],
              ),
              // Total row
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.grey50),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                      'TOTAL',
                      style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: utilityColor ?? PdfColors.blue900),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                      _formatCurrency(totalCost),
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: utilityColor ?? PdfColors.blue900),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
