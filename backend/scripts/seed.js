// Seed script - анхны өгөгдөл бэлтгэх скрипт
// Энэ файл нь MongoDB-д анхны тест өгөгдлүүдийг (хэрэглэгч, засварчин, мэдэгдэл) үүсгэдэг

const mongoose = require('mongoose');
const dotenv = require('dotenv');
// bcrypt шаардлагагүй - User модел дээрх pre-save middleware нууц үгийг автоматаар hash хийх болно
const User = require('../models/User');
const Technician = require('../models/Technician');
const Announcement = require('../models/Announcement');

dotenv.config();

// MongoDB холболтын URL
const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/rehamed';

// Анхны өгөгдөл үүсгэх функц
async function seed() {
  try {
    // MongoDB-д холбогдох
    await mongoose.connect(MONGODB_URI);
    console.log('Connected to MongoDB');

    // Одоо байгаа өгөгдлүүдийг устгах (цэвэрлэх)
    await User.deleteMany({});
    await Technician.deleteMany({});
    await Announcement.deleteMany({});

    // Админ хэрэглэгч үүсгэх
    // Нууц үгийг шууд дамжуулна - User модел дээрх pre-save middleware автоматаар hash хийх болно
    const admin = await User.create({
      username: 'admin',
      password: 'admin123', // pre-save middleware автоматаар hash хийх болно
      name: 'Админ',
      role: 'admin',
      email: 'admin@rehamed.mn'
    });
    console.log('Created admin user:', admin.username);

    // Энгийн хэрэглэгч үүсгэх
    // Нууц үгийг шууд дамжуулна - User модел дээрх pre-save middleware автоматаар hash хийх болно
    const user = await User.create({
      username: 'user',
      password: 'user123', // pre-save middleware автоматаар hash хийх болно
      name: 'Хэрэглэгч',
      role: 'user',
      email: 'user@rehamed.mn'
    });
    console.log('Created user:', user.username);

    // Засварчдын мэдээлэл үүсгэх
    const technicians = await Technician.create([
      {
        name: 'Мөнх-эрдэнэ',
        phone: '99112233',
        specialization: 'Цахилгаан засвар',
        email: 'Munkherdener@rehamed.mn',
      },
      {
        name: 'Түшигбаяр',
        phone: '99334455',
        specialization: 'Ерөнхий засвар',
        email: 'Tushigbayar@rehamed.mn',
      },
      {
        name: 'Ариунсанаа',
        phone: '99445566',
        specialization: 'Тоног төхөөрөмжийн засвар',
        email: 'Ariunsanaa@rehamed.mn',
      },
    ]);
    console.log('Created', technicians.length, 'technicians');

    // Мэдэгдлүүд үүсгэх
    const announcements = await Announcement.create([
      {
        title: 'Засвар үйлчилгээний цагийн хуваарь',
        content: 'Энэ сарын 15-наас эхлэн засвар үйлчилгээний цагийн хуваарь өөрчлөгдлөө. Дэлгэрэнгүй мэдээллийг удирдлагаас асууна уу.',
        createdAt: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000), // 2 өдрийн өмнөх огноо
        isImportant: true,
        author: 'Удирдлага',
      },
      {
        title: 'Шинэ засварчдын нэмэлт',
        content: 'Манай багт 2 шинэ засварчин нэгдлээ. Тэдний мэдээллийг системээс харна уу.',
        createdAt: new Date(Date.now() - 5 * 24 * 60 * 60 * 1000), // 5 өдрийн өмнөх огноо
        isImportant: false,
        author: 'Хүний нөөцийн хэлтэс',
      },
      {
        title: 'Яаралтай дуудлагын дүрэм',
        content: 'Яаралтай дуудлага өгөхдөө байршил, дэлгэрэнгүй мэдээллийг бүрэн оруулна уу.',
        createdAt: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000), // 7 өдрийн өмнөх огноо
        isImportant: true,
        author: 'Удирдлага',
      },
    ]);
    console.log('Created', announcements.length, 'announcements');

    // Амжилттай дууссан мэдээлэл хэвлэх
    console.log('\nSeed completed successfully!');
    console.log('\nTest accounts:');
    console.log('Admin - username: admin, password: admin123');
    console.log('User - username: user, password: user123');

    // MongoDB холболтыг хаах
    await mongoose.connection.close();
    process.exit(0); // Амжилттай дууссан
  } catch (error) {
    console.error('Seed error:', error);
    await mongoose.connection.close();
    process.exit(1); // Алдаа гарсан
  }
}

// Seed функцийг дуудах
seed();
