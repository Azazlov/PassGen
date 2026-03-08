import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:pass_gen/domain/usecases/category/update_category_usecase.dart';
import 'package:pass_gen/domain/repositories/category_repository.dart';
import 'package:pass_gen/domain/entities/category.dart';

import 'update_category_usecase_test.mocks.dart';

@GenerateMocks([CategoryRepository])
void main() {
  late UpdateCategoryUseCase useCase;
  late MockCategoryRepository mockRepository;

  setUp(() {
    mockRepository = MockCategoryRepository();
    useCase = UpdateCategoryUseCase(mockRepository);
  });

  group('UpdateCategoryUseCase', () {
    test('должен обновить существующую категорию', () async {
      // Arrange
      final oldCategory = Category(
        id: 1,
        name: 'Старое название',
        icon: '📁',
        isSystem: false,
        createdAt: DateTime(2024, 1, 1),
      );

      final updatedCategory = Category(
        id: 1,
        name: 'Новое название',
        icon: '📂',
        isSystem: false,
        createdAt: DateTime(2024, 1, 1),
      );

      when(mockRepository.update(oldCategory)).thenAnswer((_) async => updatedCategory);

      // Act
      final result = await useCase.execute(oldCategory);

      // Assert
      expect(result, equals(updatedCategory));
      expect(result.name, equals('Новое название'));
      expect(result.icon, equals('📂'));
      verify(mockRepository.update(oldCategory)).called(1);
    });

    test('должен обновить только название категории', () async {
      // Arrange
      final category = Category(
        id: 2,
        name: 'Обновлённая',
        icon: '🔧',
        isSystem: false,
        createdAt: DateTime(2024, 1, 1),
      );

      when(mockRepository.update(category)).thenAnswer((_) async => category);

      // Act
      final result = await useCase.execute(category);

      // Assert
      expect(result.name, equals('Обновлённая'));
      expect(result.icon, equals('🔧'));
    });

    test('должен сохранить isSystem флаг при обновлении', () async {
      // Arrange
      final systemCategory = Category(
        id: 3,
        name: 'Системная обновлённая',
        icon: '🔐',
        isSystem: true,
        createdAt: DateTime(2024, 1, 1),
      );

      when(mockRepository.update(systemCategory)).thenAnswer((_) async => systemCategory);

      // Act
      final result = await useCase.execute(systemCategory);

      // Assert
      expect(result.isSystem, isTrue);
    });

    test('должен вызвать repository.update с правильной категорией', () async {
      // Arrange
      final category = Category(
        id: 4,
        name: 'Тест',
        icon: '🧪',
        isSystem: false,
        createdAt: DateTime(2024, 1, 1),
      );

      when(mockRepository.update(category)).thenAnswer((_) async => category);

      // Act
      await useCase.execute(category);

      // Assert
      verify(mockRepository.update(category)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
