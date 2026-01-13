# Үнэгүй Web Server дээр байршуулах заавар

## 🚀 Хамгийн хялбар арга: Firebase Hosting

### 1. Firebase account үүсгэх
1. https://firebase.google.com дээр орох
2. Google account-аар нэвтрэх
3. "Get started" дарах

### 2. Firebase CLI суулгах
```bash
npm install -g firebase-tools
```

### 3. Firebase-д нэвтрэх
```bash
firebase login
```

### 4. Firebase project үүсгэх
1. https://console.firebase.google.com дээр орох
2. "Add project" дарах
3. Project нэр оруулах: "rehamed-maintenance"
4. "Create project" дарах

### 5. Hosting идэвхжүүлэх
1. Firebase Console дээр "Hosting" сонгох
2. "Get started" дарах
3. "Next" → "Continue"

### 6. Firebase init хийх
```bash
cd C:\my_app
firebase init hosting
```

**Сонголтууд:**
- What do you want to use as your public directory? → `build/web`
- Configure as a single-page app? → `Yes`
- Set up automatic builds and deploys with GitHub? → `No`

### 7. Deploy хийх
```bash
flutter build web
firebase deploy --only hosting
```

### 8. URL авах
- Firebase Console → Hosting → Site URL
- Жишээ: `https://rehamed-maintenance.web.app`

---

## 🌐 Netlify (Хамгийн хурдан)

### 1. Netlify account үүсгэх
1. https://www.netlify.com дээр орох
2. "Sign up" дарах (GitHub, GitLab, эсвэл Email)

### 2. Deploy хийх (Drag & Drop)
1. `flutter build web` хийх
2. https://app.netlify.com/drop дээр орох
3. `build/web` folder-ийг drag & drop хийх
4. Deploy автоматаар эхэлнэ

### 3. URL авах
- Netlify dashboard дээр site URL харагдана
- Жишээ: `https://random-name-12345.netlify.app`

### 4. Custom domain нэмэх (сонголттой)
- Site settings → Domain management
- Custom domain нэмэх

---

## 📦 GitHub Pages (GitHub ашигладаг бол)

### 1. GitHub repository үүсгэх
1. https://github.com дээр орох
2. "New repository" дарах
3. Repository нэр: "rehamed-maintenance"
4. "Create repository" дарах

### 2. Code push хийх
```bash
cd C:\my_app
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/rehamed-maintenance.git
git push -u origin main
```

### 3. GitHub Pages идэвхжүүлэх
1. Repository → Settings → Pages
2. Source: "Deploy from a branch" сонгох
3. Branch: `main` сонгох
4. Folder: `/build/web` сонгох
5. "Save" дарах

### 4. Build workflow үүсгэх
`.github/workflows/deploy.yml` файл үүсгэх:
```yaml
name: Deploy to GitHub Pages

on:
  push:
    branches: [ main ]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.38.5'
      - run: flutter pub get
      - run: flutter build web
      - uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./build/web
```

### 5. URL авах
- `https://YOUR_USERNAME.github.io/rehamed-maintenance`

---

## ⚡ Vercel (Хурдан, найдвартай)

### 1. Vercel account үүсгэх
1. https://vercel.com дээр орох
2. GitHub эсвэл Email-аар бүртгүүлэх

### 2. Vercel CLI суулгах
```bash
npm install -g vercel
```

### 3. Deploy хийх
```bash
cd C:\my_app
flutter build web
cd build/web
vercel
```

**Сонголтууд:**
- Set up and deploy? → `Y`
- Which scope? → Сонгох
- Link to existing project? → `N`
- Project name → `rehamed-maintenance`
- Directory → `.`

### 4. URL авах
- Vercel dashboard дээр site URL харагдана
- Жишээ: `https://rehamed-maintenance.vercel.app`

---

## 🎯 Харьцуулалт

| Сервис | Хурд | Хувийн domain | SSL | Хязгаарлалт |
|--------|------|---------------|-----|--------------|
| **Firebase** | ⭐⭐⭐⭐ | ✅ | ✅ | 10GB bandwidth |
| **Netlify** | ⭐⭐⭐⭐⭐ | ✅ | ✅ | 100GB bandwidth |
| **GitHub Pages** | ⭐⭐⭐ | ✅ | ✅ | 1GB storage |
| **Vercel** | ⭐⭐⭐⭐⭐ | ✅ | ✅ | Unlimited |

---

## 🏆 Зөвлөмж

### Хамгийн хялбар: Netlify
- Drag & drop арга
- Хурдан deploy
- Автомат SSL

### Хамгийн найдвартай: Firebase
- Google-ийн дэмжлэг
- Хорох integration
- Real-time database

### Хамгийн хурдан: Vercel
- Edge network
- Хурдан хурд
- CDN integration

---

## 📝 Хурдан заавар (Netlify)

```bash
# 1. Web build хийх
flutter build web

# 2. Netlify дээр drag & drop
# https://app.netlify.com/drop
# build/web folder-ийг drag & drop хийх

# 3. URL авах
# Netlify dashboard дээр site URL харагдана
```

---

## 📝 Хурдан заавар (Firebase)

```bash
# 1. Firebase CLI суулгах
npm install -g firebase-tools

# 2. Нэвтрэх
firebase login

# 3. Init хийх
firebase init hosting
# Public directory: build/web
# Single-page app: Yes

# 4. Build хийх
flutter build web

# 5. Deploy хийх
firebase deploy --only hosting

# 6. URL авах
# Firebase Console → Hosting → Site URL
```

---

## 🔧 Custom domain нэмэх

### Netlify:
1. Site settings → Domain management
2. "Add custom domain" дарах
3. Domain нэр оруулах
4. DNS тохиргоо хийх

### Firebase:
1. Hosting → Add custom domain
2. Domain нэр оруулах
3. DNS тохиргоо хийх

---

## ⚠️ Тэмдэглэл

1. **Build хийх:**
   - Deploy хийхээсээ өмнө `flutter build web` хийх хэрэгтэй

2. **Folder:**
   - Зөвхөн `build/web` folder-ийг deploy хийх
   - Бусад файлууд хэрэггүй

3. **Update хийх:**
   - Код өөрчлөхөд дахин build хийж deploy хийх

---

## 🎉 Амжилттай байршуулсны дараа

1. **URL хуваалцах:**
   - Хүмүүст URL хуваалцах
   - Утасны browser-оор нээх

2. **"Add to Home Screen":**
   - iOS: Safari → Share → Add to Home Screen
   - Android: Chrome → Menu → Add to Home Screen

3. **App шиг ажиллана:**
   - Home screen дээр icon харагдана
   - App шиг ажиллана

---

## 📞 Тусламж

- Firebase: https://firebase.google.com/docs/hosting
- Netlify: https://docs.netlify.com
- GitHub Pages: https://docs.github.com/pages
- Vercel: https://vercel.com/docs
