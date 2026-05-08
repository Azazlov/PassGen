import 'dart:convert';

import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../../core/utils/qr_payload_codec.dart';
import '../../../domain/entities/password_entry.dart';
import '../../../domain/entities/qr_transfer_payload.dart';
import '../../../domain/repositories/qr_transfer_repository.dart';

/// Реализация репозитория QR-обмена
class QrTransferRepositoryImpl implements QrTransferRepository {
  QrTransferRepositoryImpl({QrPayloadCodec? codec})
      : _codec = codec ?? const QrPayloadCodec();

  final QrPayloadCodec _codec;

  @override
  Future<Either<Failure, QrTransferPayload>> createExportPayload(
    PasswordEntry entry,
    String transferPin, {
    int ttlSeconds = 300,
  }) async {
    try {
      if (transferPin.length < 4 || transferPin.length > 8) {
        return left(
          const ValidationFailure(
            message: 'Transfer PIN должен содержать 4–8 цифр',
          ),
        );
      }
      final entryJson = entry.toJson();
      // Убираем id и profile_id при передаче
      entryJson.remove('id');
      entryJson.remove('profile_id');
      final entryBytes = utf8.encode(jsonEncode(entryJson));

      final payload = await _codec.encrypt(
        entryBytes: entryBytes,
        transferPin: transferPin,
        ttlSeconds: ttlSeconds,
      );
      return right(payload);
    } on ValidationFailure catch (e) {
      return left(e);
    } catch (e) {
      return left(EncryptionFailure(message: 'Ошибка создания QR: $e'));
    }
  }

  @override
  Future<Either<Failure, PasswordEntry>> decodePayload(
    String qrData,
    String transferPin,
  ) async {
    try {
      final payload = QrTransferPayload.fromBase64Url(qrData);
      final entryBytes = await _codec.decrypt(
        payload: payload,
        transferPin: transferPin,
      );
      final json = jsonDecode(utf8.decode(entryBytes)) as Map<String, dynamic>;
      return right(PasswordEntry.fromJson(json));
    } on ValidationFailure catch (e) {
      return left(e);
    } on AuthFailure catch (e) {
      return left(e);
    } catch (e) {
      return left(EncryptionFailure(message: 'Ошибка декодирования QR: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> validatePayload(String qrData) async {
    try {
      final payload = QrTransferPayload.fromBase64Url(qrData);
      return right(!payload.isExpired);
    } catch (e) {
      return left(ValidationFailure(message: 'Неверный формат QR: $e'));
    }
  }
}
