import '../../entities/category.dart';
import '../../repositories/category_repository.dart';

/// Использование: Создание категории
class CreateCategoryUseCase {
  final CategoryRepository repository;

  const CreateCategoryUseCase(this.repository);

  Future<Category> execute(Category category) async {
    return await repository.create(category);
  }
}
