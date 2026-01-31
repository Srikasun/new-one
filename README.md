# DreamShelf

A beautiful book tracking app built with Flutter.

## Features

- 📚 Track your reading progress
- 🎯 Set and achieve reading goals
- 📊 View reading statistics
- 📱 Scan ISBN barcodes to add books
- 🌙 Light and dark theme support
- 💰 Premium features with in-app purchases
- 📈 Ad-supported with optional ad removal

## Architecture

This project follows clean architecture principles:

```
lib/
├── core/                 # Shared utilities, constants, themes
│   ├── constants/       # App-wide constants
│   ├── themes/          # Theme configuration
│   ├── utils/           # Utility functions
│   └── errors/          # Error handling
├── data/                 # Data layer
│   ├── models/          # Data models with Hive adapters
│   ├── data_sources/    # Local and remote data sources
│   └── repositories/    # Repository implementations
├── domain/               # Domain layer
│   ├── entities/        # Business entities
│   └── usecases/        # Business logic
├── presentation/         # Presentation layer
│   ├── bloc/            # BLoC state management
│   ├── screens/         # App screens
│   ├── widgets/         # Reusable widgets
│   └── router/          # Navigation
└── main.dart            # App entry point
```

## Tech Stack

- **State Management**: flutter_bloc
- **Local Database**: Hive
- **Monetization**: Google Mobile Ads, In-App Purchase
- **Barcode Scanner**: mobile_scanner
- **HTTP Client**: http
- **Image Caching**: cached_network_image
- **Charts**: fl_chart
- **Routing**: go_router

## Getting Started

### Prerequisites

- Flutter SDK 3.10+
- Dart SDK 3.0+
- Android Studio / Xcode

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Generate Hive adapters (if needed):
   ```bash
   flutter packages pub run build_runner build
   ```
4. Run the app:
   ```bash
   flutter run
   ```

## Configuration

### API Keys

Update the following files with your API keys:
- `lib/core/constants/app_constants.dart`:
  - Google Books API key
  - Ad unit IDs

### Ad Configuration

For production, replace test ad unit IDs in `lib/core/constants/app_constants.dart` with your actual ad unit IDs from AdMob.

### In-App Purchases

Configure your products in App Store Connect and Google Play Console, then update the product IDs in `lib/core/constants/app_constants.dart`.

## Minimum Requirements

- Android SDK 21 (Android 5.0)
- iOS 12.0

## License

This project is proprietary software.
