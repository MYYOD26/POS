/// แม่แบบหลักของ Error ในระบบ
abstract class Failure {
  final String message;
  const Failure(this.message);
}

/// Error ที่เกิดจากฝั่ง Server / API
class ServerFailure extends Failure {
  const ServerFailure([String message = 'Server error occurred']) : super(message);
}

/// Error ที่เกิดจากฝั่ง Local Database / Cache
class CacheFailure extends Failure {
  const CacheFailure([String message = 'Cache error occurred']) : super(message);
}

/// Error ที่เกิดจากการเชื่อมต่ออินเทอร์เน็ต
class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'No internet connection']) : super(message);
}