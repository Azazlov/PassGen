import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pass_gen/domain/repositories/app_settings_repository.dart';
import 'package:pass_gen/domain/usecases/settings/get_setting_usecase.dart';

import 'get_setting_usecase_test.mocks.dart';

@GenerateMocks([AppSettingsRepository])
void main() {
  late GetSettingUseCase useCase;
  late MockAppSettingsRepository mockRepository;

  setUp(() {
    mockRepository = MockAppSettingsRepository();
    useCase = GetSettingUseCase(mockRepository);
  });

  group('GetSettingUseCase', () {
    test('должен вернуть значение настройки по ключу', () async {
      // Arrange
      const testKey = 'pin_code';
      const testValue = '1234';
      when(mockRepository.getValue(testKey)).thenAnswer((_) async => testValue);

      // Act
      final result = await useCase.execute(testKey);

      // Assert
      expect(result, equals(testValue));
      verify(mockRepository.getValue(testKey)).called(1);
    });

    test('должен вернуть null для несуществующего ключа', () async {
      // Arrange
      const unknownKey = 'unknown_key';
      when(mockRepository.getValue(unknownKey)).thenAnswer((_) async => null);

      // Act
      final result = await useCase.execute(unknownKey);

      // Assert
      expect(result, isNull);
      verify(mockRepository.getValue(unknownKey)).called(1);
    });

    test('должен вернуть значение с пробелами', () async {
      // Arrange
      const testKey = 'app_name';
      const testValue = 'PassGen Pro';
      when(mockRepository.getValue(testKey)).thenAnswer((_) async => testValue);

      // Act
      final result = await useCase.execute(testKey);

      // Assert
      expect(result, equals(testValue));
    });

    test('должен вызвать repository.getValue с правильным ключом', () async {
      // Arrange
      const testKey = 'theme';
      when(mockRepository.getValue(testKey)).thenAnswer((_) async => 'dark');

      // Act
      await useCase.execute(testKey);

      // Assert
      verify(mockRepository.getValue(testKey)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('должен работать с разными ключами', () async {
      // Arrange
      when(mockRepository.getValue('key1')).thenAnswer((_) async => 'value1');
      when(mockRepository.getValue('key2')).thenAnswer((_) async => 'value2');

      // Act
      final result1 = await useCase.execute('key1');
      final result2 = await useCase.execute('key2');

      // Assert
      expect(result1, equals('value1'));
      expect(result2, equals('value2'));
    });
  });
}
