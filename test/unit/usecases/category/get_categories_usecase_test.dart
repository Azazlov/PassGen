import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pass_gen/domain/entities/category.dart';
import 'package:pass_gen/domain/repositories/category_repository.dart';
import 'package:pass_gen/domain/usecases/category/get_categories_usecase.dart';

import 'get_categories_usecase_test.mocks.dart';

@GenerateMocks([CategoryRepository])
void main() {
  late GetCategoriesUseCase useCase;
  late MockCategoryRepository mockRepository;

  setUp(() {
    mockRepository = MockCategoryRepository();
    useCase = GetCategoriesUseCase(mockRepository);
  });

  group('GetCategoriesUseCase', () {
    test('должен вернуть список всех категорий', () async {
      // Arrange
      final testCategories = [
        Category(name: 'Соцсети', icon: '👥', isSystem: true, createdAt: DateTime(2024, 1, 1)),
        Category(name: 'Почта', icon: '📧', isSystem: true, createdAt: DateTime(2024, 1, 1)),
        Category(name: 'Банки', icon: '🏦', isSystem: true, createdAt: DateTime(2024, 1, 1)),
      ];

      when(mockRepository.getAll()).thenAnswer((_) async => testCategories);

      // Act
      final result = await useCase.execute();

      // Assert
      expect(result, equals(testCategories));
      verify(mockRepository.getAll()).called(1);
    });

    test('должен вернуть пустой список, если категорий нет', () async {
      // Arrange
      when(mockRepository.getAll()).thenAnswer((_) async => []);

      // Act
      final result = await useCase.execute();

      // Assert
      expect(result, isEmpty);
      verify(mockRepository.getAll()).called(1);
    });

    test('должен вернуть только системные категории', () async {
      // Arrange
      final systemCategories = Category.systemCategories;
      when(mockRepository.getAll()).thenAnswer((_) async => systemCategories);

      // Act
      final result = await useCase.execute();

      // Assert
      expect(result.length, equals(systemCategories.length));
      expect(result.every((c) => c.isSystem), isTrue);
    });

    test('должен вызвать repository.getAll()', () async {
      // Arrange
      when(mockRepository.getAll()).thenAnswer((_) async => []);

      // Act
      await useCase.execute();

      // Assert
      verify(mockRepository.getAll()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
