// Засварчдын модель
// Энэ файл нь засварчдын мэдээллийг хадгалах бүтцийг тодорхойлдог

const mongoose = require('mongoose');

// Засварчдын schema - засварчдын мэдээллийн бүтэц
const technicianSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true // Заавал оруулах - засварчдын нэр
  },
  phone: {
    type: String,
    required: true // Заавал оруулах - утасны дугаар
  },
  specialization: {
    type: String,
    required: true // Заавал оруулах - мэргэшлийн чиглэл (жишээ: Цахилгаан засвар)
  },
  email: {
    type: String,
    trim: true, // Хоосон зайг арилгах
    lowercase: true // Жижиг үсэг болгох
  },
  isActive: {
    type: Boolean,
    default: true // Анхдагч утга - засварчин идэвхтэй эсэх
  }
}, {
  timestamps: true // createdAt, updatedAt талбаруудыг автоматаар нэмэх
});

module.exports = mongoose.model('Technician', technicianSchema);
