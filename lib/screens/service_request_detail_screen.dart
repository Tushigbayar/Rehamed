import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../models/service_request.dart';
import '../models/technician.dart';
import '../services/service_request_service.dart';
import '../services/technician_service.dart';
import '../main.dart';
import 'service_request_edit_screen.dart';

class ServiceRequestDetailScreen extends StatefulWidget {
  final String requestId;

  const ServiceRequestDetailScreen({super.key, required this.requestId});

  @override
  State<ServiceRequestDetailScreen> createState() => _ServiceRequestDetailScreenState();
}

class _ServiceRequestDetailScreenState extends State<ServiceRequestDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ServiceRequest?>(
      future: ServiceRequestService.getRequestById(widget.requestId),
      builder: (context, requestSnapshot) {
        if (requestSnapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Дуудлагын дэлгэрэнгүй'),
              backgroundColor: LogoColors.blue,
              foregroundColor: Colors.white,
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        
        final request = requestSnapshot.data;
        
        if (request == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Алдаа')),
            body: const Center(child: Text('Дуудлага олдсонгүй')),
          );
        }

        Color statusColor;
        IconData statusIcon;
        
        switch (request.status) {
          case ServiceRequestStatus.pending:
            statusColor = LogoColors.amber;
            statusIcon = Icons.pending;
            break;
          case ServiceRequestStatus.accepted:
          case ServiceRequestStatus.inProgress:
            statusColor = LogoColors.blue;
            statusIcon = Icons.work;
            break;
          case ServiceRequestStatus.completed:
            statusColor = LogoColors.green;
            statusIcon = Icons.check_circle;
            break;
          case ServiceRequestStatus.cancelled:
            statusColor = LogoColors.red;
            statusIcon = Icons.cancel;
            break;
        }

        return FutureBuilder<Technician?>(
          future: request.assignedTo != null
              ? TechnicianService.getTechnicianById(request.assignedTo!)
              : Future.value(null),
          builder: (context, technicianSnapshot) {
            final technician = technicianSnapshot.data;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Дуудлагын дэлгэрэнгүй'),
        backgroundColor: LogoColors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ServiceRequestEditScreen(request: request),
                ),
              );
              if (result == true && context.mounted) {
                Navigator.pop(context, true);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            request.isUrgent ? Icons.emergency : statusIcon,
                            color: statusColor,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      request.title,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (request.isUrgent)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: LogoColors.red,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'ЯАРАЛТАЙ',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: () => _showStatusChangeDialog(context, request),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: statusColor.withOpacity(0.3)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        request.statusLabel,
                                        style: TextStyle(
                                          color: statusColor,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(Icons.edit, size: 14, color: statusColor),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              'Төрөл',
              request.typeLabel,
              Icons.category,
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              'Байршил',
              request.location,
              Icons.location_on,
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              'Илгээсэн огноо',
              DateFormat('yyyy-MM-dd HH:mm').format(request.requestedAt),
              Icons.calendar_today,
            ),
            if (request.acceptedAt != null) ...[
              const SizedBox(height: 12),
              _buildInfoCard(
                'Хүлээн авсан огноо',
                DateFormat('yyyy-MM-dd HH:mm').format(request.acceptedAt!),
                Icons.check_circle,
              ),
            ],
            if (request.completedAt != null) ...[
              const SizedBox(height: 12),
              _buildInfoCard(
                'Дууссан огноо',
                DateFormat('yyyy-MM-dd HH:mm').format(request.completedAt!),
                Icons.done_all,
              ),
            ],
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
                        Row(
                          children: [
                            Icon(Icons.person, color: LogoColors.blue, size: 24),
                            const SizedBox(width: 8),
                            const Text(
                              'Ажиллаж буй ажилтан',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.person_add, color: LogoColors.blue),
                          onPressed: () => _showTechnicianMentionDialog(context, request),
                          tooltip: 'Засварчин томилох',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (technician != null) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: LogoColors.blue.withOpacity(0.1),
                            child: Icon(
                              Icons.person,
                              color: LogoColors.blue,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  technician.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  technician.specialization,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Text(
                                      technician.phone,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                if (technician.email != null) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.email, size: 16, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      Text(
                                        technician.email!,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(
                          child: Text(
                            'Засварчин томилогдоогүй байна',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (request.scheduledDate != null) ...[
              const SizedBox(height: 12),
              _buildInfoCard(
                'Төлөвлөсөн огноо',
                DateFormat('yyyy-MM-dd').format(request.scheduledDate!),
                Icons.schedule,
              ),
            ],
            if (request.scheduledTime != null) ...[
              const SizedBox(height: 12),
              _buildInfoCard(
                'Төлөвлөсөн цаг',
                DateFormat('HH:mm').format(request.scheduledTime!),
                Icons.access_time,
              ),
            ],
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.description, color: LogoColors.blue),
                        const SizedBox(width: 8),
                        const Text(
                          'Дэлгэрэнгүй',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      request.description,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            if (request.notes != null && request.notes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.note, color: LogoColors.amber),
                          const SizedBox(width: 8),
                          const Text(
                            'Тэмдэглэл',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        request.notes!,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (request.images != null && request.images!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.photo, color: LogoColors.green),
                          const SizedBox(width: 8),
                          const Text(
                            'Зураг',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 1.0,
                        ),
                        itemCount: request.images!.length,
                        itemBuilder: (context, index) {
                          return AspectRatio(
                            aspectRatio: 1.0,
                            child: GestureDetector(
                              onTap: () {
                                _showImageDialog(context, request.images![index]);
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(request.images![index]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
            );
          },
        );
      },
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: LogoColors.blue),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _showImageDialog(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                title: const Text('Зураг'),
                backgroundColor: LogoColors.blue,
                foregroundColor: Colors.white,
              ),
              Flexible(
                child: SingleChildScrollView(
                  child: Image.file(
                    File(imagePath),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Хаах'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStatusChangeDialog(BuildContext context, ServiceRequest request) async {
    ServiceRequestStatus selectedStatus = request.status;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Төлөв өөрчлөх'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ServiceRequestStatus.values.map((status) {
              String label;
              Color color;
              switch (status) {
                case ServiceRequestStatus.pending:
                  label = 'Хүлээгдэж байна';
                  color = LogoColors.amber;
                  break;
                case ServiceRequestStatus.accepted:
                  label = 'Хүлээн авсан';
                  color = LogoColors.blue;
                  break;
                case ServiceRequestStatus.inProgress:
                  label = 'Засварлаж байна';
                  color = LogoColors.blue;
                  break;
                case ServiceRequestStatus.completed:
                  label = 'Дууссан';
                  color = LogoColors.green;
                  break;
                case ServiceRequestStatus.cancelled:
                  label = 'Цуцлагдсан';
                  color = LogoColors.red;
                  break;
              }
              return RadioListTile<ServiceRequestStatus>(
                title: Text(label),
                value: status,
                groupValue: selectedStatus,
                activeColor: color,
                onChanged: (value) {
                  if (value != null) {
                    setDialogState(() {
                      selectedStatus = value;
                    });
                  }
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Цуцлах'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedStatus != request.status) {
                  final updatedRequest = ServiceRequest(
                    id: request.id,
                    userId: request.userId,
                    type: request.type,
                    title: request.title,
                    description: request.description,
                    location: request.location,
                    status: selectedStatus,
                    requestedAt: request.requestedAt,
                    acceptedAt: selectedStatus != ServiceRequestStatus.pending 
                        ? (request.acceptedAt ?? DateTime.now())
                        : null,
                    completedAt: selectedStatus == ServiceRequestStatus.completed
                        ? DateTime.now()
                        : request.completedAt,
                    assignedTo: request.assignedTo,
                    notes: request.notes,
                    images: request.images,
                    isUrgent: request.isUrgent,
                    scheduledDate: request.scheduledDate,
                    scheduledTime: request.scheduledTime,
                  );
                  
                  await ServiceRequestService.updateRequest(updatedRequest);
                  
                  if (context.mounted) {
                    setState(() {});
                  }
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Төлөв амжилттай өөрчлөгдлөө'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: LogoColors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Хадгалах'),
            ),
          ],
        ),
      ),
    );
  }

  void _showTechnicianMentionDialog(BuildContext context, ServiceRequest request) async {
    final technicians = await TechnicianService.getTechnicians();
    Technician? selectedTechnician = request.assignedTo != null
        ? await TechnicianService.getTechnicianById(request.assignedTo!)
        : null;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Засварчин томилох'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: technicians.length,
              itemBuilder: (context, index) {
                final tech = technicians[index];
                final isSelected = selectedTechnician?.id == tech.id;
                
                return RadioListTile<Technician>(
                  title: Text(tech.name),
                  subtitle: Text('${tech.specialization} - ${tech.phone}'),
                  value: tech,
                  groupValue: selectedTechnician,
                  activeColor: LogoColors.blue,
                  onChanged: (value) {
                    setDialogState(() {
                      selectedTechnician = value;
                    });
                  },
                  selected: isSelected,
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setDialogState(() {
                  selectedTechnician = null;
                });
              },
              child: const Text('Томилолтыг цуцлах'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Цуцлах'),
            ),
            ElevatedButton(
              onPressed: () async {
                final updatedRequest = ServiceRequest(
                  id: request.id,
                  userId: request.userId,
                  type: request.type,
                  title: request.title,
                  description: request.description,
                  location: request.location,
                  status: request.status,
                  requestedAt: request.requestedAt,
                  acceptedAt: request.acceptedAt,
                  completedAt: request.completedAt,
                  assignedTo: selectedTechnician?.id,
                  notes: request.notes,
                  images: request.images,
                  isUrgent: request.isUrgent,
                  scheduledDate: request.scheduledDate,
                  scheduledTime: request.scheduledTime,
                );
                
                await ServiceRequestService.updateRequest(updatedRequest);
                
                if (context.mounted) {
                  setState(() {});
                }
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(selectedTechnician != null
                        ? '${selectedTechnician!.name} ажилтан томилогдлоо'
                        : 'Томилолт цуцлагдлаа'),
                    backgroundColor: Colors.green,
                  ),
                );
                
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: LogoColors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Хадгалах'),
            ),
          ],
        ),
      ),
    );
  }
}
