import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pass_gen/domain/entities/category.dart';
import 'package:pass_gen/domain/repositories/category_repository.dart';
import 'package:pass_gen/domain/usecases/category/create_category_usecase.dart';

import 'create_category_usecase_test.mocks.dart';

@GenerateMocks([CategoryRepository])
void main() {
  late CreateCategoryUseCase useCase;
  late MockCategoryRepository mockRepository;

  setUp(() {
    mockRepository = MockCategoryRepository();
    useCase = CreateCategoryUseCase(mockRepository);
  });

  group('CreateCategoryUseCase', () {
    test('должен создать новую категорию', () async {
      // Arrange
      final newCategory = Category(
        name: 'Тестовая категория',
        icon: '🧪',
        isSystem: false,
        createdAt: DateTime(2024, 1, 1),
      );

      final createdCategory = Category(
        id: 100,
        name: 'Тестовая категория',
        icon: '🧪',
        isSystem: false,
        createdAt: DateTime(2024, 1, 1),
      );

      when(mockRepository.create(newCategory)).thenAnswer((_) async => createdCategory);

      // Act
      final result = await useCase.execute(newCategory);

      // Assert
      expect(result, equals(createdCategory));
      expect(result.id, equals(100));
      verify(mockRepository.create(newCategory)).called(1);
    });

    test('должен создать категорию без иконки', () async {
      // Arrange
      final newCategory = Category(
        name: 'Категория без иконки',
        isSystem: false,
        createdAt: DateTime(2024, 1, 1),
      );

      final createdCategory = Category(
        id: 101,
        name: 'Категория без иконки',
        icon: null,
        isSystem: false,
        createdAt: DateTime(2024, 1, 1),
      );

      when(mockRepository.create(newCategory)).thenAnswer((_) async => createdCategory);

      // Act
      final result = await useCase.execute(newCategory);

      // Assert
      expect(result, equals(createdCategory));
      expect(result.icon, isNull);
    });

    test('должен создать системную категорию', () async {
      // Arrange
      final systemCategory = Category(
        name: 'Системная',
        icon: '🔒',
        isSystem: true,
        createdAt: DateTime(2024, 1, 1),
      );

      when(mockRepository.create(systemCategory)).thenAnswer((_) async => systemCategory);

      // Act
      final result = await useCase.execute(systemCategory);

      // Assert
      expect(result.isSystem, isTrue);
      verify(mockRepository.create(systemCategory)).called(1);
    });

    test('должен вызвать repository.create с правильной категорией', () async {
      // Arrange
      final newCategory = Category(
        name: 'Новая категория',
        icon: '📁',
        isSystem: false,
        createdAt: DateTime(2024, 1, 1),
      );

      when(mockRepository.create(newCategory)).thenAnswer((_) async => newCategory);

      // Act
      await useCase.execute(newCategory);

      // Assert
      verify(mockRepository.create(newCategory)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
