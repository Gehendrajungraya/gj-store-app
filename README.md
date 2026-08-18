# GJ Store App

Flutter mobile client for the GJ Plugin Store WordPress API.

## Current architecture
- Home: banners, categories, products
- Store: search and product grid
- Product details
- Cart/Buy UI foundation
- Account/login foundation
- Orders/licenses/downloads navigation foundation
- Notifications API screen
- Shared preferences token storage
- Central API service
- GitHub Actions release APK build
- Workflow regenerates missing Flutter/Android wrapper files and patches AGP/Kotlin versions.

## API
Default:
`https://gehendrajung.com.np/wp-json/gjps/v1`

Before production, verify the installed GJ Plugin Store API response/request schema for:
auth, checkout, payment submission, orders, licenses, downloads, notifications and wishlist.

## GitHub APK
Push to `main` or use Actions → Build GJ Store APK → Run workflow.
The workflow produces `GJ-Store-App-APK`.

## Local
`flutter pub get`
`flutter run`
`flutter build apk --release`
