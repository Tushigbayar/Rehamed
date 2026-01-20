// Notification-ийн модель
// Энэ файл нь notification-ийн мэдээллийг хадгалах бүтцийг тодорхойлдог

const mongoose = require('mongoose');

// Notification-ийн schema - notification-ийн мэдээллийн бүтэц
const notificationSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User', // User моделд холбох - notification хүлээн авах хэрэглэгч
    required: true // Заавал оруулах
  },
  technicianId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Technician', // Technician моделд холбох - notification илгээх засварчин
    required: true // Заавал оруулах
  },
  serviceRequestId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'ServiceRequest', // ServiceRequest моделд холбох - холбогдох засварын хүсэлт
    required: true // Заавал оруулах
  },
  title: {
    type: String,
    required: true // Заавал оруулах - notification-ийн гарчиг
  },
  message: {
    type: String,
    required: true // Заавал оруулах - notification-ийн агуулга
  },
  type: {
    type: String,
    enum: ['assignment', 'status_change', 'other'], // Notification-ийн төрөл
    default: 'assignment' // Анхдагч утга
    // assignment: засварчид ажил томилогдох, status_change: статус өөрчлөгдөх, other: бусад
  },
  isRead: {
    type: Boolean,
    default: false // Уншсан эсэх - анхдагч утга: false (уншаагүй)
  }
}, {
  timestamps: true // createdAt, updatedAt талбаруудыг автоматаар нэмэх
});

// Index үүсгэх - хурдан хайлт хийхэд тустай
notificationSchema.index({ userId: 1, createdAt: -1 });
notificationSchema.index({ technicianId: 1, createdAt: -1 });
notificationSchema.index({ isRead: 1 });

module.exports = mongoose.model('Notification', notificationSchema);
