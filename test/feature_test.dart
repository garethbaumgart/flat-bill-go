import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flat_bill_go/main.dart';
import 'package:flat_bill_go/screens/main_bill_list_screen.dart';
import 'package:flat_bill_go/screens/new_bill_screen.dart';
import 'package:flat_bill_go/screens/bill_summary_screen.dart';
import 'package:flat_bill_go/entities/bill.dart';
import 'package:flat_bill_go/entities/property.dart';
import 'package:flat_bill_go/entities/meter_reading.dart';
import 'package:flat_bill_go/entities/tariff.dart';
import 'package:flat_bill_go/entities/tariff_step.dart';

void main() {
  group('Flat Bill Go App Tests', () {
    testWidgets('App launches successfully', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: MyApp()));
      await tester.pumpAndSettle();
      
      expect(find.text('Flat Bill Go'), findsOneWidget);
    });

    testWidgets('Main screen shows property and bills', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const ProviderScope(child: MainBillListScreen()),
        ),
      );
      await tester.pumpAndSettle();
      
      // Should show property name or placeholder
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('New Bill screen has all required fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const ProviderScope(child: NewBillScreen()),
        ),
      );
      await tester.pumpAndSettle();
      
      // Check for period selection
      expect(find.text('Billing Period'), findsOneWidget);
      expect(find.text('Start Date'), findsOneWidget);
      expect(find.text('End Date'), findsOneWidget);
      
      // Check for electricity section
      expect(find.text('Electricity'), findsOneWidget);
      
      // Check for water section
      expect(find.text('Water'), findsOneWidget);
      
      // Check for sanitation section
      expect(find.text('Sanitation'), findsOneWidget);
      
      // Check for calculate button
      expect(find.text('Calculate Bill'), findsOneWidget);
    });

    testWidgets('Bill Summary screen displays correctly', (WidgetTester tester) async {
      // Create a test bill
      final testBill = Bill(
        id: 'test_bill_1',
        periodStart: DateTime(2024, 1, 1),
        periodEnd: DateTime(2024, 1, 31),
        electricityReading: MeterReading(opening: 1000, closing: 1100),
        waterReading: MeterReading(opening: 200, closing: 208),
        sanitationReading: MeterReading(opening: 200, closing: 208),
        electricityTariff: Tariff(steps: [TariffStep(upToUnits: 100, rate: 3.25)]),
        waterTariff: Tariff(steps: [
          TariffStep(upToUnits: 6, rate: 19.75),
          TariffStep(upToUnits: 15, rate: 32.55),
          TariffStep(upToUnits: 30, rate: 45.20),
        ]),
        sanitationTariff: Tariff(steps: [
          TariffStep(upToUnits: 6, rate: 24.42),
          TariffStep(upToUnits: 15, rate: 19.54),
          TariffStep(upToUnits: 30, rate: 28.75),
        ]),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ProviderScope(
            child: BillSummaryScreen(
              bill: testBill,
              electricityCost: 325.0,
              waterCost: 151.1,
              sanitationCost: 172.36,
              subtotal: 648.46,
              vat: 97.27,
              total: 745.73,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      // Check for bill summary elements
      expect(find.text('Bill Summary'), findsOneWidget);
      expect(find.text('Electricity'), findsOneWidget);
      expect(find.text('Water'), findsOneWidget);
      expect(find.text('Sanitation'), findsOneWidget);
      expect(find.text('Subtotal'), findsOneWidget);
      expect(find.text('VAT (15%)'), findsOneWidget);
      expect(find.text('Total'), findsOneWidget);
      expect(find.text('Export to PDF'), findsOneWidget);
    });

    testWidgets('Debug button fills test data', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const ProviderScope(child: NewBillScreen()),
        ),
      );
      await tester.pumpAndSettle();
      
      // Find and tap the debug button
      final debugButton = find.byIcon(Icons.bug_report);
      expect(debugButton, findsOneWidget);
      
      await tester.tap(debugButton);
      await tester.pumpAndSettle();
      
      // Should show success message
      expect(find.text('Test data filled!'), findsOneWidget);
    });

    testWidgets('Delete functionality shows confirmation dialog', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const ProviderScope(child: MainBillListScreen()),
        ),
      );
      await tester.pumpAndSettle();
      
      // Look for dismissible widgets (bills)
      final dismissibleWidgets = find.byType(Dismissible);
      if (dismissibleWidgets.evaluate().isNotEmpty) {
        // Test swipe to delete
        await tester.drag(find.byType(Dismissible).first, const Offset(-300, 0));
        await tester.pumpAndSettle();
        
        // Should show delete confirmation dialog
        expect(find.text('Delete Bill'), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);
        expect(find.text('Delete'), findsOneWidget);
      }
    });
  });
}
