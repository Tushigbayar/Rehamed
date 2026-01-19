// Хэрэглэгчийн модель
// Энэ файл нь хэрэглэгчийн мэдээллийг хадгалах бүтцийг тодорхойлдог

const mongoose = require('mongoose');
const bcrypt = require('bcryptjs'); // Нууц үгийг hash хийхэд ашиглана

// Хэрэглэгчийн schema - хэрэглэгчийн мэдээллийн бүтэц
const userSchema = new mongoose.Schema({
  username: {
    type: String,
    required: true, // Заавал оруулах
    unique: true, // Давтагдахгүй
    trim: true // Хоосон зайг арилгах
  },
  password: {
    type: String,
    required: true // Заавал оруулах
  },
  name: {
    type: String,
    required: true // Заавал оруулах
  },
  email: {
    type: String,
    trim: true, // Хоосон зайг арилгах
    lowercase: true // Жижиг үсэг болгох
  },
  role: {
    type: String,
    enum: ['user', 'admin', 'technician'], // Зөвхөн эдгээр утгуудыг зөвшөөрөх
    default: 'user' // Анхдагч утга
  }
}, {
  timestamps: true // createdAt, updatedAt талбаруудыг автоматаар нэмэх
});

// Нууц үгийг хадгалахаасаа өмнө hash хийх middleware
userSchema.pre('save', async function(next) {
  if (!this.isModified('password')) return next(); // Нууц үг өөрчлөгдөөгүй бол алгасах
  this.password = await bcrypt.hash(this.password, 10); // Нууц үгийг hash хийх
  next();
});

// Нууц үгийг шалгах функц
userSchema.methods.comparePassword = async function(candidatePassword) {
  return await bcrypt.compare(candidatePassword, this.password);
};

module.exports = mongoose.model('User', userSchema);
