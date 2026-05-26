import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dashboard_provider.g.dart';

@riverpod
class DashboardNav extends _$DashboardNav {
  @override
  int build() {
    return 0; // ค่าเริ่มต้นคือ Index 0 (หน้า POS)
  }

  void setIndex(int index) {
    state = index;
  }
}