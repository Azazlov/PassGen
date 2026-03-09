import '../../entities/category.dart';
import '../../repositories/category_repository.dart';

/// Использование: Обновление категории
class UpdateCategoryUseCase {
  const UpdateCategoryUseCase(this.repository);
  final CategoryRepository repository;

  Future<Category> execute(Category category) async {
    return repository.update(category);
  }
}
