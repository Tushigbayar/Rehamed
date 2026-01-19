import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../models/service_request.dart';
import '../models/technician.dart';
import '../services/service_request_service.dart';
import '../services/technician_service.dart';
import '../main.dart';

class ServiceRequestEditScreen extends StatefulWidget {
  final ServiceRequest request;

  const ServiceRequestEditScreen({super.key, required this.request});

  @override
  State<ServiceRequestEditScreen> createState() => _ServiceRequestEditScreenState();
}

class _ServiceRequestEditScreenState extends State<ServiceRequestEditScreen> {
  late ServiceRequestStatus _status;
  Technician? _selectedTechnician;
  final TextEditingController _notesController = TextEditingController();
  DateTime? _scheduledDate;
  TimeOfDay? _scheduledTime;
  final List<String> _images = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _status = widget.request.status;
    _notesController.text = widget.request.notes ?? '';
    _scheduledDate = widget.request.scheduledDate;
    if (widget.request.scheduledTime != null) {
      _scheduledTime = TimeOfDay.fromDateTime(widget.request.scheduledTime!);
    }
    _images.addAll(widget.request.images ?? []);
    
    if (widget.request.assignedTo != null) {
      TechnicianService.getTechnicianById(widget.request.assignedTo!).then((tech) {
        if (mounted) {
          setState(() {
            _selectedTechnician = tech;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _images.add(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Зураг сонгохдоо алдаа гарлаа: $e')),
        );
      }
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() {
          _images.add(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Зураг авахад алдаа гарлаа: $e')),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _scheduledDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _scheduledDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _scheduledTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _scheduledTime = picked;
      });
    }
  }

  Future<void> _saveChanges() async {
    final updatedRequest = ServiceRequest(
      id: widget.request.id,
      userId: widget.request.userId,
      type: widget.request.type,
      title: widget.request.title,
      description: widget.request.description,
      location: widget.request.location,
      status: _status,
      requestedAt: widget.request.requestedAt,
      acceptedAt: _status != ServiceRequestStatus.pending 
          ? (widget.request.acceptedAt ?? DateTime.now())
          : null,
      completedAt: _status == ServiceRequestStatus.completed
          ? DateTime.now()
          : widget.request.completedAt,
      assignedTo: _selectedTechnician?.id,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      images: _images.isEmpty ? null : _images,
      isUrgent: widget.request.isUrgent,
      scheduledDate: _scheduledDate,
      scheduledTime: _scheduledDate != null && _scheduledTime != null
          ? DateTime(
              _scheduledDate!.year,
              _scheduledDate!.month,
              _scheduledDate!.day,
              _scheduledTime!.hour,
              _scheduledTime!.minute,
            )
          : null,
    );

    final result = await ServiceRequestService.updateRequest(updatedRequest);

    if (result['success'] == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Амжилттай хадгалагдлаа'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? 'Алдаа гарлаа'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Technician>>(
      future: TechnicianService.getTechnicians(),
      builder: (context, techniciansSnapshot) {
        final technicians = techniciansSnapshot.data ?? [];
        
        return Scaffold(
      appBar: AppBar(
        title: const Text('Дуудлага засах'),
        backgroundColor: LogoColors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Төлөв',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<ServiceRequestStatus>(
                    value: _status,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: ServiceRequestStatus.values.map((status) {
                      String label;
                      switch (status) {
                        case ServiceRequestStatus.pending:
                          label = 'Хүлээгдэж байна';
                          break;
                        case ServiceRequestStatus.accepted:
                          label = 'Хүлээн авсан';
                          break;
                        case ServiceRequestStatus.inProgress:
                          label = 'Засварлаж байна';
                          break;
                        case ServiceRequestStatus.completed:
                          label = 'Дууссан';
                          break;
                        case ServiceRequestStatus.cancelled:
                          label = 'Цуцлагдсан';
                          break;
                      }
                      return DropdownMenuItem<ServiceRequestStatus>(
                        value: status,
                        child: Text(label),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _status = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Засварчин',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<Technician>(
                    value: _selectedTechnician,
                    decoration: const InputDecoration(
                      labelText: 'Засварчин сонгох',
                      border: OutlineInputBorder(),
                    ),
                    items: technicians.map((tech) {
                      return DropdownMenuItem<Technician>(
                        value: tech,
                        child: Text('${tech.name} - ${tech.specialization}'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedTechnician = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Төлөвлөсөн огноо, цаг',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: _selectDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Огноо',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        _scheduledDate == null
                            ? 'Огноо сонгох'
                            : DateFormat('yyyy-MM-dd').format(_scheduledDate!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: _selectTime,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Цаг',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.access_time),
                      ),
                      child: Text(
                        _scheduledTime == null
                            ? 'Цаг сонгох'
                            : _scheduledTime!.format(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Тэмдэглэл',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      hintText: 'Тэмдэглэл оруулах...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 5,
                  ),
                ],
              ),
            ),
          ),
          if (_status == ServiceRequestStatus.completed) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Зураг',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.photo_library),
                              onPressed: _pickImage,
                              tooltip: 'Зураг сонгох',
                            ),
                            IconButton(
                              icon: const Icon(Icons.camera_alt),
                              onPressed: _takePhoto,
                              tooltip: 'Зураг авах',
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_images.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('Зураг оруулаагүй байна'),
                        ),
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 1.0,
                        ),
                        itemCount: _images.length,
                        itemBuilder: (context, index) {
                          return AspectRatio(
                            aspectRatio: 1.0,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    File(_images[index]),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () => _removeImage(index),
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        width: 24,
                                        height: 24,
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _saveChanges,
            style: ElevatedButton.styleFrom(
              backgroundColor: LogoColors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Хадгалах',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
        );
      },
    );
  }
}
