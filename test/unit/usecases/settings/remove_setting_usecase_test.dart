import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pass_gen/domain/repositories/app_settings_repository.dart';
import 'package:pass_gen/domain/usecases/settings/remove_setting_usecase.dart';

import 'remove_setting_usecase_test.mocks.dart';

@GenerateMocks([AppSettingsRepository])
void main() {
  late RemoveSettingUseCase useCase;
  late MockAppSettingsRepository mockRepository;

  setUp(() {
    mockRepository = MockAppSettingsRepository();
    useCase = RemoveSettingUseCase(mockRepository);
  });

  group('RemoveSettingUseCase', () {
    const testKey = 'old_setting';

    test('должен удалить настройку по ключу', () async {
      // Arrange
      when(mockRepository.remove(testKey)).thenAnswer((_) async {});

      // Act
      await useCase.execute(testKey);

      // Assert
      verify(mockRepository.remove(testKey)).called(1);
    });

    test('должен удалить настройку с другим ключом', () async {
      // Arrange
      const anotherKey = 'another_key';
      when(mockRepository.remove(anotherKey)).thenAnswer((_) async {});

      // Act
      await useCase.execute(anotherKey);

      // Assert
      verify(mockRepository.remove(anotherKey)).called(1);
    });

    test('должен вызвать repository.remove с правильным ключом', () async {
      // Arrange
      when(mockRepository.remove(testKey)).thenAnswer((_) async {});

      // Act
      await useCase.execute(testKey);

      // Assert
      verify(mockRepository.remove(testKey)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('должен работать с несколькими ключами', () async {
      // Arrange
      when(mockRepository.remove('key1')).thenAnswer((_) async {});
      when(mockRepository.remove('key2')).thenAnswer((_) async {});

      // Act
      await useCase.execute('key1');
      await useCase.execute('key2');

      // Assert
      verify(mockRepository.remove('key1')).called(1);
      verify(mockRepository.remove('key2')).called(1);
    });
  });
}
