// Express серверийн үндсэн файл
// Энэ файл нь серверийг эхлүүлж, бүх route-уудыг холбодог

const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const dotenv = require('dotenv');

// .env файлаас тохиргоонуудыг унших
dotenv.config();

const app = express();

// Middleware - бүх хүсэлтэнд хэрэглэгдэх тохиргоонууд
// CORS тохиргоо - БҮХ төхөөрөмж, бүх IP хаягаас хандах боломжтой болгох
app.use(cors({
  origin: '*', // Бүх origin-ээс хүлээн авах (development дээр)
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: false // Cookie шаардлагагүй
}));
app.use(express.json()); // JSON форматтай хүсэлтүүдийг унших
app.use(express.urlencoded({ extended: true })); // URL-encoded хүсэлтүүдийг унших

// Routes - API endpoint-уудыг холбох
app.use('/api/auth', require('./routes/auth')); // Нэвтрэх, бүртгүүлэх endpoint-ууд
app.use('/api/service-requests', require('./routes/serviceRequests')); // Үйлчилгээний хүсэлтүүдийн endpoint-ууд
app.use('/api/technicians', require('./routes/technicians')); // Засварчдын endpoint-ууд
app.use('/api/announcements', require('./routes/announcements')); // Мэдэгдлийн endpoint-ууд
app.use('/api/notifications', require('./routes/notifications')); // Notification-ийн endpoint-ууд

// Health check - серверийн эрүүл мэндийг шалгах endpoint
app.get('/api/health', (req, res) => {
  res.json({ status: 'OK', message: 'Server is running' });
});

// MongoDB холболтын тохиргоо
const MONGODB_URI = process.env.MONGODB_URI;
const PORT = process.env.PORT || 5000;

if (!MONGODB_URI) {
  console.error('❌ MONGODB_URI missing');
  process.exit(1);
}

mongoose.connect(MONGODB_URI)
  .then(() => {
    console.log('✅ MongoDB connected');
    app.listen(PORT, () => {
      console.log(`🚀 Server running on port ${PORT}`);
    });
  })
  .catch(err => {
    console.error('❌ MongoDB error:', err);
    process.exit(1);
  });

// Error handling middleware - бүх алдааг барьж авах
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ 
    error: 'Something went wrong!',
    message: err.message 
  });
});
