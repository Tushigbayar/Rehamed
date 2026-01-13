enum ServiceRequestType {
  emergency,
  maintenance,
  cleaning,
  equipment,
  other,
}

enum ServiceRequestStatus {
  pending,
  accepted,
  inProgress,
  completed,
  cancelled,
}

class ServiceRequest {
  final String id;
  final String userId;
  final ServiceRequestType type;
  final String title;
  final String description;
  final String location;
  ServiceRequestStatus status;
  final DateTime requestedAt;
  DateTime? acceptedAt;
  DateTime? completedAt;
  String? assignedTo;
  String? notes;
  List<String>? images;
  final bool isUrgent;
  DateTime? scheduledDate;
  DateTime? scheduledTime;

  ServiceRequest({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.description,
    required this.location,
    this.status = ServiceRequestStatus.pending,
    required this.requestedAt,
    this.acceptedAt,
    this.completedAt,
    this.assignedTo,
    this.notes,
    this.images,
    this.isUrgent = false,
    this.scheduledDate,
    this.scheduledTime,
  });

  String get typeLabel {
    switch (type) {
      case ServiceRequestType.emergency:
        return 'Яаралтай';
      case ServiceRequestType.maintenance:
        return 'Засвар';
      case ServiceRequestType.cleaning:
        return 'Цэвэрлэгээ';
      case ServiceRequestType.equipment:
        return 'Тоног төхөөрөмж';
      case ServiceRequestType.other:
        return 'Бусад';
    }
  }

  String get statusLabel {
    switch (status) {
      case ServiceRequestStatus.pending:
        return 'Хүлээгдэж байна';
      case ServiceRequestStatus.accepted:
        return 'Хүлээн авсан';
      case ServiceRequestStatus.inProgress:
        return 'Явж байна';
      case ServiceRequestStatus.completed:
        return 'Дууссан';
      case ServiceRequestStatus.cancelled:
        return 'Цуцлагдсан';
    }
  }
}
