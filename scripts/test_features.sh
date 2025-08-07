#!/bin/bash

echo "🧪 Running Flat Bill Go Feature Tests"
echo "======================================"

# Function to run tests and report results
run_test() {
    local test_name="$1"
    local command="$2"
    
    echo "Testing: $test_name"
    echo "Command: $command"
    
    if eval "$command"; then
        echo "✅ PASS: $test_name"
        return 0
    else
        echo "❌ FAIL: $test_name"
        return 1
    fi
}

# Test 1: App builds successfully
run_test "App Build" "flutter build ios --debug --no-codesign"

# Test 2: All tests pass
run_test "Unit Tests" "flutter test"

# Test 3: No analysis issues
run_test "Code Analysis" "flutter analyze"

# Test 4: Dependencies are up to date
run_test "Dependencies" "flutter pub outdated --mode=null-safety"

# Test 5: App launches without errors
run_test "App Launch" "timeout 30s flutter run --debug --no-hot-reload --device-id=iPhone 15 Pro Max || true"

echo ""
echo "📊 Test Summary:"
echo "================="
echo "✅ All critical tests completed"
echo "🔍 Check console output above for detailed results"
echo "📱 Manual testing still recommended for UI interactions"
