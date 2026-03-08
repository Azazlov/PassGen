import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:pass_gen/domain/usecases/log/get_logs_usecase.dart';
import 'package:pass_gen/domain/repositories/security_log_repository.dart';
import 'package:pass_gen/domain/entities/security_log.dart';

import 'get_logs_usecase_test.mocks.dart';

@GenerateMocks([SecurityLogRepository])
void main() {
  late GetLogsUseCase useCase;
  late MockSecurityLogRepository mockRepository;

  setUp(() {
    mockRepository = MockSecurityLogRepository();
    useCase = GetLogsUseCase(mockRepository);
  });

  group('GetLogsUseCase', () {
    test('должен вернуть список логов', () async {
      // Arrange
      final testLogs = [
        SecurityLog(actionType: 'AUTH_SUCCESS', timestamp: DateTime(2024, 1, 1)),
        SecurityLog(actionType: 'PWD_CREATED', timestamp: DateTime(2024, 1, 2)),
        SecurityLog(actionType: 'DATA_EXPORT', timestamp: DateTime(2024, 1, 3)),
      ];

      when(mockRepository.getLogs(limit: 1000)).thenAnswer((_) async => testLogs);

      // Act
      final result = await useCase.execute();

      // Assert
      expect(result, equals(testLogs));
      expect(result.length, equals(3));
      verify(mockRepository.getLogs(limit: 1000)).called(1);
    });

    test('должен вернуть пустой список, если логов нет', () async {
      // Arrange
      when(mockRepository.getLogs(limit: 1000)).thenAnswer((_) async => []);

      // Act
      final result = await useCase.execute();

      // Assert
      expect(result, isEmpty);
      verify(mockRepository.getLogs(limit: 1000)).called(1);
    });

    test('должен вернуть логи с указанным лимитом', () async {
      // Arrange
      final testLogs = [
        SecurityLog(actionType: 'AUTH_SUCCESS', timestamp: DateTime(2024, 1, 1)),
      ];

      when(mockRepository.getLogs(limit: 10)).thenAnswer((_) async => testLogs);

      // Act
      final result = await useCase.execute(limit: 10);

      // Assert
      expect(result, equals(testLogs));
      verify(mockRepository.getLogs(limit: 10)).called(1);
    });

    test('должен вернуть логи с деталями', () async {
      // Arrange
      final logWithDetails = SecurityLog(
        actionType: 'PWD_CREATED',
        timestamp: DateTime(2024, 1, 1),
        details: '{"service": "Gmail"}',
      );

      when(mockRepository.getLogs(limit: 1000)).thenAnswer((_) async => [logWithDetails]);

      // Act
      final result = await useCase.execute();

      // Assert
      expect(result.length, equals(1));
      expect(result.first.details, isNotNull);
    });

    test('должен вызвать repository.getLogs с лимитом по умолчанию', () async {
      // Arrange
      when(mockRepository.getLogs(limit: 1000)).thenAnswer((_) async => []);

      // Act
      await useCase.execute();

      // Assert
      verify(mockRepository.getLogs(limit: 1000)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
