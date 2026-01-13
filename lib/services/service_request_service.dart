import '../models/service_request.dart';
import 'auth_service.dart';

class ServiceRequestService {
  static final List<ServiceRequest> _requests = [];

  static List<ServiceRequest> getRequests() {
    if (AuthService.currentUserId == null) return [];
    return _requests.where((r) => r.userId == AuthService.currentUserId).toList();
  }

  static List<ServiceRequest> getAllRequests() {
    return _requests;
  }

  static void addRequest(ServiceRequest request) {
    _requests.add(request);
  }

  static void updateRequest(ServiceRequest updatedRequest) {
    final index = _requests.indexWhere((r) => r.id == updatedRequest.id);
    if (index != -1) {
      _requests[index] = updatedRequest;
    }
  }

  static void deleteRequest(String id) {
    _requests.removeWhere((r) => r.id == id);
  }

  static ServiceRequest? getRequestById(String id) {
    try {
      return _requests.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<ServiceRequest> getRequestsByStatus(ServiceRequestStatus status) {
    return _requests.where((r) => r.status == status).toList();
  }
}
