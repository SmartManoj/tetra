# APK Signing Fix

## Problem
APK builds from GitHub Actions workflows were failing to install with error:
```
adb: failed to install: Failure [INSTALL_FAILED_UPDATE_INCOMPATIBLE: 
Existing package com.example.simple_agent_android signatures do not match newer version; ignoring!]
```

## Root Cause
Debug builds use different signing keys across different environments:
- Local development machines generate their own debug keystore
- GitHub Actions generates its own debug keystore
- Users trying to install APKs face conflicts when switching between different sources

## Solution
Created a consistent debug keystore that all environments will use:

### 1. Generated Debug Keystore
- Created `app/debug.keystore` with standard debug credentials
- Keystore details:
  - Alias: `androiddebugkey`
  - Store password: `android`
  - Key password: `android`
  - Validity: 10,000 days

### 2. Updated Build Configuration
Modified `app/build.gradle.kts` to explicitly use the debug keystore:

```kotlin
signingConfigs {
    create("debug") {
        storeFile = file("debug.keystore")
        storePassword = "android"
        keyAlias = "androiddebugkey"
        keyPassword = "android"
    }
}

buildTypes {
    debug {
        signingConfig = signingConfigs.getByName("debug")
    }
    // ... rest of build types
}
```

## Impact
- All debug APKs (local builds, CI builds, distributed APKs) will now use the same signing key
- Users can install APKs from any source without signature conflicts
- The debug keystore is safely committed to version control (standard practice for debug keys)

## Verification
To verify the signing configuration is working:
```bash
cd Tetra
./gradlew signingReport
```

The keystore fingerprint should be:
```
SHA-256: 9F:D9:46:5A:55:29:D8:00:5C:87:3E:37:69:0C:4F:D5:C8:1E:16:9D:29:78:60:25:D4:5E:91:8A:90:48:F3:26
```

## Security Note
This is a debug-only keystore and should **never** be used for release builds. Production releases should use a proper release signing configuration with securely stored keys.