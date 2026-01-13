# Android APK Build хийх заавар

## 1. Android Studio суулгах

1. **Android Studio татах:**
   - https://developer.android.com/studio/downloads
   - Windows-д зориулсан .exe файл татаж суулгах

2. **Android Studio нээх:**
   - "More Actions" → "SDK Manager"
   - "SDK Platforms" tab дээр:
     - Android 14.0 (API 34) сонгох
     - "Show Package Details" дээр дарах
     - "Android SDK Platform 34" сонгох
   - "SDK Tools" tab дээр:
     - "Android SDK Build-Tools" сонгох
     - "Android SDK Platform-Tools" сонгох
     - "Android SDK Command-line Tools" сонгох
   - "Apply" дарах

3. **Flutter-д Android SDK заах:**
   ```bash
   # Android SDK path олох (ихэвчлэн):
   # C:\Users\<USERNAME>\AppData\Local\Android\Sdk
   
   flutter config --android-sdk C:\Users\<USERNAME>\AppData\Local\Android\Sdk
   ```

4. **Шалгах:**
   ```bash
   flutter doctor
   ```
   Android toolchain ✓ гэж харагдах ёстой

---

## 2. APK Build хийх

### Release APK үүсгэх:
```bash
flutter build apk --release
```

### APK файл байршил:
- `build/app/outputs/flutter-apk/app-release.apk`

### Split APK үүсгэх (архитектур бүрт):
```bash
flutter build apk --split-per-abi
```

Энэ нь 3 файл үүсгэнэ:
- `app-armeabi-v7a-release.apk` (32-bit)
- `app-arm64-v8a-release.apk` (64-bit)
- `app-x86_64-release.apk` (x86)

---

## 3. APK файлыг хуваалцах

### Арга 1: Email, Drive, Dropbox
1. APK файлыг email, Google Drive, Dropbox дээр байршуулах
2. Утасны дээр download хийх
3. "Unknown sources" идэвхжүүлэх (Settings → Security)
4. APK файл дээр дарах, суулгах

### Арга 2: Telegram, WhatsApp
1. Telegram эсвэл WhatsApp-аар APK файлыг илгээх
2. Утасны дээр download хийх
3. Суулгах

### Арга 3: QR Code
1. APK файлыг web server дээр байршуулах
2. QR Code үүсгэх (https://qr-code-generator.com)
3. Утасны камер-аар scan хийх
4. Download хийж суулгах

---

## 4. Google Play Store дээр байршуулах

### App Bundle үүсгэх:
```bash
flutter build appbundle --release
```

### Bundle файл:
- `build/app/outputs/bundle/release/app-release.aab`

### Google Play Console:
1. https://play.google.com/console дээр бүртгэх
2. "Create app" дарах
3. App мэдээлэл оруулах
4. "Production" → "Create new release"
5. AAB файл upload хийх
6. Review хийлгэх

---

## 5. App мэдээлэл засах

### AndroidManifest.xml:
```xml
<application
    android:label="РЕХА МЕД - Засвар үйлчилгээ"
    ...
```

### pubspec.yaml:
```yaml
name: my_app
version: 1.0.0+1
```

### build.gradle.kts:
```kotlin
applicationId = "com.example.my_app"  // Энэ нь package name
```

---

## 6. Signing (Release build-д хэрэгтэй)

### Keystore үүсгэх:
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

### key.properties файл үүсгэх:
```
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=<path-to-keystore>
```

### build.gradle.kts дээр нэмэх:
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
```

---

## Тэмдэглэл:

- **Debug APK** - Зөвхөн тест хийхэд
- **Release APK** - Хуваалцах, байршуулах
- **App Bundle** - Google Play Store-д байршуулах

---

## Хурдан командууд:

```bash
# Web build
flutter build web

# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS (macOS дээр)
flutter build ios --release
```
