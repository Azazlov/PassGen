import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';

import 'package:pass_gen/domain/usecases/password/save_password_usecase.dart';
import 'package:pass_gen/domain/repositories/password_generator_repository.dart';
import 'package:pass_gen/core/errors/failures.dart';
import 'save_password_usecase_test.mocks.dart';

@GenerateMocks([PasswordGeneratorRepository])
void main() {
  late SavePasswordUseCase useCase;
  late MockPasswordGeneratorRepository mockRepository;

  setUp(() {
    mockRepository = MockPasswordGeneratorRepository();
    useCase = SavePasswordUseCase(mockRepository);
  });

  group('SavePasswordUseCase', () {
    const testService = 'Gmail';
    const testPassword = 'SecurePass123';
    const testConfig = 'config_string';

    test('должен успешно сохранить пароль', () async {
      // Arrange
      final expectedResult = {'success': true, 'updated': false};
      
      when(mockRepository.savePassword(
        service: testService,
        password: testPassword,
        config: testConfig,
      )).thenAnswer((_) async => Right(expectedResult));

      // Act
      final result = await useCase.execute(
        service: testService,
        password: testPassword,
        config: testConfig,
      );

      // Assert
      expect(result, isA<Right>());
      expect((result as Right).value['success'], isTrue);
      verify(mockRepository.savePassword(
        service: testService,
        password: testPassword,
        config: testConfig,
      )).called(1);
    });

    test('должен сохранить пароль с categoryId', () async {
      // Arrange
      final expectedResult = {'success': true, 'updated': false};
      
      when(mockRepository.savePassword(
        service: testService,
        password: testPassword,
        config: testConfig,
        categoryId: 1,
      )).thenAnswer((_) async => Right(expectedResult));

      // Act
      final result = await useCase.execute(
        service: testService,
        password: testPassword,
        config: testConfig,
        categoryId: 1,
      );

      // Assert
      expect(result, isA<Right>());
      verify(mockRepository.savePassword(
        service: testService,
        password: testPassword,
        config: testConfig,
        categoryId: 1,
      )).called(1);
    });

    test('должен сохранить пароль с login', () async {
      // Arrange
      final expectedResult = {'success': true, 'updated': false};
      
      when(mockRepository.savePassword(
        service: testService,
        password: testPassword,
        config: testConfig,
        login: 'user@example.com',
      )).thenAnswer((_) async => Right(expectedResult));

      // Act
      final result = await useCase.execute(
        service: testService,
        password: testPassword,
        config: testConfig,
        login: 'user@example.com',
      );

      // Assert
      expect(result, isA<Right>());
      verify(mockRepository.savePassword(
        service: testService,
        password: testPassword,
        config: testConfig,
        login: 'user@example.com',
      )).called(1);
    });

    test('должен вернуть ошибку при неудачном сохранении', () async {
      // Arrange
      when(mockRepository.savePassword(
        service: testService,
        password: testPassword,
        config: testConfig,
      )).thenAnswer((_) async => Left(PasswordGenerationFailure(message: 'Ошибка сохранения')));

      // Act
      final result = await useCase.execute(
        service: testService,
        password: testPassword,
        config: testConfig,
      );

      // Assert
      expect(result, isA<Left>());
      expect((result as Left).value.message, contains('Ошибка сохранения'));
    });

    test('должен вернуть updated=true при обновлении', () async {
      // Arrange
      final expectedResult = {'success': true, 'updated': true};
      
      when(mockRepository.savePassword(
        service: testService,
        password: testPassword,
        config: testConfig,
      )).thenAnswer((_) async => Right(expectedResult));

      // Act
      final result = await useCase.execute(
        service: testService,
        password: testPassword,
        config: testConfig,
      );

      // Assert
      expect((result as Right).value['updated'], isTrue);
    });
  });
}
