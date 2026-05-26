import '../errors/failures.dart';

/// BaseUseCase บังคับให้ทุก Business Logic ต้องทำงานเหมือนกัน
/// [Type] คือ ชนิดข้อมูลที่จะคืนค่ากลับไปเมื่อสำเร็จ (เช่น User, Token, bool)
/// [Params] คือ สิ่งที่ต้องส่งเข้ามาเพื่อประมวลผล (เช่น Email, Password)
abstract class BaseUseCase<Type, Params> {
  // คืนค่าเป็น Record (Failure?, Type?)
  // ถ้าพัง Failure จะมีค่า / ถ้าสำเร็จ Type จะมีค่า
  Future<(Failure?, Type?)> call(Params params);
}

/// คลาสว่างๆ สำหรับ UseCase ที่ไม่ต้องส่งพารามิเตอร์ใดๆ เข้ามา (เช่น GetProfileUseCase)
class NoParams {
  const NoParams();
}