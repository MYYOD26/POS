class AppConstants {
  // TODO: เปลี่ยน URL เป็น API ของ Backend (PostgreSQL/NestJS/Go) ของคุณ
  static const String baseUrl = 'https://api.example.com/v1'; 
  
  // Timeout settings ป้องกันแอปค้างเวลาเน็ตหลุด
  static const int connectionTimeout = 15000; // 15 วินาที
  static const int receiveTimeout = 15000;
}