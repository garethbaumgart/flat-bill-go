import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
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
          // ELECTRICITY Section on its own page
          _buildUtilitySection(
            title: 'ELECTRICITY (electricity charged at residential B-tariff)',
            openingReading: bill.electricityReading.opening,
            closingReading: bill.electricityReading.closing,
            unitsUsed: bill.electricityReading.unitsUsed,
            unitType: 'Kwh',
            costPerUnit: bill.electricityTariff.steps.first.rate,
            calculatedCost: electricityCost - (electricityCost * 0.15), // Remove VAT to get base cost
            vatAmount: electricityCost * 0.15,
            totalCost: electricityCost,
            isSlidingScale: false,
          ),
          pw.NewPage(),

          // WATER Section on its own page
          _buildUtilitySection(
            title: 'WATER (water charged on sliding scale)',
            openingReading: bill.waterReading.opening,
            closingReading: bill.waterReading.closing,
            unitsUsed: bill.waterReading.unitsUsed,
            unitType: 'Kl',
            costPerUnit: bill.waterTariff.steps.first.rate,
            calculatedCost: waterCost - (waterCost * 0.15), // Remove VAT to get base cost
            vatAmount: waterCost * 0.15,
            totalCost: waterCost,
            isSlidingScale: true,
            tariffSteps: bill.waterTariff.steps,
          ),
          pw.NewPage(),

          // SANITATION Section on its own page with totals after
          _buildUtilitySection(
            title: 'SANITATION (sanitation charged on sliding scale)',
            openingReading: bill.sanitationReading.opening,
            closingReading: bill.sanitationReading.closing,
            unitsUsed: bill.sanitationReading.unitsUsed,
            unitType: 'Kl',
            costPerUnit: bill.sanitationTariff.steps.first.rate,
            calculatedCost: sanitationCost - (sanitationCost * 0.15), // Remove VAT to get base cost
            vatAmount: sanitationCost * 0.15,
            totalCost: sanitationCost,
            isSlidingScale: true,
            tariffSteps: bill.sanitationTariff.steps,
          ),
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
                  _formatCurrency(total),
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

  static pw.Widget _buildUtilitySection({
    required String title,
    required int openingReading,
    required int closingReading,
    required int unitsUsed,
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
                  _formatCurrency(costPerUnit),
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
