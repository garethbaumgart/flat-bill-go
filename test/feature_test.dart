import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flat_bill_go/main.dart';
import 'package:flat_bill_go/screens/main_bill_list_screen.dart';
import 'package:flat_bill_go/screens/new_bill_screen.dart';
import 'package:flat_bill_go/screens/bill_summary_screen.dart';
import 'package:flat_bill_go/entities/bill.dart';
import 'package:flat_bill_go/entities/meter_reading.dart';
import 'package:flat_bill_go/entities/tariff.dart';
import 'package:flat_bill_go/entities/tariff_step.dart';

void main() {
  group('Flat Bill Go App Tests', () {
    testWidgets('App launches successfully', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: MyApp()));
      await tester.pump();
      
      // Check for basic app structure
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('Main screen shows basic structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const ProviderScope(child: MainBillListScreen()),
        ),
      );
      await tester.pump();
      
      // Should show basic app structure
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('New Bill screen shows basic structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const ProviderScope(child: NewBillScreen()),
        ),
      );
      await tester.pump();
      
      // Check for basic structure elements
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(Form), findsOneWidget);
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
      await tester.pump();
      
      // Check for basic structure elements
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Bill Summary'), findsOneWidget);
    });

    testWidgets('Debug button exists in New Bill screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const ProviderScope(child: NewBillScreen()),
        ),
      );
      await tester.pump();
      
      // Find debug button
      final debugButton = find.byIcon(Icons.bug_report);
      expect(debugButton, findsOneWidget);
    });

    testWidgets('Main screen has basic structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const ProviderScope(child: MainBillListScreen()),
        ),
      );
      await tester.pump();
      
      // Check for basic structure
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });
  });
}
