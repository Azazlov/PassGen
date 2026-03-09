import '../../repositories/category_repository.dart';

/// Использование: Удаление категории
class DeleteCategoryUseCase {
  const DeleteCategoryUseCase(this.repository);
  final CategoryRepository repository;

  Future<void> execute(int id) async {
    return repository.delete(id);
  }
}
