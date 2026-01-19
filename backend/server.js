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
app.use(cors()); // Cross-Origin Resource Sharing - бусад домэйнуудаас хүсэлт хүлээн авах зөвшөөрөл
app.use(express.json()); // JSON форматтай хүсэлтүүдийг унших
app.use(express.urlencoded({ extended: true })); // URL-encoded хүсэлтүүдийг унших

// Routes - API endpoint-уудыг холбох
app.use('/api/auth', require('./routes/auth')); // Нэвтрэх, бүртгүүлэх endpoint-ууд
app.use('/api/service-requests', require('./routes/serviceRequests')); // Үйлчилгээний хүсэлтүүдийн endpoint-ууд
app.use('/api/technicians', require('./routes/technicians')); // Засварчдын endpoint-ууд
app.use('/api/announcements', require('./routes/announcements')); // Мэдэгдлийн endpoint-ууд

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
    app.listen(PORT, () => {
      console.log(`Server is running on port ${PORT}`);
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
