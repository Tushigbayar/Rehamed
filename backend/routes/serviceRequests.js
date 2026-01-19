// Үйлчилгээний хүсэлтийн route-ууд
// Энэ файл нь үйлчилгээний хүсэлтүүдийг удирдах бүх endpoint-уудыг агуулна

const express = require('express');
const router = express.Router();
const ServiceRequest = require('../models/ServiceRequest');
const { authenticateToken } = require('./auth'); // Токен шалгах middleware

// Бүх үйлчилгээний хүсэлтүүдийг авах endpoint
// Админ: бүх хүсэлтүүд, Энгийн хэрэглэгч: зөвхөн өөрийн хүсэлтүүд
router.get('/', authenticateToken, async (req, res) => {
  try {
    // Админ эсэхийг шалгаж query үүсгэх
    const query = req.user.role === 'admin' ? {} : { userId: req.user.userId };
    const requests = await ServiceRequest.find(query)
      .populate('userId', 'name username') // Хэрэглэгчийн мэдээллийг нэмэх
      .populate('assignedTo', 'name specialization') // Засварчдын мэдээллийг нэмэх
      .sort({ requestedAt: -1 }); // Шинэ хүсэлтүүдийг эхэнд байрлуулах
    res.json(requests);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch requests', message: error.message });
  }
});

// ID-аар үйлчилгээний хүсэлт авах endpoint
router.get('/:id', authenticateToken, async (req, res) => {
  try {
    const request = await ServiceRequest.findById(req.params.id)
      .populate('userId', 'name username') // Хэрэглэгчийн мэдээллийг нэмэх
      .populate('assignedTo', 'name specialization phone'); // Засварчдын мэдээллийг нэмэх
    
    if (!request) {
      return res.status(404).json({ error: 'Service request not found' });
    }

    // Хэрэглэгч энэ хүсэлтийг харах эрхтэй эсэхийг шалгах
    // Админ: бүх хүсэлт харна, Энгийн хэрэглэгч: зөвхөн өөрийн хүсэлт
    if (req.user.role !== 'admin' && request.userId._id.toString() !== req.user.userId) {
      return res.status(403).json({ error: 'Access denied' });
    }

    res.json(request);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch request', message: error.message });
  }
});

// Шинэ үйлчилгээний хүсэлт үүсгэх endpoint
router.post('/', authenticateToken, async (req, res) => {
  try {
    const {
      type,
      title,
      description,
      location,
      isUrgent,
      scheduledDate,
      scheduledTime,
      images
    } = req.body;

    // Заавал шаардлагатай талбаруудыг шалгах
    if (!type || !title || !description || !location) {
      return res.status(400).json({ error: 'Type, title, description, and location are required' });
    }

    // Шинэ үйлчилгээний хүсэлт үүсгэх
    const serviceRequest = new ServiceRequest({
      userId: req.user.userId, // Токеноос авсан хэрэглэгчийн ID
      type,
      title,
      description,
      location,
      isUrgent: isUrgent || false,
      scheduledDate: scheduledDate ? new Date(scheduledDate) : undefined,
      scheduledTime: scheduledTime ? new Date(scheduledTime) : undefined,
      images: images || []
    });

    await serviceRequest.save();
    await serviceRequest.populate('userId', 'name username'); // Хэрэглэгчийн мэдээллийг нэмэх
    
    res.status(201).json(serviceRequest);
  } catch (error) {
    res.status(500).json({ error: 'Failed to create request', message: error.message });
  }
});

// Үйлчилгээний хүсэлт шинэчлэх endpoint
router.put('/:id', authenticateToken, async (req, res) => {
  try {
    const request = await ServiceRequest.findById(req.params.id);
    
    if (!request) {
      return res.status(404).json({ error: 'Service request not found' });
    }

    // Хэрэглэгч энэ хүсэлтийг засах эрхтэй эсэхийг шалгах
    // Админ: бүх хүсэлт засна, Энгийн хэрэглэгч: зөвхөн өөрийн хүсэлт
    if (req.user.role !== 'admin' && request.userId.toString() !== req.user.userId) {
      return res.status(403).json({ error: 'Access denied' });
    }

    const {
      type,
      title,
      description,
      location,
      status,
      assignedTo,
      notes,
      images,
      isUrgent,
      scheduledDate,
      scheduledTime
    } = req.body;

    // Өөрчлөгдсөн талбаруудыг шинэчлэх
    if (type) request.type = type;
    if (title) request.title = title;
    if (description) request.description = description;
    if (location) request.location = location;
    if (status !== undefined) {
      request.status = status;
      // Статус өөрчлөгдөхөд огноог автоматаар нэмэх
      if (status === 'accepted' && !request.acceptedAt) {
        request.acceptedAt = new Date();
      }
      if (status === 'completed' && !request.completedAt) {
        request.completedAt = new Date();
      }
    }
    if (assignedTo !== undefined) request.assignedTo = assignedTo;
    if (notes !== undefined) request.notes = notes;
    if (images !== undefined) request.images = images;
    if (isUrgent !== undefined) request.isUrgent = isUrgent;
    if (scheduledDate !== undefined) request.scheduledDate = scheduledDate ? new Date(scheduledDate) : null;
    if (scheduledTime !== undefined) request.scheduledTime = scheduledTime ? new Date(scheduledTime) : null;

    await request.save();
    await request.populate('userId', 'name username');
    await request.populate('assignedTo', 'name specialization phone');

    res.json(request);
  } catch (error) {
    res.status(500).json({ error: 'Failed to update request', message: error.message });
  }
});

// Үйлчилгээний хүсэлт устгах endpoint
router.delete('/:id', authenticateToken, async (req, res) => {
  try {
    const request = await ServiceRequest.findById(req.params.id);
    
    if (!request) {
      return res.status(404).json({ error: 'Service request not found' });
    }

    // Хэрэглэгч энэ хүсэлтийг устгах эрхтэй эсэхийг шалгах
    // Админ: бүх хүсэлт устгана, Энгийн хэрэглэгч: зөвхөн өөрийн хүсэлт
    if (req.user.role !== 'admin' && request.userId.toString() !== req.user.userId) {
      return res.status(403).json({ error: 'Access denied' });
    }

    await ServiceRequest.findByIdAndDelete(req.params.id);
    res.json({ message: 'Service request deleted successfully' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to delete request', message: error.message });
  }
});

// Статусаар үйлчилгээний хүсэлтүүдийг авах endpoint
router.get('/status/:status', authenticateToken, async (req, res) => {
  try {
    const { status } = req.params;
    const query = { status };
    
    // Админ биш бол зөвхөн өөрийн хүсэлтүүдийг харуулах
    if (req.user.role !== 'admin') {
      query.userId = req.user.userId;
    }

    const requests = await ServiceRequest.find(query)
      .populate('userId', 'name username')
      .populate('assignedTo', 'name specialization')
      .sort({ requestedAt: -1 }); // Шинэ хүсэлтүүдийг эхэнд байрлуулах
    
    res.json(requests);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch requests', message: error.message });
  }
});

module.exports = router;
