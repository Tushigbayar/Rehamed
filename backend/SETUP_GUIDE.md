# Backend суулгах заавар

## Алхам 1: Node.js суулгах

1. Node.js суулгаагүй бол эхлээд суулгана уу:
   - https://nodejs.org/ сайтаас Node.js (v14 эсвэл дээш) татаж авна
   - Суулгана

2. Суулгасан эсэхийг шалгах:
```bash
node --version
npm --version
```

## Алхам 2: MongoDB суулгах

### Сонголт 1: Local MongoDB (орон нутгийн)

1. MongoDB Community Edition суулгах:
   - https://www.mongodb.com/try/download/community
   - Windows дээр MongoDB суулгана

2. MongoDB-ийг ажиллуулах:
   - Windows дээр MongoDB нь автоматаар ажиллана (суулгасны дараа)

### Сонголт 2: MongoDB Atlas (Cloud - үнэгүй)

1. https://www.mongodb.com/cloud/atlas/register сайтад бүртгүүлнэ
2. Free tier сонгоно
3. Database хийх
4. Connection string-ийг авна (mongodb+srv://...)
5. `.env` файлд `MONGODB_URI` гэсэн талбарт оруулна

## Алхам 3: Backend суулгах

1. Backend хавтас руу орно:
```bash
cd backend
```

2. Dependencies суулгана:
```bash
npm install
```

3. `.env` файл үүсгэнэ:
   - `backend` хавтсанд `.env` нэртэй файл үүсгэнэ
   - Дараах агуулгыг бичнэ:

```
MONGODB_URI=mongodb://localhost:27017/rehamed
PORT=5000
JWT_SECRET=your-secret-key-change-in-production
```

   Хэрэв MongoDB Atlas ашиглаж байвал:
```
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/rehamed
PORT=5000
JWT_SECRET=your-secret-key-change-in-production
```

## Алхам 4: Database-д анхны өгөгдөл оруулах (Seed)

Анхны хэрэглэгч, техникч, зарлал үүсгэхийн тулд:
```bash
npm run seed
```

Энэ нь дараах хэрэглэгчдийг үүсгэнэ:
- **Admin**: username: `admin`, password: `admin123`
- **User**: username: `user`, password: `user123`
- 3 техникч
- 3 зарлал

## Алхам 5: Backend server ажиллуулах

### Development mode (хөгжүүлэлтийн горим):
```bash
npm run dev
```

Энэ нь nodemon ашигладаг, код өөрчлөгдөхөд автоматаар дахин ажиллана.

### Production mode (бүтээгдэхүүний горим):
```bash
npm start
```

Server амжилттай ажиллаж байвал:
```
MongoDB connected successfully
Server is running on port 5000
```

## Алхам 6: Backend ажиллаж байгаа эсэхийг шалгах

Браузер эсвэл Postman ашиглан:
```
http://localhost:5000/api/health
```

Хариу:
```json
{
  "status": "OK",
  "message": "Server is running"
}
```

## Алхам 7: API тест хийх

### Login тест (Postman эсвэл curl ашиглана):

```bash
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d "{\"username\":\"admin\",\"password\":\"admin123\"}"
```

Хариу (token авах):
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "...",
    "username": "admin",
    "name": "Админ",
    "role": "admin"
  }
}
```

## Асуудал гарвал

1. **MongoDB холбогдохгүй байвал:**
   - MongoDB ажиллаж байгаа эсэхийг шалгана
   - `.env` файл дахь `MONGODB_URI` зөв эсэхийг шалгана

2. **Port 5000 ашиглаж байвал:**
   - `.env` файл дахь `PORT` өөрчлөнө (жишээ: 5001)

3. **Dependencies суулгах асуудал:**
   - `node_modules` хавтсыг устгаад дахин суулгана:
   ```bash
   rm -rf node_modules
   npm install
   ```

4. **Windows дээр:**
   - PowerShell эсвэл Command Prompt ашиглана
   - Git Bash ашиглаж болно

## Дараагийн алхам

Backend ажиллаж байгаа бол Flutter аппыг backend-тай холбох хэрэгтэй. `http` package ашиглан API-тай холбогдоно.
