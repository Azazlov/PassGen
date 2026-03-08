import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:pass_gen/domain/usecases/settings/set_setting_usecase.dart';
import 'package:pass_gen/domain/repositories/app_settings_repository.dart';

import 'set_setting_usecase_test.mocks.dart';

@GenerateMocks([AppSettingsRepository])
void main() {
  late SetSettingUseCase useCase;
  late MockAppSettingsRepository mockRepository;

  setUp(() {
    mockRepository = MockAppSettingsRepository();
    useCase = SetSettingUseCase(mockRepository);
  });

  group('SetSettingUseCase', () {
    test('должен сохранить настройку с ключом и значением', () async {
      // Arrange
      const testKey = 'pin_code';
      const testValue = '5678';
      when(mockRepository.setValue(testKey, testValue, encrypted: false))
          .thenAnswer((_) async {});

      // Act
      await useCase.execute(testKey, testValue);

      // Assert
      verify(mockRepository.setValue(testKey, testValue, encrypted: false)).called(1);
    });

    test('должен сохранить настройку с encrypted=true', () async {
      // Arrange
      const testKey = 'master_password';
      const testValue = 'secret123';
      when(mockRepository.setValue(testKey, testValue, encrypted: true))
          .thenAnswer((_) async {});

      // Act
      await useCase.execute(testKey, testValue, encrypted: true);

      // Assert
      verify(mockRepository.setValue(testKey, testValue, encrypted: true)).called(1);
    });

    test('должен сохранить настройку по умолчанию с encrypted=false', () async {
      // Arrange
      const testKey = 'theme';
      const testValue = 'light';
      when(mockRepository.setValue(testKey, testValue, encrypted: false))
          .thenAnswer((_) async {});

      // Act
      await useCase.execute(testKey, testValue);

      // Assert
      verify(mockRepository.setValue(testKey, testValue, encrypted: false)).called(1);
    });

    test('должен вызвать repository.setValue с правильными параметрами', () async {
      // Arrange
      const testKey = 'auto_lock_time';
      const testValue = '300';
      when(mockRepository.setValue(testKey, testValue, encrypted: false))
          .thenAnswer((_) async {});

      // Act
      await useCase.execute(testKey, testValue);

      // Assert
      verify(mockRepository.setValue(testKey, testValue, encrypted: false)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('должен работать с разными значениями', () async {
      // Arrange
      when(mockRepository.setValue('key1', 'value1', encrypted: false))
          .thenAnswer((_) async {});
      when(mockRepository.setValue('key2', 'value2', encrypted: true))
          .thenAnswer((_) async {});

      // Act
      await useCase.execute('key1', 'value1');
      await useCase.execute('key2', 'value2', encrypted: true);

      // Assert
      verify(mockRepository.setValue('key1', 'value1', encrypted: false)).called(1);
      verify(mockRepository.setValue('key2', 'value2', encrypted: true)).called(1);
    });
  });
}
