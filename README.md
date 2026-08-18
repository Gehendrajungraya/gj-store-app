# GJ Store Flutter App

Android-first Flutter application for the GJ Plugin Store.

## GitHub APK build

1. Push the complete project to the repository root.
2. Open **Actions**.
3. Select **Build GJ Store APK**.
4. Click **Run workflow**.
5. When the run succeeds, download **GJ-Store-App-release** from Artifacts.

The workflow automatically supplies missing Android Gradle wrapper/platform files when needed and uses:
- Flutter 3.35.0
- Android Gradle Plugin 8.9.1
- Kotlin 2.1.0
- Gradle 8.11.1
- Java 17

## Local build

```bash
flutter pub get
flutter build apk --release
```
