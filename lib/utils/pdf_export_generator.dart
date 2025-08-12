import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:math';
import '../entities/bill.dart';

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
        margin: const pw.EdgeInsets.all(40),
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'UTILITY BILL SUMMARY',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue900,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              'Period: ${_formatDate(bill.periodStart)} to ${_formatDate(bill.periodEnd)} ${_formatYear(bill.periodStart)}',
              style: const pw.TextStyle(fontSize: 14),
            ),
            pw.SizedBox(height: 16),
          ],
        ),
        build: (pw.Context context) => [
          
          // ELECTRICITY Section (kept together but only moves if needed)
          _keepTogether(_buildUtilitySection(
            title: 'ELECTRICITY (electricity charged at residential B-tariff)',
            openingReading: bill.electricityReading.opening,
            closingReading: bill.electricityReading.closing,
            unitsUsed: bill.electricityReading.unitsUsed,
            unitType: 'Kwh',
            costPerUnit: bill.electricityTariff.steps.first.rate,
            calculatedCost: calculatedElectricityCost,
            vatAmount: calculatedElectricityCost * 0.15,
            totalCost: calculatedElectricityCost + (calculatedElectricityCost * 0.15),
            isSlidingScale: false,
          )),
          pw.SizedBox(height: 20),

          // WATER Section (kept together but only moves if needed)
          _keepTogether(_buildUtilitySection(
            title: 'WATER (water charged on sliding scale)',
            openingReading: bill.waterReading.opening,
            closingReading: bill.waterReading.closing,
            unitsUsed: bill.waterReading.unitsUsed,
            unitType: 'Kl',
            costPerUnit: bill.waterTariff.steps.first.rate,
            calculatedCost: calculatedWaterCost,
            vatAmount: calculatedWaterCost * 0.15,
            totalCost: calculatedWaterCost + (calculatedWaterCost * 0.15),
            isSlidingScale: true,
            tariffSteps: bill.waterTariff.steps,
          )),
          pw.SizedBox(height: 20),

          // SANITATION Section (kept together but only moves if needed)
          _keepTogether(_buildUtilitySection(
            title: 'SANITATION (sanitation charged on sliding scale)',
            openingReading: bill.sanitationReading.opening,
            closingReading: bill.sanitationReading.closing,
            unitsUsed: bill.sanitationReading.unitsUsed,
            unitType: 'Kl',
            costPerUnit: bill.sanitationTariff.steps.first.rate,
            calculatedCost: calculatedSanitationCost,
            vatAmount: calculatedSanitationCost * 0.15,
            totalCost: calculatedSanitationCost + (calculatedSanitationCost * 0.15),
            isSlidingScale: true,
            tariffSteps: bill.sanitationTariff.steps,
          )),
          pw.SizedBox(height: 20),

          // Total Utilities Payable
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(15),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              border: pw.Border.all(color: PdfColors.grey400),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Total Utilities payable:',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  _formatCurrency(calculatedElectricityCost + calculatedWaterCost + calculatedSanitationCost + 
                    (calculatedElectricityCost + calculatedWaterCost + calculatedSanitationCost) * 0.15),
                  style: pw.TextStyle(
                    fontSize: 18,
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

  // Helper to keep a widget from splitting across pages by wrapping it in a single-row table
  static pw.Widget _keepTogether(pw.Widget child) {
    return pw.Table(
      border: null,
      columnWidths: const {0: pw.FlexColumnWidth()},
      children: [
        pw.TableRow(children: [child]),
      ],
    );
  }

  static pw.Widget _buildUtilitySection({
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
  }) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Title
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 15),

          // Readings
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Opening reading:', style: const pw.TextStyle(fontSize: 12)),
              pw.Text(
                openingReading.toStringAsFixed(3),
                style: const pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
          pw.SizedBox(height: 5),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Closing reading:', style: const pw.TextStyle(fontSize: 12)),
              pw.Text(
                closingReading.toStringAsFixed(3),
                style: const pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
          pw.SizedBox(height: 10),

          // Units Used
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('units used($unitType):', style: const pw.TextStyle(fontSize: 12)),
              pw.Text(
                unitsUsed.toStringAsFixed(2),
                style: const pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
          pw.SizedBox(height: 15),

          // Cost Calculation
          if (!isSlidingScale) ...[
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('cost/unit:', style: const pw.TextStyle(fontSize: 12)),
                pw.Text(
                  'R${_truncateToDecimals(costPerUnit, 4)}/kWh',
                  style: const pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),
            pw.SizedBox(height: 5),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Calculated cost:', style: const pw.TextStyle(fontSize: 12)),
                pw.Text(
                  _formatCurrency(calculatedCost),
                  style: const pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),
          ] else ...[
            // Sliding scale calculation
            if (tariffSteps != null) ...[
              pw.Text('Cost Calculation (Sliding Scale):', style: const pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 5),
              ...tariffSteps.asMap().entries.map((entry) {
                final index = entry.key;
                final step = entry.value;
                final stepRange = index == 0 ? '0-6' : index == 1 ? '7-15' : '16-30';
                final stepUnit = 'Kl';
                
                return pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('For $stepRange$stepUnit:', style: const pw.TextStyle(fontSize: 12)),
                    pw.Text(
                      _formatCurrency(step.rate),
                      style: const pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                );
              }),
              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Calculated cost:', style: const pw.TextStyle(fontSize: 12)),
                  pw.Text(
                    _formatCurrency(calculatedCost),
                    style: const pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
            ],
          ],
          pw.SizedBox(height: 15),

          // VAT
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('vat:', style: const pw.TextStyle(fontSize: 12)),
              pw.Text('15%', style: const pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
            ],
          ),
          pw.SizedBox(height: 5),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Calculated VAT amount:', style: const pw.TextStyle(fontSize: 12)),
              pw.Text(
                _formatCurrency(vatAmount),
                style: const pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
          pw.SizedBox(height: 15),

          // Total for this utility
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: PdfColors.blue50,
              border: pw.Border.all(color: PdfColors.blue200),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Total ${title.split(' ')[0]}:',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue900,
                  ),
                ),
                pw.Text(
                  _formatCurrency(totalCost),
                  style: pw.TextStyle(
                    fontSize: 14,
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
  }
}
