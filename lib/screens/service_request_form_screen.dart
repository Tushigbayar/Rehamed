import 'package:flutter/material.dart';
import '../models/service_request.dart';
import '../services/service_request_service.dart';
import '../services/auth_service.dart';
import '../main.dart';

class ServiceRequestFormScreen extends StatefulWidget {
  final bool isUrgent;

  const ServiceRequestFormScreen({super.key, this.isUrgent = false});

  @override
  State<ServiceRequestFormScreen> createState() => _ServiceRequestFormScreenState();
}

class _ServiceRequestFormScreenState extends State<ServiceRequestFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  ServiceRequestType _selectedType = ServiceRequestType.maintenance;
  bool _isUrgent = false;

  @override
  void initState() {
    super.initState();
    _isUrgent = widget.isUrgent;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _submitRequest() {
    if (_formKey.currentState!.validate()) {
      final request = ServiceRequest(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: AuthService.currentUserId!,
        type: _selectedType,
        title: _titleController.text,
        description: _descriptionController.text,
        location: _locationController.text,
        status: ServiceRequestStatus.pending,
        requestedAt: DateTime.now(),
        isUrgent: _isUrgent,
      );

      ServiceRequestService.addRequest(request);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isUrgent 
            ? 'Яаралтай дуудлага амжилттай илгээгдлээ!' 
            : 'Дуудлага амжилттай илгээгдлээ!'),
          backgroundColor: LogoColors.green,
        ),
      );

      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isUrgent ? 'Яаралтай дуудлага' : 'Шинэ дуудлага'),
        backgroundColor: _isUrgent ? LogoColors.red : LogoColors.blue,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_isUrgent)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: LogoColors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: LogoColors.red, width: 2),
                ),
                child: Row(
                  children: [
                    Icon(Icons.emergency, color: LogoColors.red, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Яаралтай дуудлага',
                        style: TextStyle(
                          color: LogoColors.red,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            DropdownButtonFormField<ServiceRequestType>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Төрөл *',
                border: OutlineInputBorder(),
              ),
              items: ServiceRequestType.values.map((type) {
                String label;
                switch (type) {
                  case ServiceRequestType.emergency:
                    label = 'Яаралтай';
                    break;
                  case ServiceRequestType.maintenance:
                    label = 'Засвар';
                    break;
                  case ServiceRequestType.cleaning:
                    label = 'Цэвэрлэгээ';
                    break;
                  case ServiceRequestType.equipment:
                    label = 'Тоног төхөөрөмж';
                    break;
                  case ServiceRequestType.other:
                    label = 'Бусад';
                    break;
                }
                return DropdownMenuItem<ServiceRequestType>(
                  value: type,
                  child: Text(label),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Гарчиг *',
                hintText: 'Жишээ: Угаалгын өрөөний засвар',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Гарчиг оруулна уу';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Дэлгэрэнгүй *',
                hintText: 'Дуудлагын дэлгэрэнгүй мэдээлэл...',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Дэлгэрэнгүй мэдээлэл оруулна уу';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Байршил *',
                hintText: 'Жишээ: 2-р давхар, 201-р өрөө',
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Байршил оруулна уу';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Яаралтай дуудлага'),
              subtitle: const Text('Энэ дуудлагыг яаралтай гэж тэмдэглэх'),
              value: _isUrgent,
              activeColor: LogoColors.red,
              onChanged: (value) {
                setState(() {
                  _isUrgent = value;
                });
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitRequest,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isUrgent ? LogoColors.red : LogoColors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Дуудлага илгээх',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
