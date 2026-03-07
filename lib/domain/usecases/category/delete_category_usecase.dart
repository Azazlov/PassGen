import '../../repositories/category_repository.dart';

/// Использование: Удаление категории
class DeleteCategoryUseCase {
  final CategoryRepository repository;

  const DeleteCategoryUseCase(this.repository);

  Future<void> execute(int id) async {
    return await repository.delete(id);
  }
}
