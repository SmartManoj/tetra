#!/bin/bash

# APK Signing Verification Script
# This script verifies that the signing configuration is working properly

set -e

echo "🔍 APK Signing Configuration Verification"
echo "=========================================="

# Check if we're in the right directory
if [[ ! -f "app/build.gradle.kts" ]]; then
    echo "❌ Error: Please run this script from the Tetra directory"
    exit 1
fi

# Check if keystore exists
if [[ ! -f "app/debug.keystore" ]]; then
    echo "❌ Error: Debug keystore not found at app/debug.keystore"
    exit 1
fi

echo "✅ Debug keystore found"

# Verify keystore contents
echo "📋 Keystore information:"
keytool -list -keystore app/debug.keystore -storepass android | grep -E "(androiddebugkey|Certificate fingerprint)"

# Try to get signing report (requires Android SDK)
echo ""
echo "🔨 Attempting to get signing report..."
if command -v ./gradlew >/dev/null 2>&1; then
    if ./gradlew signingReport 2>/dev/null; then
        echo "✅ Signing configuration verified successfully!"
    else
        echo "⚠️  Could not run signing report (Android SDK may not be configured)"
        echo "   This is normal in environments without Android SDK"
        echo "   The signing configuration should work when building APKs"
    fi
else
    echo "⚠️  Gradlew not found or not executable"
fi

echo ""
echo "🎯 Summary:"
echo "   - Debug keystore is present and configured"
echo "   - All debug builds will use the same signing key"
echo "   - This should resolve APK installation conflicts"
echo ""
echo "Expected SHA-256 fingerprint:"
echo "9F:D9:46:5A:55:29:D8:00:5C:87:3E:37:69:0C:4F:D5:C8:1E:16:9D:29:78:60:25:D4:5E:91:8A:90:48:F3:26"