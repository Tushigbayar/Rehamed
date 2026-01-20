// Нэвтрэх, бүртгүүлэх route-ууд
// Энэ файл нь хэрэглэгчийн нэвтрэх, бүртгүүлэх болон токен шалгах функцүүдийг агуулна

const express = require('express');
const router = express.Router();
const User = require('../models/User');
const jwt = require('jsonwebtoken'); // JSON Web Token үүсгэх, шалгахад ашиглана

// JWT нууц түлхүүр - production дээр .env файлд байх ёстой
const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key-change-in-production';

// Нэвтрэх endpoint
router.post('/login', async (req, res) => {
  try {
    const { username, password } = req.body;

    // Хэрэглэгчийн нэр, нууц үг байгаа эсэхийг шалгах
    if (!username || !password) {
      return res.status(400).json({ error: 'Username and password are required' });
    }

    // Хэрэглэгчийг олох
    const user = await User.findOne({ username });
    if (!user) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    // Нууц үгийг шалгах
    const isPasswordValid = await user.comparePassword(password);
    if (!isPasswordValid) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    // JWT токен үүсгэх (7 хоногийн хугацаатай)
    const token = jwt.sign(
      { userId: user._id, username: user.username, role: user.role },
      JWT_SECRET,
      { expiresIn: '7d' }
    );

    // Токен болон хэрэглэгчийн мэдээллийг буцаах
    res.json({
      token,
      user: {
        id: user._id,
        username: user.username,
        name: user.name,
        role: user.role
      }
    });
  } catch (error) {
    res.status(500).json({ error: 'Login failed', message: error.message });
  }
});

// Бүртгүүлэх endpoint
router.post('/register', async (req, res) => {
  try {
    const { username, password, name, email, role } = req.body;

    // Заавал шаардлагатай талбаруудыг шалгах
    if (!username || !password || !name) {
      return res.status(400).json({ error: 'Username, password, and name are required' });
    }

    // Хэрэглэгчийн нэр давтагдахгүй эсэхийг шалгах
    const existingUser = await User.findOne({ username });
    if (existingUser) {
      return res.status(400).json({ error: 'Username already exists' });
    }

    // Шинэ хэрэглэгч үүсгэх
    const user = new User({
      username,
      password, // pre-save middleware нууц үгийг автоматаар hash хийх болно
      name,
      email,
      role: role || 'user' // Анхдагч role: user
    });

    await user.save();

    // JWT токен үүсгэх
    const token = jwt.sign(
      { userId: user._id, username: user.username, role: user.role },
      JWT_SECRET,
      { expiresIn: '7d' }
    );

    // Токен болон хэрэглэгчийн мэдээллийг буцаах
    res.status(201).json({
      token,
      user: {
        id: user._id,
        username: user.username,
        name: user.name,
        role: user.role
      }
    });
  } catch (error) {
    res.status(500).json({ error: 'Registration failed', message: error.message });
  }
});

// Одоогийн хэрэглэгчийн мэдээлэл авах endpoint
router.get('/me', authenticateToken, async (req, res) => {
  try {
    // Токеноос авсан userId-аар хэрэглэгчийг олох (нууц үггүй)
    const user = await User.findById(req.user.userId).select('-password');
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }
    res.json({ user });
  } catch (error) {
    res.status(500).json({ error: 'Failed to get user', message: error.message });
  }
});

// Токен шалгах middleware - бусад route-уудад ашиглана
function authenticateToken(req, res, next) {
  // Authorization header-оос токенийг авах
  const authHeader = req.headers['authorization'] || req.headers['Authorization'];
  
  // Debug: Header шалгах
  console.log('=== authenticateToken Debug ===');
  console.log('Request path:', req.path);
  console.log('Authorization header:', authHeader ? authHeader.substring(0, 50) + '...' : 'null');
  console.log('All headers:', Object.keys(req.headers));
  
  const token = authHeader && authHeader.split(' ')[1]; // "Bearer TOKEN" форматаас токенийг салгах
  
  console.log('Extracted token:', token ? token.substring(0, 30) + '...' : 'null');

  if (!token) {
    console.log('ERROR: Token not found');
    return res.status(401).json({ error: 'Access token required' });
  }

  // Токенийг шалгах
  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) {
      console.log('ERROR: Token verification failed:', err.message);
      return res.status(403).json({ error: 'Invalid or expired token' });
    }
    console.log('Token verified successfully. User:', user);
    req.user = user; // Хүсэлтэд хэрэглэгчийн мэдээллийг нэмэх
    next(); // Дараагийн middleware эсвэл route handler руу шилжих
  });
}

module.exports = router;
module.exports.authenticateToken = authenticateToken; // Бусад файлуудад экспортлох
