import '../../entities/category.dart';
import '../../repositories/category_repository.dart';

/// Использование: Создание категории
class CreateCategoryUseCase {
  const CreateCategoryUseCase(this.repository);
  final CategoryRepository repository;

  Future<Category> execute(Category category) async {
    return repository.create(category);
  }
}
