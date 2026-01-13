import '../models/announcement.dart';

class AnnouncementService {
  static final List<Announcement> _announcements = [
    Announcement(
      id: '1',
      title: 'Засвар үйлчилгээний цагийн хуваарь',
      content: 'Энэ сарын 15-наас эхлэн засвар үйлчилгээний цагийн хуваарь өөрчлөгдлөө. Дэлгэрэнгүй мэдээллийг удирдлагаас асууна уу.',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      isImportant: true,
      author: 'Удирдлага',
    ),
    Announcement(
      id: '2',
      title: 'Шинэ засварчдын нэмэлт',
      content: 'Манай багт 2 шинэ засварчин нэгдлээ. Тэдний мэдээллийг системээс харна уу.',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      isImportant: false,
      author: 'Хүний нөөцийн хэлтэс',
    ),
    Announcement(
      id: '3',
      title: 'Яаралтай дуудлагын дүрэм',
      content: 'Яаралтай дуудлага өгөхдөө байршил, дэлгэрэнгүй мэдээллийг бүрэн оруулна уу.',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      isImportant: true,
      author: 'Удирдлага',
    ),
  ];

  static List<Announcement> getAnnouncements() {
    return _announcements..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  static List<Announcement> getRecentAnnouncements({int limit = 5}) {
    final all = getAnnouncements();
    return all.take(limit).toList();
  }

  static void addAnnouncement(Announcement announcement) {
    _announcements.add(announcement);
  }
}
