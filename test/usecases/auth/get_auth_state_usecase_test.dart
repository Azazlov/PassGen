import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'get_auth_state_usecase_test.mocks.dart';
import 'package:mockito/annotations.dart';

import 'package:pass_gen/domain/usecases/auth/get_auth_state_usecase.dart';
import 'package:pass_gen/domain/repositories/auth_repository.dart';
import 'package:pass_gen/domain/entities/auth_state.dart';

@GenerateMocks([AuthRepository])
void main() {
  late GetAuthStateUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = GetAuthStateUseCase(mockRepository);
  });

  group('GetAuthStateUseCase', () {
    test('должен вернуть авторизованное состояние', () async {
      // Arrange
      final expectedState = AuthState(
        isAuthenticated: true,
        isPinSetup: true,
        isLocked: false,
      );
      
      when(mockRepository.getAuthState())
          .thenAnswer((_) async => expectedState);

      // Act
      final result = await useCase.execute();

      // Assert
      expect(result, equals(expectedState));
      expect(result.isAuthenticated, isTrue);
      expect(result.isPinSetup, isTrue);
      verify(mockRepository.getAuthState()).called(1);
    });

    test('должен вернуть неавторизованное состояние', () async {
      // Arrange
      final expectedState = AuthState(
        isAuthenticated: false,
        isPinSetup: true,
        isLocked: false,
      );
      
      when(mockRepository.getAuthState())
          .thenAnswer((_) async => expectedState);

      // Act
      final result = await useCase.execute();

      // Assert
      expect(result.isAuthenticated, isFalse);
      expect(result.isPinSetup, isTrue);
    });

    test('должен вернуть состояние с блокировкой', () async {
      // Arrange
      final lockoutTime = DateTime.now().add(const Duration(seconds: 30));
      final expectedState = AuthState(
        isAuthenticated: false,
        isPinSetup: true,
        isLocked: true,
        lockoutUntil: lockoutTime,
      );
      
      when(mockRepository.getAuthState())
          .thenAnswer((_) async => expectedState);

      // Act
      final result = await useCase.execute();

      // Assert
      expect(result.isAuthenticated, isFalse);
      expect(result.isLocked, isTrue);
      expect(result.lockoutUntil, isNotNull);
    });

    test('должен вернуть состояние без PIN', () async {
      // Arrange
      final expectedState = AuthState(
        isAuthenticated: false,
        isPinSetup: false,
        isLocked: false,
      );
      
      when(mockRepository.getAuthState())
          .thenAnswer((_) async => expectedState);

      // Act
      final result = await useCase.execute();

      // Assert
      expect(result.isPinSetup, isFalse);
    });

    test('должен вызвать repository.getAuthState ровно 1 раз', () async {
      // Arrange
      when(mockRepository.getAuthState())
          .thenAnswer((_) async => AuthState(isAuthenticated: false, isPinSetup: true));

      // Act
      await useCase.execute();

      // Assert
      verify(mockRepository.getAuthState()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
