# Android WorkManager Startup Crash

## Symptom

- App package: `com.example.due`
- Reproduced on BlueStacks device `127.0.0.1:5555`.
- App crashed before Flutter UI started.
- Captured log file: `.codex-temp/due-logcat.txt` (temporary, not committed).

Key logcat signature:

```text
FATAL EXCEPTION: main
Process: com.example.due
java.lang.RuntimeException: Unable to get provider androidx.startup.InitializationProvider
androidx.datastore.preferences.protobuf.c1: java.lang.RuntimeException: Failed to create an instance of androidx.work.impl.WorkDatabase
Caused by: java.lang.RuntimeException: Failed to create an instance of androidx.work.impl.WorkDatabase
at androidx.work.WorkManagerInitializer
```

## Root Cause

`home_widget` brings in AndroidX WorkManager. WorkManager was auto-initialized by AndroidX Startup before Flutter started, and its internal `WorkDatabase` creation crashed on the emulator/device.

This is a native Android startup crash, not a Dart, Hive, Riverpod, or Flutter page crash.

## Fix

File changed:

- `android/app/src/main/AndroidManifest.xml`

The manifest now removes only the WorkManager auto-initializer metadata from `androidx.startup.InitializationProvider`:

```xml
<provider
    android:name="androidx.startup.InitializationProvider"
    android:authorities="${applicationId}.androidx-startup"
    tools:node="merge">
    <meta-data
        android:name="androidx.work.WorkManagerInitializer"
        tools:node="remove" />
</provider>
```

This keeps AndroidX Startup available for other initializers and only prevents WorkManager from starting before the app needs it.

## Verification

Commands used:

```powershell
flutter build apk
adb -s 127.0.0.1:5555 install -r build\app\outputs\flutter-apk\app-release.apk
adb -s 127.0.0.1:5555 logcat -c
adb -s 127.0.0.1:5555 shell am start -W -n com.example.due/.MainActivity
adb -s 127.0.0.1:5555 shell pidof com.example.due
adb -s 127.0.0.1:5555 logcat -d -t 800
flutter test
```

Observed result:

- APK build succeeded.
- Install succeeded.
- Launch returned `Status: ok`.
- Process stayed alive: `pidof com.example.due` returned a PID.
- No `FATAL EXCEPTION`, `WorkManagerInitializer`, or `WorkDatabase` crash appeared in the fresh startup log.
- `flutter test` passed 16/16.

## Future Debug Shortcut

If this class of crash returns, start with:

```powershell
adb devices
adb -s 127.0.0.1:5555 logcat -c
adb -s 127.0.0.1:5555 shell am start -W -n com.example.due/.MainActivity
adb -s 127.0.0.1:5555 logcat -d -t 1000 | Select-String -Pattern 'FATAL EXCEPTION|AndroidRuntime|WorkManagerInitializer|WorkDatabase|InitializationProvider|com.example.due'
```

If the same signature appears, check whether `androidx.work.WorkManagerInitializer` removal is still present in `AndroidManifest.xml` and whether a dependency upgrade changed the merged manifest.

## Risk

- The app currently does not use explicit WorkManager jobs.
- If a future feature needs WorkManager scheduling, initialize/configure WorkManager intentionally instead of relying on startup auto-initialization.
