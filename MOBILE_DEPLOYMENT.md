# iOS болон Android дээр App суулгах бүрэн заавар

## 📱 Android дээр суулгах

### 1. Android Studio суулгах

#### Шаардлага:
- Windows, macOS, эсвэл Linux
- Хамгийн багадаа 8GB RAM
- 4GB хадгалах зай

#### Алхам:
1. **Android Studio татах:**
   - https://developer.android.com/studio/downloads
   - Windows: `.exe` файл татаж суулгах
   - macOS: `.dmg` файл татаж суулгах
   - Linux: `.tar.gz` файл татаж суулгах

2. **Android Studio нээх:**
   - "More Actions" → "SDK Manager"
   - "SDK Platforms" tab:
     - ✅ Android 14.0 (API 34) сонгох
     - ✅ "Show Package Details" дээр дарах
     - ✅ "Android SDK Platform 34" сонгох
   - "SDK Tools" tab:
     - ✅ "Android SDK Build-Tools" сонгох
     - ✅ "Android SDK Platform-Tools" сонгох
     - ✅ "Android SDK Command-line Tools" сонгох
     - ✅ "Android Emulator" сонгох (хэрэв тест хийх бол)
   - "Apply" дарах

3. **Flutter-д Android SDK заах:**
   ```bash
   # Android SDK path олох:
   # Windows: C:\Users\<USERNAME>\AppData\Local\Android\Sdk
   # macOS: ~/Library/Android/sdk
   # Linux: ~/Android/Sdk
   
   flutter config --android-sdk <ANDROID_SDK_PATH>
   ```

4. **Шалгах:**
   ```bash
   flutter doctor
   ```
   Android toolchain ✓ гэж харагдах ёстой

---

### 2. Android APK Build хийх

#### Release APK үүсгэх:
```bash
flutter build apk --release
```

#### APK файл байршил:
- `build/app/outputs/flutter-apk/app-release.apk`
- Хэмжээ: ~20-30 MB

#### Split APK үүсгэх (архитектур бүрт):
```bash
flutter build apk --split-per-abi
```

Энэ нь 3 файл үүсгэнэ:
- `app-armeabi-v7a-release.apk` (32-bit, ~10 MB)
- `app-arm64-v8a-release.apk` (64-bit, ~10 MB)
- `app-x86_64-release.apk` (x86, ~10 MB)

---

### 3. Android APK хуваалцах

#### Арга 1: Email, Drive, Dropbox
1. APK файлыг email, Google Drive, Dropbox дээр байршуулах
2. Утасны дээр download хийх
3. "Unknown sources" идэвхжүүлэх:
   - Settings → Security → Unknown sources
   - Эсвэл Settings → Apps → Special access → Install unknown apps
4. APK файл дээр дарах, суулгах

#### Арга 2: Telegram, WhatsApp
1. Telegram эсвэл WhatsApp-аар APK файлыг илгээх
2. Утасны дээр download хийх
3. Суулгах

#### Арга 3: QR Code
1. APK файлыг web server дээр байршуулах
2. QR Code үүсгэх (https://qr-code-generator.com)
3. Утасны камер-аар scan хийх
4. Download хийж суулгах

#### Арга 4: USB кабелаар
1. Утасны USB debugging идэвхжүүлэх
2. USB кабелаар компьютерт холбох
3. APK файлыг утасны дээр хуулах
4. Утасны дээр APK файл дээр дарах, суулгах

---

### 4. Google Play Store дээр байршуулах

#### App Bundle үүсгэх:
```bash
flutter build appbundle --release
```

#### Bundle файл:
- `build/app/outputs/bundle/release/app-release.aab`
- Хэмжээ: ~15-20 MB

#### Google Play Console:
1. **Бүртгэл:**
   - https://play.google.com/console
   - Google account-аар нэвтрэх
   - $25 төлбөр төлөх (нэг удаа)

2. **App үүсгэх:**
   - "Create app" дарах
   - App нэр: "РЕХА МЕД - Засвар үйлчилгээ"
   - Default language: Монгол хэл
   - App type: App
   - Free эсвэл Paid сонгох

3. **App мэдээлэл оруулах:**
   - Тайлбар
   - Скриншот (хэмжээ: 1080x1920)
   - Icon (512x512)
   - Category: Business

4. **Release үүсгэх:**
   - "Production" → "Create new release"
   - AAB файл upload хийх
   - Release notes оруулах
   - "Review release" дарах

5. **Content rating:**
   - Content rating form бөглөх

6. **Review хийлгэх:**
   - "Submit for review" дарах
   - 1-3 хоног хүлээх

---

## 🍎 iOS дээр суулгах

### 1. Шаардлага

#### Заавал шаардлагатай:
- ✅ **macOS computer** (MacBook, iMac, Mac mini)
- ✅ **Xcode** (App Store-аас суулгах)
- ✅ **Apple Developer account** ($99/жил)

#### iOS эмулятор дээр тест хийх:
- macOS computer
- Xcode суулгасан
- Apple Developer account хэрэггүй

---

### 2. Xcode суулгах

1. **App Store-аас Xcode татах:**
   - App Store нээх
   - "Xcode" хайх
   - "Get" эсвэл "Install" дарах
   - ~12GB хэмжээтэй, удаан татагдана

2. **Xcode нээх:**
   - Xcode → Preferences → Locations
   - Command Line Tools сонгох

3. **Flutter-д iOS заах:**
   ```bash
   flutter doctor
   ```
   iOS toolchain ✓ гэж харагдах ёстой

---

### 3. iOS Build хийх

#### iOS эмулятор дээр ажиллуулах:
```bash
# Боломжтой эмуляторуудыг харах
flutter devices

# iOS эмулятор дээр ажиллуулах
flutter run -d ios
```

#### Release build хийх:
```bash
flutter build ios --release
```

#### IPA файл үүсгэх:
1. Xcode нээх:
   ```bash
   open ios/Runner.xcworkspace
   ```

2. Xcode дээр:
   - Product → Archive
   - Archive хийгдсэний дараа "Distribute App" дарах
   - "App Store Connect" сонгох
   - "Upload" дарах

---

### 4. App Store дээр байршуулах

#### App Store Connect:
1. **Бүртгэл:**
   - https://appstoreconnect.apple.com
   - Apple Developer account-аар нэвтрэх
   - $99/жил төлбөр төлөх

2. **App үүсгэх:**
   - "My Apps" → "+" → "New App"
   - App нэр: "РЕХА МЕД - Засвар үйлчилгээ"
   - Primary language: Монгол хэл
   - Bundle ID: com.example.my_app (өөрчлөх хэрэгтэй)
   - SKU: my-app-001

3. **App мэдээлэл оруулах:**
   - Тайлбар
   - Скриншот (iPhone, iPad)
   - Icon (1024x1024)
   - Category: Business

4. **Build upload хийх:**
   - Xcode-аас Archive хийсний дараа
   - App Store Connect дээр автоматаар харагдана
   - Build сонгох

5. **Review хийлгэх:**
   - "Submit for Review" дарах
   - 1-7 хоног хүлээх

---

### 5. TestFlight (Beta тест)

#### TestFlight ашиглах:
1. App Store Connect дээр "TestFlight" tab нээх
2. Beta testers нэмэх
3. Build upload хийх
4. Testers-д урилга илгээх
5. TestFlight app-аар тест хийх

---

## 🔐 App Signing (Release build-д хэрэгтэй)

### Android Signing:

#### 1. Keystore үүсгэх:
```bash
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

#### 2. key.properties файл үүсгэх (android/ folder дотор):
```properties
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=../upload-keystore.jks
```

#### 3. android/app/build.gradle.kts засах:
```kotlin
signingConfigs {
    create("release") {
        val keystorePropertiesFile = rootProject.file("key.properties")
        val keystoreProperties = Properties()
        keystoreProperties.load(FileInputStream(keystorePropertiesFile))
        
        keyAlias = keystoreProperties["keyAlias"] as String
        keyPassword = keystoreProperties["keyPassword"] as String
        storeFile = file(keystoreProperties["storeFile"] as String)
        storePassword = keystoreProperties["storePassword"] as String
    }
}

buildTypes {
    release {
        signingConfig = signingConfigs.getByName("release")
    }
}
```

### iOS Signing:

#### Xcode дээр:
1. Runner project сонгох
2. "Signing & Capabilities" tab
3. "Automatically manage signing" сонгох
4. Team сонгох (Apple Developer account)

---

## 📋 App мэдээлэл засах

### Android:

#### android/app/src/main/AndroidManifest.xml:
```xml
<application
    android:label="РЕХА МЕД - Засвар үйлчилгээ"
    ...
```

#### android/app/build.gradle.kts:
```kotlin
applicationId = "com.rehamed.maintenance"  // Package name өөрчлөх
versionCode = 1
versionName = "1.0.0"
```

### iOS:

#### ios/Runner/Info.plist:
```xml
<key>CFBundleName</key>
<string>РЕХА МЕД - Засвар үйлчилгээ</string>
```

#### ios/Runner.xcodeproj/project.pbxproj:
```
PRODUCT_BUNDLE_IDENTIFIER = com.rehamed.maintenance;
```

---

## 🚀 Хурдан командууд

### Android:
```bash
# APK build
flutter build apk --release

# App Bundle build
flutter build appbundle --release

# Test хийх
flutter run -d android
```

### iOS:
```bash
# iOS build
flutter build ios --release

# Test хийх
flutter run -d ios

# Xcode нээх
open ios/Runner.xcworkspace
```

---

## 📊 Харьцуулалт

| Онцлог | Android | iOS |
|--------|---------|-----|
| **Build хийх** | Windows/macOS/Linux | Зөвхөн macOS |
| **Developer account** | $25 (нэг удаа) | $99/жил |
| **APK/IPA хуваалцах** | Тийм (APK) | Үгүй (IPA хуваалцахгүй) |
| **Store review** | 1-3 хоног | 1-7 хоног |
| **Test хийх** | APK хуваалцах | TestFlight |

---

## ⚠️ Тэмдэглэл

1. **Android:**
   - APK файлыг шууд хуваалцаж болно
   - Google Play Store-д байршуулах нь сонголттой

2. **iOS:**
   - IPA файлыг хуваалцахгүй (App Store эсвэл TestFlight)
   - macOS computer заавал хэрэгтэй
   - Apple Developer account заавал хэрэгтэй

3. **Web:**
   - Хамгийн хялбар арга
   - Бүх төхөөрөмж дээр ажиллана
   - Store review хэрэггүй

---

## 🎯 Зөвлөмж

1. **Эхлээд Android APK build хийх** - Хамгийн хялбар
2. **Web build хийх** - Бүх төхөөрөмж дээр ажиллана
3. **iOS build хийх** - macOS computer шаардлагатай

---

## 📞 Тусламж

- Flutter documentation: https://docs.flutter.dev
- Android documentation: https://developer.android.com
- iOS documentation: https://developer.apple.com
