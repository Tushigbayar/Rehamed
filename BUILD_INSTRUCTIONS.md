# App-ийг утасны дээр байршуулах заавар

## Сонголт 1: Web Build (Хамгийн хялбар)

### 1. Web build хийх:
```bash
flutter build web
```

### 2. Build хийгдсэн файлууд:
- `build/web/` folder дотор байна
- Энэ folder-ийг web server дээр байршуулах

### 3. Хэрхэн ашиглах:
- Web server дээр байршуулсны дараа URL-ийг утасны browser-оор нээх
- Эсвэл Firebase Hosting, Netlify, GitHub Pages дээр байршуулах

---

## Сонголт 2: Android APK Build (Утасны дээр суулгах)

### Шаардлага:
1. **Android Studio суулгах:**
   - https://developer.android.com/studio/downloads
   - Android SDK, Android SDK Platform-Tools суулгах

2. **Flutter-д Android SDK заах:**
   ```bash
   flutter config --android-sdk <ANDROID_SDK_PATH>
   ```

### APK Build хийх:

#### 1. Release APK үүсгэх:
```bash
flutter build apk --release
```

#### 2. Split APK үүсгэх (архитектур бүрт):
```bash
flutter build apk --split-per-abi
```

#### 3. Build хийгдсэн файл:
- `build/app/outputs/flutter-apk/app-release.apk`
- Энэ файлыг утасны дээр суулгах

### Хэрхэн хуваалцах:
1. **APK файлыг хуваалцах:**
   - Email, Google Drive, Dropbox, Telegram зэрэг
   - Утасны дээр download хийж суулгах

2. **Google Play Store дээр байршуулах:**
   - Google Play Console дээр бүртгэх
   - App Bundle үүсгэх: `flutter build appbundle --release`
   - Upload хийх

---

## Сонголт 3: iOS App Build (iPhone/iPad)

### Шаардлага:
- macOS computer
- Xcode суулгасан
- Apple Developer account

### Build хийх:
```bash
flutter build ios --release
```

---

## Одоогийн тохиргоо:

### App мэдээлэл:
- **Нэр:** РЕХА МЕД - Засвар үйлчилгээний систем
- **Version:** 1.0.0+1
- **Package:** com.example.my_app

### Android тохиргоо:
- Android folder байна
- AndroidManifest.xml байна
- Build.gradle.kts байна

---

## Хурдан заавар (Web):

```bash
# 1. Web build хийх
flutter build web

# 2. Build хийгдсэн folder-ийг web server дээр байршуулах
# build/web/ folder-ийг хуваалцах
```

---

## Хурдан заавар (Android APK):

```bash
# 1. Android SDK суулгах (Android Studio)
# 2. Flutter config хийх
flutter config --android-sdk <PATH>

# 3. APK build хийх
flutter build apk --release

# 4. APK файлыг хуваалцах
# build/app/outputs/flutter-apk/app-release.apk
```

---

## Зөвлөмж:

1. **Web build** - Хамгийн хялбар, хурдан
2. **Android APK** - Утасны дээр шууд суулгах
3. **App Store** - Албан ёсны байршуулалт

---

## Тэмдэглэл:

- Android SDK суугаагүй байгаа тул эхлээд Android Studio суулгах хэрэгтэй
- Web build хийхэд ямар нэгэн нэмэлт тохиргоо хэрэггүй
- APK файлыг хуваалцахдаа "Unknown sources" идэвхжүүлэх хэрэгтэй
