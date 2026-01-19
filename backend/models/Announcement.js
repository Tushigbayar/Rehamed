// Мэдэгдлийн модель
// Энэ файл нь мэдэгдлийн мэдээллийг хадгалах бүтцийг тодорхойлдог

const mongoose = require('mongoose');

// Мэдэгдлийн schema - мэдэгдлийн мэдээллийн бүтэц
const announcementSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true // Заавал оруулах - мэдэгдлийн гарчиг
  },
  content: {
    type: String,
    required: true // Заавал оруулах - мэдэгдлийн агуулга
  },
  author: {
    type: String // Мэдэгдэл бичсэн хүний нэр
  },
  isImportant: {
    type: Boolean,
    default: false // Чухал эсэх - анхдагч утга: false
  },
  createdAt: {
    type: Date,
    default: Date.now // Мэдэгдэл үүсгэсэн огноо
  }
}, {
  timestamps: true // createdAt, updatedAt талбаруудыг автоматаар нэмэх
});

module.exports = mongoose.model('Announcement', announcementSchema);
