import '../entities/category.dart';

/// Интерфейс репозитория категорий
abstract class CategoryRepository {
  /// Получение всех категорий
  Future<List<Category>> getAll();

  /// Получение категории по ID
  Future<Category?> getById(int id);

  /// Создание категории
  Future<Category> create(Category category);

  /// Обновление категории
  Future<Category> update(Category category);

  /// Удаление категории
  Future<void> delete(int id);

  /// Получение системных категорий
  Future<List<Category>> getSystemCategories();

  /// Получение пользовательских категорий
  Future<List<Category>> getUserCategories();
}
