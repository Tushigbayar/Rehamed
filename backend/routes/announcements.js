// Мэдэгдлийн route-ууд
// Энэ файл нь мэдэгдлүүдийг удирдах бүх endpoint-уудыг агуулна

const express = require('express');
const router = express.Router();
const Announcement = require('../models/Announcement');
const { authenticateToken } = require('./auth'); // Токен шалгах middleware

// Бүх мэдэгдлүүдийг авах endpoint
router.get('/', authenticateToken, async (req, res) => {
  try {
    const announcements = await Announcement.find()
      .sort({ createdAt: -1 }); // Шинэ мэдэгдлүүдийг эхэнд байрлуулах
    res.json(announcements);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch announcements', message: error.message });
  }
});

// Сүүлийн мэдэгдлүүдийг авах endpoint
router.get('/recent', authenticateToken, async (req, res) => {
  try {
    const limit = parseInt(req.query.limit) || 5; // Хэдэн мэдэгдэл авах (анхдагч: 5)
    const announcements = await Announcement.find()
      .sort({ createdAt: -1 }) // Шинэ мэдэгдлүүдийг эхэнд байрлуулах
      .limit(limit); // Хязгаарлалт
    res.json(announcements);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch announcements', message: error.message });
  }
});

// ID-аар мэдэгдэл авах endpoint
router.get('/:id', authenticateToken, async (req, res) => {
  try {
    const announcement = await Announcement.findById(req.params.id);
    
    if (!announcement) {
      return res.status(404).json({ error: 'Announcement not found' });
    }

    res.json(announcement);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch announcement', message: error.message });
  }
});

// Шинэ мэдэгдэл үүсгэх endpoint (зөвхөн админ)
router.post('/', authenticateToken, async (req, res) => {
  try {
    // Зөвхөн админ мэдэгдэл үүсгэх эрхтэй
    if (req.user.role !== 'admin') {
      return res.status(403).json({ error: 'Admin access required' });
    }

    const { title, content, isImportant, author } = req.body;

    // Заавал шаардлагатай талбаруудыг шалгах
    if (!title || !content) {
      return res.status(400).json({ error: 'Title and content are required' });
    }

    // Шинэ мэдэгдэл үүсгэх
    const announcement = new Announcement({
      title,
      content,
      isImportant: isImportant || false,
      author: author || req.user.username // Хэрэв author байхгүй бол токеноос авна
    });

    await announcement.save();
    res.status(201).json(announcement);
  } catch (error) {
    res.status(500).json({ error: 'Failed to create announcement', message: error.message });
  }
});

// Мэдэгдэл шинэчлэх endpoint (зөвхөн админ)
router.put('/:id', authenticateToken, async (req, res) => {
  try {
    // Зөвхөн админ мэдэгдэл засах эрхтэй
    if (req.user.role !== 'admin') {
      return res.status(403).json({ error: 'Admin access required' });
    }

    const announcement = await Announcement.findById(req.params.id);
    
    if (!announcement) {
      return res.status(404).json({ error: 'Announcement not found' });
    }

    const { title, content, isImportant, author } = req.body;

    // Өөрчлөгдсөн талбаруудыг шинэчлэх
    if (title) announcement.title = title;
    if (content) announcement.content = content;
    if (isImportant !== undefined) announcement.isImportant = isImportant;
    if (author) announcement.author = author;

    await announcement.save();
    res.json(announcement);
  } catch (error) {
    res.status(500).json({ error: 'Failed to update announcement', message: error.message });
  }
});

// Мэдэгдэл устгах endpoint (зөвхөн админ)
router.delete('/:id', authenticateToken, async (req, res) => {
  try {
    // Зөвхөн админ мэдэгдэл устгах эрхтэй
    if (req.user.role !== 'admin') {
      return res.status(403).json({ error: 'Admin access required' });
    }

    const announcement = await Announcement.findById(req.params.id);
    
    if (!announcement) {
      return res.status(404).json({ error: 'Announcement not found' });
    }

    await Announcement.findByIdAndDelete(req.params.id);
    res.json({ message: 'Announcement deleted successfully' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to delete announcement', message: error.message });
  }
});

module.exports = router;
