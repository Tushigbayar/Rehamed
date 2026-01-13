import 'package:flutter/material.dart';
import '../models/service_request.dart';
import '../services/service_request_service.dart';
import '../main.dart';
import 'service_request_form_screen.dart';
import 'service_request_detail_screen.dart';

class ServiceRequestListScreen extends StatefulWidget {
  const ServiceRequestListScreen({super.key});

  @override
  State<ServiceRequestListScreen> createState() => _ServiceRequestListScreenState();
}

class _ServiceRequestListScreenState extends State<ServiceRequestListScreen> {
  ServiceRequestStatus? _filterStatus;

  @override
  void initState() {
    super.initState();
  }

  void _refresh() {
    setState(() {});
  }

  List<ServiceRequest> get _filteredRequests {
    final requests = ServiceRequestService.getRequests();
    if (_filterStatus == null) return requests;
    return requests.where((r) => r.status == _filterStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    final requests = _filteredRequests;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Миний дуудлагууд'),
        backgroundColor: LogoColors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Бүгд', null),
                  const SizedBox(width: 8),
                  _buildFilterChip('Хүлээгдэж байна', ServiceRequestStatus.pending),
                  const SizedBox(width: 8),
                  _buildFilterChip('Засварлаж байна', ServiceRequestStatus.inProgress),
                  const SizedBox(width: 8),
                  _buildFilterChip('Дууссан', ServiceRequestStatus.completed),
                ],
              ),
            ),
          ),
          Expanded(
            child: requests.isEmpty
                ? const Center(
                    child: Text('Дуудлага олдсонгүй'),
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      _refresh();
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: requests.length,
                      itemBuilder: (context, index) {
                        return _buildRequestCard(context, requests[index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ServiceRequestFormScreen(),
            ),
          );
          if (result == true) {
            _refresh();
          }
        },
        backgroundColor: LogoColors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterChip(String label, ServiceRequestStatus? status) {
    final isSelected = _filterStatus == status;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filterStatus = selected ? status : null;
        });
      },
      selectedColor: LogoColors.blue.withOpacity(0.2),
      checkmarkColor: LogoColors.blue,
    );
  }

  Widget _buildRequestCard(BuildContext context, ServiceRequest request) {
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

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ServiceRequestDetailScreen(requestId: request.id),
            ),
          );
          if (result == true) {
            _refresh();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
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
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (request.isUrgent)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: LogoColors.red,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'ЯАРАЛТАЙ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      request.typeLabel,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${request.requestedAt.year}-${request.requestedAt.month.toString().padLeft(2, '0')}-${request.requestedAt.day.toString().padLeft(2, '0')} ${request.requestedAt.hour.toString().padLeft(2, '0')}:${request.requestedAt.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    if (request.assignedTo != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.person, size: 12, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Засварчин томилогдсон',
                              style: TextStyle(
                                color: LogoColors.blue,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      request.statusLabel,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (request.assignedTo != null)
                    Icon(Icons.person, color: LogoColors.blue, size: 16),
                  const SizedBox(height: 4),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
