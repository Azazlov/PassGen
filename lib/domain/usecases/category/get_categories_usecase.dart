import '../../entities/category.dart';
import '../../repositories/category_repository.dart';

/// Использование: Получение всех категорий
class GetCategoriesUseCase {
  const GetCategoriesUseCase(this.repository);
  final CategoryRepository repository;

  Future<List<Category>> execute() async {
    return repository.getAll();
  }
}
