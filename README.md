# Utility Bill Generator App

## Overview
This app is designed to simplify the process of generating monthly utility bills for a single residential property, such as a flat or apartment. It is intended for landlords or property managers who need to calculate and view utility costs (electricity, water, sanitation) for one property. The app is targeted at South Africa, using South African Rands (ZAR) as the currency and a static, hardcoded 15% VAT rate. The app will be available on desktop (macOS, Windows, Linux) and mobile (iOS, Android) platforms using Flutter.

The app allows users to enter meter readings and tariff rates for electricity, water, and sanitation, automatically calculates totals (including VAT), and generates a professional bill summary for on-screen viewing. All data is stored locally on the device—no sign-up, login, or cloud storage is required for the MVP.

---

## Example Bill (as generated in Excel)

| Utility      | Opening | Closing | Units Used | Tariff Details                                   | Subtotal (ZAR) |
|--------------|---------|---------|------------|--------------------------------------------------|----------------|
| Electricity  | 12345   | 12456   | 111        | 111 x R3.2054/kWh                                | R355.80        |
| Water        | 200     | 208     | 8          | 6 x R19.75 + 2 x R32.55                          | R151.10        |
| Sanitation   | 200     | 208     | 8          | 6 x R24.42 + 2 x R19.54                          | R172.36        |
| **Subtotal** |         |         |            |                                                  | **R679.26**    |
| VAT (15%)    |         |         |            |                                                  | R101.89        |
| **Total**    |         |         |            |                                                  | **R781.15**    |

*Note: Tariff details and calculations are for illustration. Actual values will depend on user input and current tariffs.*

---

## MVP Features
- **Single Property:** Manage one property only (no property list or sharing).
- **Local Storage:** All data is stored locally on the device (no cloud, no sync).
- **Meter Readings Input:** Enter opening and closing readings for electricity, water, and sanitation.
- **Tariff Entry:** Enter tariff rates for each bill (fixed and sliding scale).
- **Automatic Calculation:** Calculate units used, apply tariffs (including sliding scale), calculate VAT (static 15%), and show totals in ZAR.
- **Bill Summary Display:** View a detailed summary of the bill, similar to the provided Excel example.

*Note: The MVP is designed for South Africa, using Rands (ZAR) and a hardcoded 15% VAT rate.*

---

## MVP Feature/User Story Breakdown

1. **Property and Bill Management**
   - 1.1. Add/Edit Property Details: As a user, I can enter the name and details of my property (single property only).
   - 1.2. Start New Bill: As a user, I can start a new bill for my property by selecting a billing period.
   - 1.3. Enter Meter Readings: As a user, I can enter opening and closing readings for electricity, water, and sanitation.
   - 1.4. Enter Tariffs: As a user, I can enter tariff rates for the bill (fixed and sliding scale).
   - 1.5. Calculate Bill: As a user, I can see the calculated totals (including VAT) for the bill.
   - 1.6. View Bill Summary: As a user, I can view a summary of the bill, similar to the Excel example.

---

## Post-MVP Features
- **Export/Download as PDF:** Export the bill summary as a PDF for download or sharing.
- **User Authentication:** Add user accounts and authentication for secure access and sharing.
- **Cloud Storage/Sync:** Store bills and data in the cloud for backup and multi-device access.
- **Multiple Properties:** Manage bills for multiple properties or tenants.
- **Property Sharing:** Share a property with other users for collaboration.
- **Tariff Presets:** Save and reuse commonly used tariff rates.
- **Bill History:** View and manage past bills.
- **Advanced User Roles:** Different permissions for owners, managers, and viewers.

---

## Getting Started
Coming soon...