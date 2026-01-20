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
const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/rehamed';
const PORT = process.env.PORT || 5000;

// MongoDB-д холбогдох
mongoose
  .connect(MONGODB_URI)
  .then(() => {
    console.log('MongoDB connected successfully');
    // MongoDB холбогдсоны дараа серверийг эхлүүлэх
    // 0.0.0.0 дээр listen хийх нь бүх network interface дээр сонсох гэсэн үг
    // Энэ нь physical device-ээс холбогдох боломжийг олгоно
    app.listen(PORT, '0.0.0.0', () => {
      console.log(`Server is running on port ${PORT}`);
      console.log(`Local: http://localhost:${PORT}`);
      console.log(`Network: http://0.0.0.0:${PORT}`);
      console.log('\n✅ Server нь БҮХ network interface дээр сонсож байна');
      console.log('✅ Олон төхөөрөмж, олон IP хаягаас хандах боломжтой');
      console.log('\nPhysical device дээр ажиллахын тулд:');
      console.log('1. Компьютерийн IP хаягийг олох:');
      console.log('   Windows: ipconfig');
      console.log('   Mac/Linux: ifconfig эсвэл ip addr');
      console.log('2. Flutter app дээр api_config.dart файлд computerIPs array-д IP хаягуудыг нэмэх');
      console.log('3. Бүх төхөөрөмж ижил WiFi network дээр байх ёстой');
      console.log('4. Firewall 5000 портыг нээх шаардлагатай');
    });
  })
  .catch((error) => {
    console.error('MongoDB connection error:', error);
    process.exit(1); // Алдаа гарвал програм зогсоох
  });

// Error handling middleware - бүх алдааг барьж авах
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ 
    error: 'Something went wrong!',
    message: err.message 
  });
});
