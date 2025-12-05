import 'dart:convert';
import 'dart:math';
import 'package:cryptography/cryptography.dart';

// Функция создания рандомных байтов (Стандартно - 32 байта)
List<int> random({int len = 32}){
  Random random = Random.secure();
  List<int> bytesList = [];

  for (int i = 0; i < len; i++){
    bytesList.add(random.nextInt(255));
  }

  return bytesList;
}

// Объект шифра с методами:
// 1. Экспорт конфига
// 2. Шифрование сообщения с записью данных в свойства
// 3. Дешифрование хранимого сообщения по ключу
class EncryptedPassword {
  late List<int> _nonce;
  late List<int> _nonceBox;
  late List<int> _cipherText;
  late Mac _mac;
  late final Chacha20 _algorithm = Chacha20.poly1305Aead();

  // Создает шифр по JSON конфигу, либо просто инициализирует
  EncryptedPassword({String? encrJSON}){
    if (encrJSON != null) {    
      Map<String, dynamic> encr = jsonDecode(encrJSON);
      _nonce = List<int>.from(base64Decode(encr['nonce']!));
      _nonceBox = List<int>.from(base64Decode(encr['nonceBox']!));
      _cipherText = List<int>.from(base64Decode(encr['cipherText']!));
      _mac = Mac(List<int>.from(base64Decode(encr['mac']!)));
    }
  }

  // Внутренняя функция, создает ключ шифрования
  Future<SecretKey> _getSecretKey({
    required List<int> password,
    List<int>? nonce
    }) async {

    Pbkdf2 pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: 10000, 
      bits: 256
    );

    nonce == null? nonce = random():1;

    SecretKey secretKey = 
    await pbkdf2.deriveKeyFromPassword(
      password: base64Encode(password), 
      nonce: nonce
    );
    
    return secretKey;
  }

  // Выдает шифр в виде последовательности байтов
  Future<List<int>> getEncr({
    required List<int> message, 
    required List<int> passwd
    }) async{

    List<int> nonce = random();
    SecretKey secretKey = 
    await _getSecretKey(
      password: passwd,
      nonce: nonce
    );
    SecretBox secretBox =
    await _algorithm.encrypt(
      message,
      secretKey: secretKey
    );

    _nonce = nonce;
    _nonceBox = secretBox.nonce;
    _cipherText = secretBox.cipherText;
    _mac = secretBox.mac;

    return _cipherText;
  }

  // Выдает исходное сообщение в виде последовательности байтов
  Future<List<int>> getDeEncr({
    required List<int> passwd
    }) async{

    SecretBox secretBox = SecretBox(
      _cipherText, 
      nonce: _nonceBox, 
      mac: _mac
    );
    SecretKey secretKey = 
    await _getSecretKey(
      password: passwd, 
      nonce: _nonce
    );
    
    return await _algorithm.decrypt(secretBox, secretKey: secretKey);
  }

  // Выдает конфиг шифра в виде JSON-строки
  String getEncrJSON(){
    try{
      Map<String, String> passwd = {
        'nonce': base64Encode(_nonce),
        'nonceBox': base64Encode(_nonceBox),
        'cipherText': base64Encode(_cipherText),
        'mac': base64Encode(_mac.bytes),
      };
      return jsonEncode(passwd);
    }
    catch (e){
      print('Ошибка, пароль не был сгенерирован и не имеет конфига\n$e');
      return '';
    }
  }
}