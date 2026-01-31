# DreamShelf - Production Setup Guide

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Android Configuration](#android-configuration)
3. [iOS Configuration](#ios-configuration)
4. [AdMob Setup](#admob-setup)
5. [In-App Purchases Setup](#in-app-purchases-setup)
6. [Release Build](#release-build)
7. [Testing](#testing)

---

## Prerequisites

### Development Environment
- Flutter 3.10.0 or higher
- Dart SDK 3.0.0 or higher
- Android Studio / Xcode
- Valid Apple Developer Account (for iOS)
- Google Play Developer Account (for Android)

### Required Accounts
- Google AdMob Account
- Google Cloud Console (for Google Books API)
- Apple App Store Connect
- Google Play Console

---

## Android Configuration

### 1. Update Application ID
Edit `android/app/build.gradle`:
```gradle
android {
    defaultConfig {
        applicationId "com.yourcompany.dreamshelf"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
    }
}
```

### 2. Configure Signing
Create `android/key.properties`:
```properties
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=<path-to-keystore>/upload-keystore.jks
```

Update `android/app/build.gradle`:
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
}
```

### 3. Enable ProGuard
Ensure `proguard-rules.pro` is in `android/app/` directory.

### 4. Update AndroidManifest
Add required permissions in `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="com.android.vending.BILLING"/>
```

Add AdMob App ID in `<application>` tag:
```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX"/>
```

---

## iOS Configuration

### 1. Update Bundle ID
In Xcode, update Bundle Identifier to: `com.yourcompany.dreamshelf`

### 2. Configure Info.plist
Add to `ios/Runner/Info.plist`:
```xml
<!-- Camera Permission -->
<key>NSCameraUsageDescription</key>
<string>DreamShelf needs camera access to scan book barcodes.</string>

<!-- AdMob App ID -->
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX</string>

<!-- SKAdNetwork for AdMob -->
<key>SKAdNetworkItems</key>
<array>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>cstr6suwn9.skadnetwork</string>
    </dict>
    <!-- Add more SKAdNetwork identifiers as needed -->
</array>

<!-- App Transport Security -->
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

### 3. Configure App Store Connect
- Create App Record
- Configure In-App Purchases
- Set up App Privacy details

---

## AdMob Setup

### 1. Create AdMob Account
1. Go to https://admob.google.com
2. Create your app
3. Note your App ID

### 2. Create Ad Units
Create these ad units in AdMob:
- **Banner Ad**: For home screen and book details
- **Interstitial Ad**: For between-screen transitions
- **Rewarded Video Ad**: For temporary premium unlock

### 3. Update Ad IDs
Replace test IDs in `lib/core/constants/app_constants.dart`:
```dart
class AdConstants {
  // Android
  static const String androidBannerId = 'ca-app-pub-YOUR_ID/BANNER_ID';
  static const String androidInterstitialId = 'ca-app-pub-YOUR_ID/INTERSTITIAL_ID';
  static const String androidRewardedId = 'ca-app-pub-YOUR_ID/REWARDED_ID';
  
  // iOS
  static const String iosBannerId = 'ca-app-pub-YOUR_ID/BANNER_ID';
  static const String iosInterstitialId = 'ca-app-pub-YOUR_ID/INTERSTITIAL_ID';
  static const String iosRewardedId = 'ca-app-pub-YOUR_ID/REWARDED_ID';
}
```

---

## In-App Purchases Setup

### Google Play Console
1. Go to Play Console > Your App > Monetize > Products
2. Create a new managed product:
   - Product ID: `dreamshelf_premium`
   - Price: $3.99
   - Title: DreamShelf Premium
   - Description: Unlock unlimited books, ad-free experience, and premium themes

### App Store Connect
1. Go to App Store Connect > Your App > Features > In-App Purchases
2. Create a Non-Consumable:
   - Reference Name: DreamShelf Premium
   - Product ID: `dreamshelf_premium`
   - Price: Tier 4 ($3.99)

### Update Product ID
Ensure the product ID in `lib/core/constants/app_constants.dart` matches:
```dart
class PurchaseConstants {
  static const String premiumOneTimeId = 'dreamshelf_premium';
}
```

---

## Release Build

### Android
```bash
# Clean and get dependencies
flutter clean
flutter pub get

# Build release APK
flutter build apk --release

# Build App Bundle for Play Store
flutter build appbundle --release
```

Output locations:
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- AAB: `build/app/outputs/bundle/release/app-release.aab`

### iOS
```bash
# Build for release
flutter build ios --release

# Open Xcode for archive and upload
open ios/Runner.xcworkspace
```

In Xcode:
1. Select "Any iOS Device" as target
2. Product > Archive
3. Distribute App > App Store Connect

---

## Testing

### Test AdMob
Always use test ad IDs during development:
```dart
static const String testBannerId = 'ca-app-pub-3940256099942544/6300978111';
static const String testInterstitialId = 'ca-app-pub-3940256099942544/1033173712';
static const String testRewardedId = 'ca-app-pub-3940256099942544/5224354917';
```

### Test In-App Purchases
1. **Android**: Add test accounts in Play Console
2. **iOS**: Create Sandbox test accounts in App Store Connect

### Testing Checklist
- [ ] All screens render correctly
- [ ] Book scanning works
- [ ] Google Books API returns results
- [ ] Goals can be created and tracked
- [ ] Statistics display correctly
- [ ] Premium purchase flow works
- [ ] Ads display for free users
- [ ] Ads hidden for premium users
- [ ] Data persists after app restart
- [ ] Dark mode works
- [ ] Onboarding shows on first launch only

---

## Privacy Policy

Create a privacy policy covering:
1. Data collection (local storage only)
2. Third-party services (AdMob, Google Books API)
3. Camera usage
4. In-app purchases
5. User rights

Host the privacy policy at a public URL and link it in:
- App Store listing
- Play Store listing
- Settings screen

---

## Support

For technical support during production deployment:
- Review Flutter documentation: https://docs.flutter.dev
- AdMob implementation guide: https://developers.google.com/admob
- In-app purchases guide: https://pub.dev/packages/in_app_purchase
