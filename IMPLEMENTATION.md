# Default Utility Rates Implementation

This document describes the implementation of default utility rates for properties, addressing issue #11.

## What was implemented

### 1. Extended Property Entity
- Added 7 new optional fields to the `Property` class:
  - `defaultElectricityRate` - flat rate for electricity (R/kWh)
  - `defaultWaterRate0to6` - water rate for 0-6kl tier
  - `defaultWaterRate7to15` - water rate for 7-15kl tier  
  - `defaultWaterRate16to30` - water rate for 16-30kl tier
  - `defaultSanitationRate0to6` - sanitation rate for 0-6kl tier
  - `defaultSanitationRate7to15` - sanitation rate for 7-15kl tier
  - `defaultSanitationRate16to30` - sanitation rate for 16-30kl tier

### 2. Updated Property Details Screen
- Added 3 new card sections after the property information:
  - **Default Electricity Rate** - single rate input field
  - **Default Water Rates** - three tier rate inputs (0-6kl, 7-15kl, 16-30kl)
  - **Default Sanitation Rates** - three tier rate inputs (0-6kl, 7-15kl, 16-30kl)
- All rate fields are optional with helper text
- Proper validation for numeric inputs
- Maintains existing property name and address functionality

### 3. Updated New Bill Screen
- New bills automatically load property defaults when created
- Added "Load Defaults" button in app bar for new bills
- Helper text indicates when defaults are loaded from property
- Editing existing bills is unaffected (no auto-loading of defaults)
- Users can still override rates for specific bills

## How to test

### Manual Testing Steps

1. **Set up property defaults:**
   - Navigate to Property Details screen
   - Enter property name and address
   - Fill in default rates in the new sections:
     - Electricity: e.g., 3.40
     - Water rates: e.g., 20.80, 34.20, 48.50
     - Sanitation rates: e.g., 25.50, 20.50, 29.80
   - Save the property

2. **Create new bill with defaults:**
   - Navigate to New Bill screen
   - Verify that tariff fields are pre-filled with the property defaults
   - Test the "Load Defaults" button to reload defaults if needed
   - Create a bill normally

3. **Test backward compatibility:**
   - Existing properties without defaults should continue working
   - Property details screen should show empty rate fields for existing properties
   - New bills should have empty rate fields if no defaults are set

### Expected Behavior

- **New users:** Can set defaults once and have them auto-populated for all future bills
- **Existing users:** Existing data continues working unchanged; can optionally add defaults
- **Flexibility:** Users can still override defaults for specific bills when needed

## Technical Details

- **Storage:** All changes use existing SharedPreferences JSON storage
- **Validation:** Proper numeric validation with 2 decimal places
- **UI/UX:** Consistent with existing design patterns
- **Performance:** Minimal impact - only loads defaults when creating new bills
- **Backward compatibility:** All new fields are optional and nullable

## Files Modified

1. `lib/entities/property.dart` - Extended with default rate fields
2. `lib/screens/property_details_screen.dart` - Added rate input sections
3. `lib/screens/new_bill_screen.dart` - Added default loading functionality

## Files Added

1. `test/property_entity_test.dart` - Unit tests for Property entity
2. `example/default_rates_demo.dart` - Demo showing functionality

The implementation maintains the principle of minimal changes while providing the requested functionality.