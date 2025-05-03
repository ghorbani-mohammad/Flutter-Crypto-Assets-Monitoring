# Crypto Monitor App

A Flutter application for monitoring cryptocurrency prices.

## Features

- Fetches cryptocurrency data from your backend API
- Displays crypto prices with 24-hour price changes
- Supports both light and dark themes
- Pull to refresh functionality

## Setup

1. Update the API endpoint:
   - Open `lib/services/api_service.dart`
   - Replace the `baseUrl` with your actual backend endpoint

2. Make sure your API response is in the expected format:
   ```json
   [
     {
       "id": "bitcoin",
       "name": "Bitcoin",
       "symbol": "BTC",
       "price": 50000.0,
       "change24h": 2.5
     },
     ...
   ]
   ```

## Building for Android

To build an APK for Android:

1. Install Flutter SDK and set it up: https://docs.flutter.dev/get-started/install
2. Connect your Android device via USB with debugging enabled
3. Run these commands:

```
flutter pub get
flutter build apk
```

4. The APK will be available at `build/app/outputs/flutter-apk/app-release.apk`
5. Install it on your device using:

```
flutter install
```

## Customization

- Update the theme colors in `lib/main.dart`
- Modify the UI layout in the widget files
- Add additional features like sorting, filtering, or favorites 