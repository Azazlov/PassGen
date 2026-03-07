import '../../entities/category.dart';
import '../../repositories/category_repository.dart';

/// Использование: Обновление категории
class UpdateCategoryUseCase {
  final CategoryRepository repository;

  const UpdateCategoryUseCase(this.repository);

  Future<Category> execute(Category category) async {
    return await repository.update(category);
  }
}
