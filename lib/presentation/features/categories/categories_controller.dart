import 'package:flutter/material.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/usecases/category/get_categories_usecase.dart';
import '../../../domain/usecases/category/create_category_usecase.dart';
import '../../../domain/usecases/category/update_category_usecase.dart';
import '../../../domain/usecases/category/delete_category_usecase.dart';

/// Контроллер для управления категориями
class CategoriesController extends ChangeNotifier {
  final GetCategoriesUseCase _getCategoriesUseCase;
  final CreateCategoryUseCase _createCategoryUseCase;
  final UpdateCategoryUseCase _updateCategoryUseCase;
  final DeleteCategoryUseCase _deleteCategoryUseCase;

  CategoriesController({
    required GetCategoriesUseCase getCategoriesUseCase,
    required CreateCategoryUseCase createCategoryUseCase,
    required UpdateCategoryUseCase updateCategoryUseCase,
    required DeleteCategoryUseCase deleteCategoryUseCase,
  })  : _getCategoriesUseCase = getCategoriesUseCase,
        _createCategoryUseCase = createCategoryUseCase,
        _updateCategoryUseCase = updateCategoryUseCase,
        _deleteCategoryUseCase = deleteCategoryUseCase;

  List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isEmpty => _categories.isEmpty;

  /// Загрузка категорий
  Future<void> loadCategories() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _categories = await _getCategoriesUseCase.execute();
    } catch (e) {
      _error = 'Ошибка загрузки категорий: $e';
      _categories = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Создание категории
  Future<bool> createCategory(String name, String icon) async {
    _isLoading = true;
    notifyListeners();

    try {
      final category = Category(
        name: name,
        icon: icon,
        isSystem: false,
        createdAt: DateTime.now(),
      );
      await _createCategoryUseCase.execute(category);
      await loadCategories();
      return true;
    } catch (e) {
      _error = 'Ошибка создания категории: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  /// Обновление категории
  Future<bool> updateCategory(Category category) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _updateCategoryUseCase.execute(category);
      await loadCategories();
      return true;
    } catch (e) {
      _error = 'Ошибка обновления категории: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  /// Удаление категории
  Future<bool> deleteCategory(int id, bool isSystem) async {
    if (isSystem) {
      _error = 'Нельзя удалить системную категорию';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      await _deleteCategoryUseCase.execute(id);
      await loadCategories();
      return true;
    } catch (e) {
      _error = 'Ошибка удаления категории: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  /// Получение категории по ID
  Category? getCategoryById(int? id) {
    if (id == null) return null;
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Получение системных категорий
  List<Category> getSystemCategories() {
    return _categories.where((c) => c.isSystem).toList();
  }

  /// Получение пользовательских категорий
  List<Category> getUserCategories() {
    return _categories.where((c) => !c.isSystem).toList();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _categories.clear();
    super.dispose();
  }
}
