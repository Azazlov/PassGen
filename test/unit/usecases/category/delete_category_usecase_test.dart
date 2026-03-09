import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pass_gen/domain/repositories/category_repository.dart';
import 'package:pass_gen/domain/usecases/category/delete_category_usecase.dart';

import 'delete_category_usecase_test.mocks.dart';

@GenerateMocks([CategoryRepository])
void main() {
  late DeleteCategoryUseCase useCase;
  late MockCategoryRepository mockRepository;

  setUp(() {
    mockRepository = MockCategoryRepository();
    useCase = DeleteCategoryUseCase(mockRepository);
  });

  group('DeleteCategoryUseCase', () {
    const testId = 1;

    test('должен удалить категорию по ID', () async {
      // Arrange
      when(mockRepository.delete(testId)).thenAnswer((_) async {});

      // Act
      await useCase.execute(testId);

      // Assert
      verify(mockRepository.delete(testId)).called(1);
    });

    test('должен удалить категорию с большим ID', () async {
      // Arrange
      const largeId = 999;
      when(mockRepository.delete(largeId)).thenAnswer((_) async {});

      // Act
      await useCase.execute(largeId);

      // Assert
      verify(mockRepository.delete(largeId)).called(1);
    });

    test('должен вызвать repository.delete с правильным ID', () async {
      // Arrange
      when(mockRepository.delete(testId)).thenAnswer((_) async {});

      // Act
      await useCase.execute(testId);

      // Assert
      verify(mockRepository.delete(testId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('должен работать с разными ID', () async {
      // Arrange
      when(mockRepository.delete(5)).thenAnswer((_) async {});
      when(mockRepository.delete(10)).thenAnswer((_) async {});

      // Act
      await useCase.execute(5);
      await useCase.execute(10);

      // Assert
      verify(mockRepository.delete(5)).called(1);
      verify(mockRepository.delete(10)).called(1);
    });
  });
}
