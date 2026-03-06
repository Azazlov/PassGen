import '../../entities/category.dart';
import '../../repositories/category_repository.dart';

/// Использование: Получение всех категорий
class GetCategoriesUseCase {
  final CategoryRepository repository;

  const GetCategoriesUseCase(this.repository);

  Future<List<Category>> execute() async {
    return await repository.getAll();
  }
}
