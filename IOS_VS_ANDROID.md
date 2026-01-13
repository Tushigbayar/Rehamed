# APK vs IPA - iOS болон Android файлууд

## ❌ APK файл iOS дээр суулгах боломжгүй

**APK (Android Package Kit)** файл нь:
- ✅ Зөвхөн **Android** үйлдлийн систем дээр ажиллана
- ❌ **iOS** (iPhone, iPad) дээр ажиллахгүй
- ❌ **macOS** дээр ажиллахгүй

**Шалтгаан:**
- APK файл нь Android-ийн тусгай формат
- iOS нь өөр формат (IPA) ашигладаг
- iOS нь зөвхөн App Store эсвэл TestFlight-аас app суулгахыг зөвшөөрдөг

---

## ✅ iOS дээр суулгахын тулд

### Шаардлага:
1. **macOS computer** (MacBook, iMac, Mac mini)
2. **Xcode** (App Store-аас суулгах)
3. **Apple Developer account** ($99/жил)

### IPA файл үүсгэх:
```bash
# macOS computer дээр
flutter build ios --release
```

### iOS дээр суулгах арга:
1. **App Store** (албан ёсны)
2. **TestFlight** (beta тест)
3. **Xcode** (development)

---

## 📱 Төхөөрөмж бүрт зориулсан файл

| Төхөөрөмж | Файл формат | Build командууд |
|-----------|-------------|-----------------|
| **Android** | APK | `flutter build apk --release` |
| **Android** | AAB (Play Store) | `flutter build appbundle --release` |
| **iOS** | IPA | `flutter build ios --release` (macOS only) |
| **Web** | HTML/JS | `flutter build web` |
| **Windows** | EXE | `flutter build windows` |
| **macOS** | APP | `flutter build macos` |
| **Linux** | DEB/RPM | `flutter build linux` |

---

## 🔄 Хэрэв iOS хэрэгтэй бол

### Сонголт 1: macOS computer ашиглах
1. macOS computer олох (MacBook, iMac)
2. Xcode суулгах
3. Apple Developer account ($99/жил)
4. IPA файл үүсгэх
5. App Store эсвэл TestFlight дээр байршуулах

### Сонголт 2: Cloud build service ашиглах
- **Codemagic** (https://codemagic.io)
- **Bitrise** (https://bitrise.io)
- **AppCircle** (https://appcircle.io)

Эдгээр нь macOS computer шаардлагагүй, cloud дээр build хийх боломжтой.

### Сонголт 3: Web app ашиглах
- Web build хийх (`flutter build web`)
- Утасны browser-оор нээх
- iOS болон Android дээр ажиллана

---

## 🌐 Web App (iOS болон Android дээр ажиллана)

### Web build хийх:
```bash
flutter build web
```

### Хэрхэн ашиглах:
1. Web server дээр байршуулах
2. Утасны browser-оор нээх (Safari, Chrome)
3. "Add to Home Screen" хийх
4. App шиг ажиллана

### Давуу тал:
- ✅ iOS болон Android дээр ажиллана
- ✅ Store review хэрэггүй
- ✅ macOS computer шаардлагагүй
- ✅ Apple Developer account шаардлагагүй

---

## 📊 Харьцуулалт

| Онцлог | APK (Android) | IPA (iOS) | Web App |
|--------|---------------|-----------|---------|
| **Android дээр** | ✅ | ❌ | ✅ |
| **iOS дээр** | ❌ | ✅ | ✅ |
| **macOS шаардлага** | ❌ | ✅ | ❌ |
| **Developer account** | $25 (нэг удаа) | $99/жил | Үгүй |
| **Store review** | 1-3 хоног | 1-7 хоног | Үгүй |
| **Хуваалцах** | Тийм (APK) | Үгүй (App Store only) | Тийм (URL) |

---

## 💡 Зөвлөмж

### Хэрэв зөвхөн Android хэрэгтэй:
- ✅ APK файл ашиглах (одоо бэлэн)
- ✅ Google Play Store дээр байршуулах (сонголттой)

### Хэрэв iOS хэрэгтэй:
- ✅ macOS computer олох
- ✅ Xcode суулгах
- ✅ Apple Developer account ($99/жил)
- ✅ IPA файл үүсгэх

### Хэрэв iOS болон Android хоёулаа хэрэгтэй:
- ✅ Web app ашиглах (хамгийн хялбар)
- ✅ Эсвэл тус бүрт build хийх

---

## 🎯 Одоогийн байдал

### Бэлэн байгаа:
- ✅ **Android APK** - `app-release.apk` (47.6 MB)
- ✅ **Web build** - `build/web/` folder

### Хэрэгтэй:
- ❌ **iOS IPA** - macOS computer шаардлагатай

---

## 📞 Тусламж

Хэрэв iOS app хэрэгтэй бол:
1. macOS computer олох
2. `MOBILE_DEPLOYMENT.md` файлын iOS хэсгийг дагах
3. Эсвэл Web app ашиглах (iOS болон Android дээр ажиллана)
