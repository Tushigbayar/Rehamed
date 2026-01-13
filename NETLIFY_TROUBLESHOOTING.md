# Netlify Deployment Асуудлыг Шийдэх Заавар

GitHub руу push хийсэн ч Netlify дээр өөрчлөлт харагдахгүй байвал дараах алхмуудыг дагана уу:

## 1. Netlify Dashboard дээр шалгах

### Build статус шалгах
1. [Netlify Dashboard](https://app.netlify.com) руу нэвтрэх
2. Таны сайтыг сонгох
3. **Deploys** таб руу орох
4. Хамгийн сүүлийн deploy-ийн статусыг шалгах:
   - ✅ **Published** - Амжилттай
   - ⚠️ **Building** - Одоогоор build хийж байна
   - ❌ **Failed** - Амжилтгүй болсон

### Build лог шалгах
- Deploy дээр дараад **Deploy log**-ийг нээх
- Алдааны мэдээлэл байгаа эсэхийг шалгах

## 2. Build амжилтгүй болсон тохиолдолд

### Алдааны төрлүүд:

#### A. Flutter суулгах асуудал
```
Error: Flutter not found
```
**Шийдэл:**
- `netlify.toml` дээр Flutter version зөв эсэхийг шалгах
- Build command-ийг шалгах

#### B. Dependencies асуудал
```
Error: pub get failed
```
**Шийдэл:**
- `pubspec.yaml` дээр dependencies зөв эсэхийг шалгах
- `flutter pub get` командыг орон нутгийн дээр ажиллуулж шалгах

#### C. Build асуудал
```
Error: flutter build web failed
```
**Шийдэл:**
- Орон нутгийн дээр `flutter build web --release` командыг ажиллуулж шалгах
- Алдааны мэдээлэл байвал засах

## 3. Build амжилттай боловч өөрчлөлт харагдахгүй байвал

### A. Cache асуудал
**Шийдэл:**
1. Netlify Dashboard → Site settings → Build & deploy
2. **Clear cache and retry deploy** товч дарах
3. Эсвэл **Trigger deploy** → **Clear cache and deploy site**

### B. GitHub хувилбар таарахгүй байх
**Шийдэл:**
1. GitHub дээр push хийсэн commit-ийг шалгах
2. Netlify дээр **Deploys** → **Trigger deploy** → **Deploy site**
3. Эсвэл GitHub дээр дахин push хийх (жижиг өөрчлөлт)

### C. Build output folder буруу байх
**Шийдэл:**
- `netlify.toml` дээр `publish = "build/web"` зөв эсэхийг шалгах
- Flutter web build-ийн output folder нь `build/web` байх ёстой

## 4. GitHub Integration шалгах

### Repository холбоо тасалсан эсэх
1. Netlify Dashboard → Site settings → Build & deploy → Continuous Deployment
2. **Link to Git provider** дээр дарах
3. GitHub repository-г дахин холбох

### Branch тохиргоо
- **Production branch**: `main` эсвэл `master` байх ёстой
- Push хийсэн branch-ийг шалгах

## 5. Manual Deploy хийх

Хэрэв дээрх алхмууд ажиллахгүй бол:

1. Netlify Dashboard → **Deploys** таб
2. **Trigger deploy** → **Deploy site** товч дарах
3. Эсвэл **Publish directory**-г шалгаад **Trigger deploy** хийх

## 6. Build Script шалгах

`build.sh` файл зөв эсэхийг шалгах:
- Flutter суулгах командууд зөв эсэх
- Build командууд зөв эсэх
- Error handling байгаа эсэх

## 7. Environment Variables шалгах

Netlify дээр шаардлагатай environment variables байгаа эсэхийг шалгах:
1. Site settings → Environment variables
2. Шаардлагатай хувьсагчдыг нэмэх

## 8. Build Timeout

Flutter build удаан байвал timeout болж магадгүй:
1. Site settings → Build & deploy → Build settings
2. **Build timeout**-ийг нэмэгдүүлэх (default: 15 минут)

## Хурдан Шийдэл (Quick Fix)

Хамгийн хурдан арга:
1. Netlify Dashboard → Deploys
2. **Trigger deploy** → **Clear cache and deploy site**
3. Хүлээх (5-10 минут)

## Холбоо барих

Хэрэв дээрх бүх арга ажиллахгүй бол:
- Netlify Support: https://www.netlify.com/support/
- Build log-ийг хавсаргаад илгээх
