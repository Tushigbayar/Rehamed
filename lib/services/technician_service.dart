import '../models/technician.dart';

class TechnicianService {
  static final List<Technician> _technicians = [
    Technician(
      id: '1',
      name: 'Мөнх-эрдэнэ',
      phone: '99112233',
      specialization: 'Цахилгаан засвар',
      email: 'Munkherdener@rehamed.mn',
    ),
    Technician(
      id: '2',
      name: 'Түшигбаяр',
      phone: '99334455',
      specialization: 'Ерөнхий засвар',
      email: 'Tushigbayar@rehamed.mn',
    ),
    Technician(
      id: '3',
      name: 'Ариунсанаа',
      phone: '99445566',
      specialization: 'Тоног төхөөрөмжийн засвар',
      email: 'Ariunsanaa@rehamed.mn',
    ),
  ];

  static List<Technician> getTechnicians() {
    return _technicians;
  }

  static Technician? getTechnicianById(String id) {
    try {
      return _technicians.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  static void addTechnician(Technician technician) {
    _technicians.add(technician);
  }
}
