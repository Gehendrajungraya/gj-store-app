# GJ Store App

Flutter mobile/web client for the GJ Plugin Store at `https://gehendrajung.com.np`.

## Included
- Android project files (so this is a real Flutter project, not only `lib/` source)
- Web project files
- Home, Store, Orders and Account screens
- API service for products, banners, categories, login, orders and notifications
- Search and category filtering
- WhatsApp support button
- Local auth token storage

## Run
1. Install Flutter SDK.
2. Open this folder (`gj_store_app`).
3. Run `flutter pub get`.
4. Run `flutter run` for a connected Android device/emulator.
5. Build APK with `flutter build apk --release`.

### Important
The WordPress plugin API must expose the endpoints used in `lib/services/api.dart`. If your plugin uses different endpoint names or response fields, update that file only; the UI does not need to be rewritten.
