/// รวบรวมเส้นทางทั้งหมดในแอปพลิเคชัน
enum AppRoute {
  splash(path: '/'),
  login(path: '/login'),
  dashboard(path: '/dashboard'),
  pos(path: '/pos'); // หน้าจอเครื่องคิดเงิน

  const AppRoute({required this.path});
  final String path;
}