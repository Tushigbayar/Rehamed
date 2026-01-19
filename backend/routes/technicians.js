// Засварчдын route-ууд
// Энэ файл нь засварчдын мэдээллийг удирдах бүх endpoint-уудыг агуулна

const express = require('express');
const router = express.Router();
const Technician = require('../models/Technician');
const { authenticateToken } = require('./auth'); // Токен шалгах middleware

// Бүх идэвхтэй засварчдыг авах endpoint
router.get('/', authenticateToken, async (req, res) => {
  try {
    const technicians = await Technician.find({ isActive: true }) // Зөвхөн идэвхтэй засварчдыг
      .sort({ name: 1 }); // Нэрээр эрэмбэлэх (A-Z)
    res.json(technicians);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch technicians', message: error.message });
  }
});

// ID-аар засварчин авах endpoint
router.get('/:id', authenticateToken, async (req, res) => {
  try {
    const technician = await Technician.findById(req.params.id);
    
    if (!technician) {
      return res.status(404).json({ error: 'Technician not found' });
    }

    res.json(technician);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch technician', message: error.message });
  }
});

// Шинэ засварчин үүсгэх endpoint (зөвхөн админ)
router.post('/', authenticateToken, async (req, res) => {
  try {
    // Зөвхөн админ засварчин үүсгэх эрхтэй
    if (req.user.role !== 'admin') {
      return res.status(403).json({ error: 'Admin access required' });
    }

    const { name, phone, specialization, email } = req.body;

    // Заавал шаардлагатай талбаруудыг шалгах
    if (!name || !phone || !specialization) {
      return res.status(400).json({ error: 'Name, phone, and specialization are required' });
    }

    // Шинэ засварчин үүсгэх
    const technician = new Technician({
      name,
      phone,
      specialization,
      email
    });

    await technician.save();
    res.status(201).json(technician);
  } catch (error) {
    res.status(500).json({ error: 'Failed to create technician', message: error.message });
  }
});

// Засварчны мэдээлэл шинэчлэх endpoint (зөвхөн админ)
router.put('/:id', authenticateToken, async (req, res) => {
  try {
    // Зөвхөн админ засварчны мэдээлэл засах эрхтэй
    if (req.user.role !== 'admin') {
      return res.status(403).json({ error: 'Admin access required' });
    }

    const technician = await Technician.findById(req.params.id);
    
    if (!technician) {
      return res.status(404).json({ error: 'Technician not found' });
    }

    const { name, phone, specialization, email, isActive } = req.body;

    // Өөрчлөгдсөн талбаруудыг шинэчлэх
    if (name) technician.name = name;
    if (phone) technician.phone = phone;
    if (specialization) technician.specialization = specialization;
    if (email !== undefined) technician.email = email;
    if (isActive !== undefined) technician.isActive = isActive; // Идэвхтэй эсэхийг өөрчлөх

    await technician.save();
    res.json(technician);
  } catch (error) {
    res.status(500).json({ error: 'Failed to update technician', message: error.message });
  }
});

// Засварчин устгах endpoint (зөвхөн админ)
router.delete('/:id', authenticateToken, async (req, res) => {
  try {
    // Зөвхөн админ засварчин устгах эрхтэй
    if (req.user.role !== 'admin') {
      return res.status(403).json({ error: 'Admin access required' });
    }

    const technician = await Technician.findById(req.params.id);
    
    if (!technician) {
      return res.status(404).json({ error: 'Technician not found' });
    }

    await Technician.findByIdAndDelete(req.params.id);
    res.json({ message: 'Technician deleted successfully' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to delete technician', message: error.message });
  }
});

module.exports = router;
