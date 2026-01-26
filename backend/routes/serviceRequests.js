// Үйлчилгээний хүсэлтийн route-ууд
// Энэ файл нь үйлчилгээний хүсэлтүүдийг удирдах бүх endpoint-уудыг агуулна

const express = require('express');
const router = express.Router();
const ServiceRequest = require('../models/ServiceRequest');
const Notification = require('../models/Notification');
const Technician = require('../models/Technician');
const User = require('../models/User');
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
      const previousStatus = request.status;
      request.status = status;
      // Статус өөрчлөгдөхөд огноог автоматаар нэмэх
      if (status === 'accepted' && !request.acceptedAt) {
        request.acceptedAt = new Date();
      }
      if (status === 'completed' && !request.completedAt) {
        request.completedAt = new Date();
      }
      
      // Статус өөрчлөгдсөн бол хэрэглэгчид notification илгээх
      if (status !== previousStatus) {
        try {
          const user = await User.findById(request.userId);
          if (user) {
            const notification = new Notification({
              userId: user._id,
              technicianId: request.assignedTo || user._id,
              serviceRequestId: request._id,
              title: 'Засварын хүсэлтийн статус өөрчлөгдлөө',
              message: `"${request.title}" засварын хүсэлтийн статус "${status}" болсон.`,
              type: 'status_change'
            });
            await notification.save();
            
            // Socket.IO ашиглан real-time notification илгээх
            const io = req.app.get('io');
            if (io) {
              const populatedNotification = await Notification.findById(notification._id)
                .populate('technicianId', 'name specialization')
                .populate('serviceRequestId', 'title type status');
              io.to(`user_${user._id}`).emit('notification', populatedNotification);
              console.log(`📤 Sent status change notification to user ${user._id}`);
            }
          }
        } catch (notificationError) {
          console.error('Error creating status change notification:', notificationError);
        }
      }
    }
    // Засварчин томилогдох үед notification илгээх
    const previousAssignedTo = request.assignedTo ? request.assignedTo.toString() : null;
    if (assignedTo !== undefined) {
      request.assignedTo = assignedTo;
      
      // Засварчин шинээр томилогдсон эсэхийг шалгах
      if (assignedTo && assignedTo !== previousAssignedTo) {
        try {
          const technician = await Technician.findById(assignedTo);
          if (technician) {
            // Засварчтай холбоотой хэрэглэгчийн дансыг олох (technician role бүхий)
            const technicianUser = await User.findOne({ 
              role: 'technician',
              name: technician.name 
            }).or([
              { email: technician.email }
            ]);

            // Хэрэв technician user олдвол notification үүсгэх
            if (technicianUser) {
              const notification = new Notification({
                userId: technicianUser._id,
                technicianId: assignedTo,
                serviceRequestId: request._id,
                title: 'Шинэ засварын ажил томилогдлоо',
                message: `Та "${request.title}" засварын ажилд томилогдлоо. Байршил: ${request.location}`,
                type: 'assignment'
              });
              await notification.save();
              
              // Socket.IO ашиглан real-time notification илгээх
              const io = req.app.get('io');
              if (io) {
                const populatedNotification = await Notification.findById(notification._id)
                  .populate('technicianId', 'name specialization')
                  .populate('serviceRequestId', 'title type status');
                io.to(`user_${technicianUser._id}`).emit('notification', populatedNotification);
                console.log(`📤 Sent notification to user ${technicianUser._id}`);
              }
            }
          }
        } catch (notificationError) {
          // Notification илгээхэд алдаа гарвал үндсэн процесс үргэлжлүүлнэ
          console.error('Error creating notification:', notificationError);
        }
      }
    }
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

// Тайлан авах endpoint (он сараар шүүх, CSV форматаар буцаах)
router.get('/report/export', authenticateToken, async (req, res) => {
  try {
    console.log('=== Report Export Endpoint ===');
    console.log('User:', req.user);
    console.log('Query params:', req.query);
    
    const { year, month } = req.query;
    
    // Огноо шүүх query үүсгэх
    let dateQuery = {};
    if (year && month) {
      const startDate = new Date(parseInt(year), parseInt(month) - 1, 1);
      const endDate = new Date(parseInt(year), parseInt(month), 0, 23, 59, 59, 999);
      dateQuery.requestedAt = {
        $gte: startDate,
        $lte: endDate
      };
    }
    
    // Админ биш бол зөвхөн өөрийн хүсэлтүүдийг харуулах
    const query = req.user.role === 'admin' ? dateQuery : { ...dateQuery, userId: req.user.userId };

    const requests = await ServiceRequest.find(query)
      .populate('userId', 'name username')
      .populate('assignedTo', 'name specialization phone')
      .sort({ requestedAt: -1 });

    // CSV мөрүүд үүсгэх
    const csvRows = [];
    
    // CSV header (Монгол хэл дээр)
    csvRows.push('ID,Төрөл,Гарчиг,Тайлбар,Байршил,Статус,Хүсэлт гаргасан огноо,Хүлээн авсан огноо,Дууссан огноо,Хэрэглэгч,Засварчин,Тэмдэглэл,Яаралтай,Төлөвлөсөн огноо,Төлөвлөсөн цаг');
    
    // Өгөгдөл
    requests.forEach(request => {
      const row = [
        request._id || '',
        request.type || '',
        (request.title || '').replace(/,/g, ';').replace(/\n/g, ' ').replace(/"/g, '""'),
        (request.description || '').replace(/,/g, ';').replace(/\n/g, ' ').replace(/"/g, '""'),
        (request.location || '').replace(/,/g, ';').replace(/"/g, '""'),
        request.status || '',
        request.requestedAt ? new Date(request.requestedAt).toISOString() : '',
        request.acceptedAt ? new Date(request.acceptedAt).toISOString() : '',
        request.completedAt ? new Date(request.completedAt).toISOString() : '',
        request.userId?.name || request.userId?.username || '',
        request.assignedTo ? `${request.assignedTo.name} (${request.assignedTo.specialization})` : '',
        (request.notes || '').replace(/,/g, ';').replace(/\n/g, ' ').replace(/"/g, '""'),
        request.isUrgent ? 'Тийм' : 'Үгүй',
        request.scheduledDate ? new Date(request.scheduledDate).toISOString().split('T')[0] : '',
        request.scheduledTime ? new Date(request.scheduledTime).toISOString() : ''
      ];
      csvRows.push(row.map(cell => `"${cell}"`).join(','));
    });

    const csvContent = csvRows.join('\n');
    
    // CSV файл буцаах
    res.setHeader('Content-Type', 'text/csv; charset=utf-8');
    res.setHeader('Content-Disposition', `attachment; filename="duudlagiin_tailan_${year || 'all'}_${month || 'all'}.csv"`);
    
    // BOM нэмэх (Excel-д зөв харуулахын тулд)
    res.write('\ufeff');
    res.end(csvContent);
  } catch (error) {
    res.status(500).json({ error: 'Failed to export report', message: error.message });
  }
});

module.exports = router;
