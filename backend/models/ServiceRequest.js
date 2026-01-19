// Үйлчилгээний хүсэлтийн модель
// Энэ файл нь үйлчилгээний хүсэлтийн мэдээллийг хадгалах бүтцийг тодорхойлдог

const mongoose = require('mongoose');

// Үйлчилгээний хүсэлтийн schema
const serviceRequestSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User', // User моделд холбох
    required: true // Заавал оруулах - хүсэлт гаргасан хэрэглэгч
  },
  type: {
    type: String,
    enum: ['emergency', 'maintenance', 'cleaning', 'equipment', 'other'], // Зөвхөн эдгээр төрлүүд
    required: true // Заавал оруулах - хүсэлтийн төрөл
    // emergency: яаралтай, maintenance: засвар, cleaning: цэвэрлэгээ, equipment: тоног төхөөрөмж, other: бусад
  },
  title: {
    type: String,
    required: true // Заавал оруулах - хүсэлтийн гарчиг
  },
  description: {
    type: String,
    required: true // Заавал оруулах - дэлгэрэнгүй тайлбар
  },
  location: {
    type: String,
    required: true // Заавал оруулах - байршил
  },
  status: {
    type: String,
    enum: ['pending', 'accepted', 'inProgress', 'completed', 'cancelled'], // Зөвхөн эдгээр статусууд
    default: 'pending' // Анхдагч статус
    // pending: хүлээгдэж буй, accepted: хүлээн авсан, inProgress: хийгдэж буй, completed: дууссан, cancelled: цуцлагдсан
  },
  requestedAt: {
    type: Date,
    default: Date.now // Хүсэлт гаргасан огноо
  },
  acceptedAt: {
    type: Date // Хүлээн авсан огноо
  },
  completedAt: {
    type: Date // Дууссан огноо
  },
  assignedTo: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Technician' // Technician моделд холбох - хүсэлтэд томилогдсон засварчин
  },
  notes: {
    type: String // Нэмэлт тэмдэглэл
  },
  images: [{
    type: String // Зургийн URL-уудын массив
  }],
  isUrgent: {
    type: Boolean,
    default: false // Яаралтай эсэх
  },
  scheduledDate: {
    type: Date // Төлөвлөсөн огноо
  },
  scheduledTime: {
    type: Date // Төлөвлөсөн цаг
  }
}, {
  timestamps: true // createdAt, updatedAt талбаруудыг автоматаар нэмэх
});

module.exports = mongoose.model('ServiceRequest', serviceRequestSchema);
