import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/password_entry.dart';
import '../entities/qr_transfer_payload.dart';

/// Интерфейс репозитория QR-обмена
abstract class QrTransferRepository {
  /// Создаёт зашифрованный payload для QR-кода
  Future<Either<Failure, QrTransferPayload>> createExportPayload(
    PasswordEntry entry,
    String transferPin, {
    int ttlSeconds = 300,
  });

  /// Декодирует payload и возвращает запись пароля
  Future<Either<Failure, PasswordEntry>> decodePayload(
    String qrData,
    String transferPin,
  );

  /// Проверяет валидность payload (TTL, формат)
  Future<Either<Failure, bool>> validatePayload(String qrData);
}
