import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pass_gen/domain/repositories/security_log_repository.dart';
import 'package:pass_gen/domain/usecases/log/log_event_usecase.dart';

import 'log_event_usecase_test.mocks.dart';

@GenerateMocks([SecurityLogRepository])
void main() {
  late LogEventUseCase useCase;
  late MockSecurityLogRepository mockRepository;

  setUp(() {
    mockRepository = MockSecurityLogRepository();
    useCase = LogEventUseCase(mockRepository);
  });

  group('LogEventUseCase', () {
    test('должен залогировать событие с типом действия', () async {
      // Arrange
      const actionType = 'AUTH_SUCCESS';
      when(mockRepository.logEvent(actionType, details: null))
          .thenAnswer((_) async {});

      // Act
      await useCase.execute(actionType);

      // Assert
      verify(mockRepository.logEvent(actionType, details: null)).called(1);
    });

    test('должен залогировать событие с деталями', () async {
      // Arrange
      const actionType = 'PWD_CREATED';
      final details = {'service': 'Gmail', 'password_id': 123};
      when(mockRepository.logEvent(actionType, details: details))
          .thenAnswer((_) async {});

      // Act
      await useCase.execute(actionType, details: details);

      // Assert
      verify(mockRepository.logEvent(actionType, details: details)).called(1);
    });

    test('должен залогировать событие DATA_EXPORT', () async {
      // Arrange
      const actionType = 'DATA_EXPORT';
      final details = {'format': 'JSON', 'count': 10};
      when(mockRepository.logEvent(actionType, details: details))
          .thenAnswer((_) async {});

      // Act
      await useCase.execute(actionType, details: details);

      // Assert
      verify(mockRepository.logEvent(actionType, details: details)).called(1);
    });

    test('должен залогировать событие SETTINGS_CHG', () async {
      // Arrange
      const actionType = 'SETTINGS_CHG';
      final details = {'setting': 'pin_code', 'changed': true};
      when(mockRepository.logEvent(actionType, details: details))
          .thenAnswer((_) async {});

      // Act
      await useCase.execute(actionType, details: details);

      // Assert
      verify(mockRepository.logEvent(actionType, details: details)).called(1);
    });

    test('должен вызвать repository.logEvent с правильными параметрами', () async {
      // Arrange
      const actionType = 'AUTH_FAILURE';
      when(mockRepository.logEvent(actionType, details: null))
          .thenAnswer((_) async {});

      // Act
      await useCase.execute(actionType);

      // Assert
      verify(mockRepository.logEvent(actionType, details: null)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
