// Notification-ийн route-ууд
// Энэ файл нь notification-үүдийг удирдах бүх endpoint-уудыг агуулна

const express = require('express');
const router = express.Router();
const Notification = require('../models/Notification');
const { authenticateToken } = require('./auth'); // Токен шалгах middleware

// Бүх notification-үүдийг авах endpoint (хэрэглэгчийн notification-үүд)
router.get('/', authenticateToken, async (req, res) => {
  try {
    // Хэрэглэгчийн notification-үүдийг авах
    const notifications = await Notification.find({ userId: req.user.userId })
      .populate('technicianId', 'name specialization')
      .populate('serviceRequestId', 'title type status')
      .sort({ createdAt: -1 }); // Шинэ notification-үүдийг эхэнд байрлуулах
    
    res.json(notifications);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch notifications', message: error.message });
  }
});

// Уншаагүй notification-үүдийг авах endpoint
router.get('/unread', authenticateToken, async (req, res) => {
  try {
    const notifications = await Notification.find({ 
      userId: req.user.userId,
      isRead: false 
    })
      .populate('technicianId', 'name specialization')
      .populate('serviceRequestId', 'title type status')
      .sort({ createdAt: -1 });
    
    res.json(notifications);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch unread notifications', message: error.message });
  }
});

// Notification уншсан болгох endpoint
router.put('/:id/read', authenticateToken, async (req, res) => {
  try {
    const notification = await Notification.findById(req.params.id);
    
    if (!notification) {
      return res.status(404).json({ error: 'Notification not found' });
    }

    // Зөвхөн notification-ийн эзэн уншсан болгож болно
    if (notification.userId.toString() !== req.user.userId) {
      return res.status(403).json({ error: 'Access denied' });
    }

    notification.isRead = true;
    await notification.save();

    res.json(notification);
  } catch (error) {
    res.status(500).json({ error: 'Failed to mark notification as read', message: error.message });
  }
});

// Бүх notification-үүдийг уншсан болгох endpoint
router.put('/read-all', authenticateToken, async (req, res) => {
  try {
    const result = await Notification.updateMany(
      { userId: req.user.userId, isRead: false },
      { isRead: true }
    );

    res.json({ 
      message: 'All notifications marked as read',
      updatedCount: result.modifiedCount 
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to mark all notifications as read', message: error.message });
  }
});

// Notification устгах endpoint
router.delete('/:id', authenticateToken, async (req, res) => {
  try {
    const notification = await Notification.findById(req.params.id);
    
    if (!notification) {
      return res.status(404).json({ error: 'Notification not found' });
    }

    // Зөвхөн notification-ийн эзэн устгаж болно
    if (notification.userId.toString() !== req.user.userId) {
      return res.status(403).json({ error: 'Access denied' });
    }

    await Notification.findByIdAndDelete(req.params.id);
    res.json({ message: 'Notification deleted successfully' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to delete notification', message: error.message });
  }
});

// Уншаагүй notification-үүдийн тоог авах endpoint
router.get('/unread/count', authenticateToken, async (req, res) => {
  try {
    const count = await Notification.countDocuments({ 
      userId: req.user.userId,
      isRead: false 
    });
    
    res.json({ count });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch unread notification count', message: error.message });
  }
});

module.exports = router;
