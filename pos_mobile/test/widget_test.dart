import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// อิมพอร์ต PosApp จากโปรเจกต์ของคุณ
import 'package:pos_mobile/app.dart'; 

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // ต้องครอบ ProviderScope เสมอเมื่อรันเทสแอปที่ใช้ Riverpod
    await tester.pumpWidget(
      const ProviderScope(
        child: PosApp(),
      ),
    );

    // ตรวจสอบว่าหน้าจอวาด UI สำเร็จและแสดงข้อความเริ่มต้นที่เราตั้งไว้
    expect(find.text('POS System Initialized'), findsOneWidget);
  });
}