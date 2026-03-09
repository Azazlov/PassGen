import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../database/database_helper.dart';
import '../models/category_model.dart';

/// Реализация репозитория категорий для SQLite
class CategoryRepositoryImpl implements CategoryRepository {
  CategoryRepositoryImpl({DatabaseHelper? dbHelper})
    : _dbHelper = dbHelper ?? DatabaseHelper();
  final DatabaseHelper _dbHelper;

  @override
  Future<List<Category>> getAll() async {
    final maps = await _dbHelper.queryAll('categories');
    return maps.map(CategoryModel.fromMap).map(_toEntity).toList();
  }

  @override
  Future<Category?> getById(int id) async {
    final map = await _dbHelper.queryById('categories', id);
    if (map == null) return null;
    final model = CategoryModel.fromMap(map);
    return _toEntity(model);
  }

  @override
  Future<Category> create(Category category) async {
    final model = _toModel(category);
    final id = await _dbHelper.insert('categories', model.toMap());
    return category.copyWith(id: id);
  }

  @override
  Future<Category> update(Category category) async {
    if (category.id == null) {
      throw ArgumentError('Category must have an id to update');
    }
    final model = _toModel(category);
    await _dbHelper.update('categories', model.toMap(), id: category.id!);
    return category;
  }

  @override
  Future<void> delete(int id) async {
    await _dbHelper.deleteById('categories', id);
  }

  @override
  Future<List<Category>> getSystemCategories() async {
    final maps = await _dbHelper.query(
      'categories',
      where: 'is_system = ?',
      whereArgs: [1],
    );
    return maps.map(CategoryModel.fromMap).map(_toEntity).toList();
  }

  @override
  Future<List<Category>> getUserCategories() async {
    final maps = await _dbHelper.query(
      'categories',
      where: 'is_system = ?',
      whereArgs: [0],
    );
    return maps.map(CategoryModel.fromMap).map(_toEntity).toList();
  }

  /// Преобразование модели в entity
  Category _toEntity(CategoryModel model) {
    return Category(
      id: model.id,
      name: model.name,
      icon: model.icon,
      isSystem: model.isSystem,
      createdAt: model.createdAt,
    );
  }

  /// Преобразование entity в модель
  CategoryModel _toModel(Category entity) {
    return CategoryModel(
      id: entity.id,
      name: entity.name,
      icon: entity.icon,
      isSystem: entity.isSystem,
      createdAt: entity.createdAt,
    );
  }
}
